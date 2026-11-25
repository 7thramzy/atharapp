import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef QuranAudioDownloadProgress = void Function(
  int receivedBytes,
  int expectedBytes,
);

/// A chapter recording returned by an approved Quran Foundation audio source.
class QuranChapterAudioAsset {
  const QuranChapterAudioAsset({
    required this.sourceId,
    required this.reciterId,
    required this.reciterName,
    required this.surahNumber,
    required this.audioUri,
    required this.fileSizeBytes,
    required this.format,
    this.publisher = 'Quran Foundation',
  });

  final String sourceId;
  final String reciterId;
  final String reciterName;
  final int surahNumber;
  final Uri audioUri;
  final int fileSizeBytes;
  final String format;
  final String publisher;
}

class DownloadedQuranAudio {
  const DownloadedQuranAudio({
    required this.sourceId,
    required this.reciterId,
    required this.reciterName,
    required this.surahNumber,
    required this.file,
    required this.sizeBytes,
    required this.format,
    required this.audioUri,
    required this.publisher,
    required this.downloadedAt,
  });

  final String sourceId;
  final String reciterId;
  final String reciterName;
  final int surahNumber;
  final File file;
  final int sizeBytes;
  final String format;
  final Uri audioUri;
  final String publisher;
  final DateTime downloadedAt;
}

class QuranAudioDownloadException implements Exception {
  const QuranAudioDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class QuranAudioStorageLimitException extends QuranAudioDownloadException {
  const QuranAudioStorageLimitException(super.message);
}

/// Stores user-requested recitation files only inside Athaar's private
/// application-support directory. Audio is never exported or re-hosted.
class QuranAudioDownloadManager {
  QuranAudioDownloadManager({
    http.Client? client,
    Future<Directory> Function()? privateDirectoryProvider,
    this.maxStorageBytes = 512 * 1024 * 1024,
  }) : _client = client ?? http.Client(),
       _privateDirectoryProvider =
           privateDirectoryProvider ?? getApplicationSupportDirectory;

  static const allowedAudioHosts = <String>{
    'quranicaudio.com',
    'download.quranicaudio.com',
    'verses.quran.com',
    'verses.quran.foundation',
    'audio.qurancdn.com',
  };

  static const _audioExtensions = <String>{
    'mp3',
    'm4a',
    'aac',
    'ogg',
    'opus',
    'flac',
  };

  final http.Client _client;
  final Future<Directory> Function() _privateDirectoryProvider;
  final int maxStorageBytes;
  final Set<String> _activeSourceIds = {};

  void close() => _client.close();

  Future<Directory> _audioDirectory() async {
    final privateDirectory = await _privateDirectoryProvider();
    final audioDirectory = Directory(
      '${privateDirectory.path}${Platform.pathSeparator}quran_audio',
    );
    if (!await audioDirectory.exists()) {
      await audioDirectory.create(recursive: true);
    }
    return audioDirectory;
  }

  static void validateAsset(QuranChapterAudioAsset asset) {
    if (asset.sourceId.trim().isEmpty ||
        asset.reciterId.trim().isEmpty ||
        asset.reciterName.trim().isEmpty) {
      throw ArgumentError('Audio source, reciter ID, and reciter name are required.');
    }
    if (asset.surahNumber < 1 || asset.surahNumber > 114) {
      throw RangeError.range(asset.surahNumber, 1, 114, 'surahNumber');
    }
    if (asset.fileSizeBytes <= 0) {
      throw ArgumentError.value(
        asset.fileSizeBytes,
        'fileSizeBytes',
        'must be supplied by the audio source',
      );
    }
    if (!asset.audioUri.isAbsolute ||
        asset.audioUri.scheme != 'https' ||
        asset.audioUri.userInfo.isNotEmpty ||
        !allowedAudioHosts.contains(asset.audioUri.host.toLowerCase())) {
      throw ArgumentError.value(
        asset.audioUri,
        'audioUri',
        'must be an HTTPS URL from an approved Quran Foundation audio host',
      );
    }
    if (!_audioExtensions.contains(asset.format.toLowerCase())) {
      throw ArgumentError.value(asset.format, 'format', 'unsupported audio format');
    }
  }

  Future<int> get usedStorageBytes async {
    final downloads = await listDownloads();
    var total = 0;
    for (final download in downloads) {
      total += download.sizeBytes;
    }
    return total;
  }

  Future<List<DownloadedQuranAudio>> listDownloads() async {
    final directory = await _audioDirectory();
    final records = <DownloadedQuranAudio>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      try {
        final decoded = jsonDecode(await entity.readAsString());
        if (decoded is! Map<String, dynamic>) continue;
        final record = await _recordFromJson(directory, decoded);
        if (record != null) records.add(record);
      } on Object {
        // Ignore incomplete or invalid sidecars; they are not usable downloads.
      }
    }
    records.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return records;
  }

  Future<DownloadedQuranAudio?> findBySourceId(String sourceId) async {
    final records = await listDownloads();
    for (final record in records) {
      if (record.sourceId == sourceId) return record;
    }
    return null;
  }

  Future<DownloadedQuranAudio> download(
    QuranChapterAudioAsset asset, {
    required bool userRequested,
    QuranAudioDownloadProgress? onProgress,
  }) async {
    if (!userRequested) {
      throw StateError('Offline audio must be explicitly requested by the user.');
    }
    validateAsset(asset);
    if (asset.fileSizeBytes > maxStorageBytes) {
      throw QuranAudioStorageLimitException(
        'The recording is larger than the configured offline-audio limit.',
      );
    }
    if (!_activeSourceIds.add(asset.sourceId)) {
      throw StateError('This recording is already downloading.');
    }

    File? temporaryAudio;
    File? finalAudio;
    File? temporaryMetadata;
    File? finalMetadata;
    try {
      final directory = await _audioDirectory();
      final existing = await findBySourceId(asset.sourceId);
      if (existing != null &&
          existing.audioUri == asset.audioUri &&
          existing.sizeBytes == asset.fileSizeBytes &&
          await existing.file.exists() &&
          await existing.file.length() == asset.fileSizeBytes) {
        return existing;
      }

      final previousSize = existing?.sizeBytes ?? 0;
      final used = await usedStorageBytes;
      final projected = used - previousSize + asset.fileSizeBytes;
      if (projected > maxStorageBytes) {
        throw QuranAudioStorageLimitException(
          'Offline audio storage limit reached. Delete an existing surah or increase the limit first.',
        );
      }

      if (existing != null) {
        await delete(existing.sourceId);
      }

      final safeReciter = _safeFilePart(asset.reciterId);
      final safeSource = _safeFilePart(asset.sourceId);
      final baseName =
          'qf_${safeReciter}_${asset.surahNumber.toString().padLeft(3, '0')}_$safeSource';
      final extension = asset.format.toLowerCase();
      final fileName = '$baseName.$extension';
      final finalAudioPath =
          '${directory.path}${Platform.pathSeparator}$fileName';
      final temporaryAudioPath = '$finalAudioPath.part';
      final finalMetadataPath =
          '${directory.path}${Platform.pathSeparator}$baseName.json';
      final temporaryMetadataPath = '$finalMetadataPath.part';

      finalAudio = File(finalAudioPath);
      temporaryAudio = File(temporaryAudioPath);
      finalMetadata = File(finalMetadataPath);
      temporaryMetadata = File(temporaryMetadataPath);

      if (await temporaryAudio.exists()) await temporaryAudio.delete();
      if (await temporaryMetadata.exists()) await temporaryMetadata.delete();

      final request = http.Request('GET', asset.audioUri);
      final response = await _client.send(request);
      if (response.statusCode != HttpStatus.ok) {
        throw QuranAudioDownloadException(
          'The audio source returned HTTP ${response.statusCode}.',
        );
      }
      if (response.contentLength != null &&
          response.contentLength != asset.fileSizeBytes) {
        throw QuranAudioDownloadException(
          'The source-reported file size does not match its response headers.',
        );
      }

      var receivedBytes = 0;
      final sink = temporaryAudio.openWrite();
      try {
        await for (final chunk in response.stream) {
          receivedBytes += chunk.length;
          if (receivedBytes > asset.fileSizeBytes ||
              receivedBytes > maxStorageBytes) {
            throw QuranAudioDownloadException(
              'The downloaded recording exceeded its declared size.',
            );
          }
          sink.add(chunk);
          onProgress?.call(receivedBytes, asset.fileSizeBytes);
        }
        await sink.flush();
      } catch (_) {
        await sink.close();
        rethrow;
      }
      await sink.close();

      if (receivedBytes != asset.fileSizeBytes ||
          await temporaryAudio.length() != asset.fileSizeBytes) {
        throw QuranAudioDownloadException(
          'The recording is incomplete; the temporary file was discarded.',
        );
      }

      await temporaryAudio.rename(finalAudioPath);
      final downloadedAt = DateTime.now().toUtc();
      final metadata = <String, Object>{
        'sourceId': asset.sourceId,
        'reciterId': asset.reciterId,
        'reciterName': asset.reciterName,
        'surahNumber': asset.surahNumber,
        'fileName': fileName,
        'sizeBytes': receivedBytes,
        'format': extension,
        'audioUri': asset.audioUri.toString(),
        'publisher': asset.publisher,
        'downloadedAt': downloadedAt.toIso8601String(),
      };
      await temporaryMetadata.writeAsString(jsonEncode(metadata), flush: true);
      await temporaryMetadata.rename(finalMetadataPath);

      return DownloadedQuranAudio(
        sourceId: asset.sourceId,
        reciterId: asset.reciterId,
        reciterName: asset.reciterName,
        surahNumber: asset.surahNumber,
        file: finalAudio,
        sizeBytes: receivedBytes,
        format: extension,
        audioUri: asset.audioUri,
        publisher: asset.publisher,
        downloadedAt: downloadedAt,
      );
    } catch (_) {
      if (temporaryAudio != null && await temporaryAudio.exists()) {
        await temporaryAudio.delete();
      }
      if (temporaryMetadata != null && await temporaryMetadata.exists()) {
        await temporaryMetadata.delete();
      }
      if (finalAudio != null && await finalAudio.exists() &&
          (finalMetadata == null || !await finalMetadata.exists())) {
        await finalAudio.delete();
      }
      rethrow;
    } finally {
      _activeSourceIds.remove(asset.sourceId);
    }
  }

  /// Deletes a recording if its source is removed or its rights are withdrawn.
  Future<void> delete(String sourceId) async {
    final directory = await _audioDirectory();
    for (final record in await listDownloads()) {
      if (record.sourceId != sourceId) continue;
      if (await record.file.exists()) await record.file.delete();
      final sidecar = File(
        '${directory.path}${Platform.pathSeparator}${record.file.uri.pathSegments.last.split('.').first}.json',
      );
      if (await sidecar.exists()) await sidecar.delete();
    }
  }

  /// Apply source-removal events received from the recitation metadata sync.
  Future<void> deleteRemovedSources(Set<String> removedSourceIds) async {
    for (final sourceId in removedSourceIds) {
      await delete(sourceId);
    }
  }

  String _safeFilePart(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    if (sanitized.isEmpty) {
      throw ArgumentError.value(value, 'filePart', 'cannot be empty');
    }
    return sanitized.length > 48 ? sanitized.substring(0, 48) : sanitized;
  }

  Future<DownloadedQuranAudio?> _recordFromJson(
    Directory directory,
    Map<String, dynamic> json,
  ) async {
    final sourceId = json['sourceId'];
    final reciterId = json['reciterId'];
    final reciterName = json['reciterName'];
    final surahNumber = json['surahNumber'];
    final fileName = json['fileName'];
    final sizeBytes = json['sizeBytes'];
    final format = json['format'];
    final audioUriRaw = json['audioUri'];
    final publisher = json['publisher'];
    final downloadedAtRaw = json['downloadedAt'];
    if (sourceId is! String ||
        reciterId is! String ||
        reciterName is! String ||
        surahNumber is! int ||
        fileName is! String ||
        sizeBytes is! int ||
        format is! String ||
        audioUriRaw is! String ||
        publisher is! String ||
        downloadedAtRaw is! String) {
      return null;
    }
    if (fileName.contains('/') || fileName.contains(r'\')) return null;
    final audioUri = Uri.tryParse(audioUriRaw);
    final downloadedAt = DateTime.tryParse(downloadedAtRaw);
    if (audioUri == null || downloadedAt == null) return null;
    final file = File(
      '${directory.path}${Platform.pathSeparator}$fileName',
    );
    if (!await file.exists() || await file.length() != sizeBytes) return null;
    return DownloadedQuranAudio(
      sourceId: sourceId,
      reciterId: reciterId,
      reciterName: reciterName,
      surahNumber: surahNumber,
      file: file,
      sizeBytes: sizeBytes,
      format: format,
      audioUri: audioUri,
      publisher: publisher,
      downloadedAt: downloadedAt,
    );
  }
}
