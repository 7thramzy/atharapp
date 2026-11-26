import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Private, user-initiated AlQuran Cloud surah downloads.
///
/// Files stay in the app support directory. They are never exported or
/// uploaded. The CDN's documented surah endpoint serves one file per surah,
/// which avoids making thousands of separate ayah download requests.
class OfflineRecitationStore {
  OfflineRecitationStore({
    http.Client? client,
    Future<Directory> Function()? supportDirectory,
  }) : _client = client ?? http.Client(),
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  final http.Client _client;
  final Future<Directory> Function() _supportDirectory;

  bool get isSupported => true;

  static const _bitrates = <int>[128, 64, 48, 40, 32, 192];

  String _validatedEdition(String edition) {
    final value = edition.trim();
    if (!RegExp(r'^[a-zA-Z0-9._-]{1,80}$').hasMatch(value)) {
      throw ArgumentError.value(edition, 'edition', 'Invalid audio edition identifier.');
    }
    return value;
  }

  void _validateSurah(int surah) {
    if (surah < 1 || surah > 114) {
      throw RangeError.range(surah, 1, 114, 'surah');
    }
  }

  Future<Directory> _editionDirectory(String edition) async {
    final safeEdition = _validatedEdition(edition);
    final base = await _supportDirectory();
    final directory = Directory(
      '${base.path}${Platform.pathSeparator}athaar_recitations'
      '${Platform.pathSeparator}$safeEdition',
    );
    await directory.create(recursive: true);
    return directory;
  }

  Future<File> _fileFor(String edition, int surah) async {
    _validateSurah(surah);
    final directory = await _editionDirectory(edition);
    final number = surah.toString().padLeft(3, '0');
    return File('${directory.path}${Platform.pathSeparator}surah-$number.mp3');
  }

  Future<String?> localSurahPath({
    required String edition,
    required int surah,
  }) async {
    final file = await _fileFor(edition, surah);
    if (!await file.exists() || await file.length() == 0) return null;
    return file.path;
  }

  Future<bool> isSurahDownloaded({
    required String edition,
    required int surah,
  }) async => (await localSurahPath(edition: edition, surah: surah)) != null;

  Future<Set<int>> downloadedSurahs(String edition) async {
    final directory = await _editionDirectory(edition);
    final result = <int>{};
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File) continue;
      final match = RegExp(r'^surah-(\d{3})\.mp3$').firstMatch(
        entity.uri.pathSegments.last,
      );
      if (match == null) continue;
      final number = int.tryParse(match.group(1)!);
      if (number != null && number >= 1 && number <= 114 && await entity.length() > 0) {
        result.add(number);
      }
    }
    return result;
  }

  Future<String> downloadSurah({
    required String edition,
    required int surah,
  }) async {
    _validateSurah(surah);
    final safeEdition = _validatedEdition(edition);
    final target = await _fileFor(safeEdition, surah);
    if (await target.exists() && await target.length() > 0) return target.path;

    final partial = File('${target.path}.part');
    Object? lastError;

    for (final bitrate in _bitrates) {
      final uri = Uri.https(
        'cdn.islamic.network',
        '/quran/audio-surah/$bitrate/$safeEdition/$surah.mp3',
      );

      try {
        final request = http.Request('GET', uri)
          ..headers['Accept'] = 'audio/mpeg'
          ..headers['User-Agent'] = 'Athaar/0.3 offline-recitation';
        final response = await _client.send(request);

        if (response.statusCode == 404) {
          await response.stream.drain<void>();
          continue;
        }
        if (response.statusCode < 200 || response.statusCode >= 300) {
          await response.stream.drain<void>();
          throw HttpException(
            'Audio download failed with HTTP ${response.statusCode}.',
            uri: uri,
          );
        }

        if (await partial.exists()) await partial.delete();
        final sink = partial.openWrite();
        try {
          await response.stream.pipe(sink);
        } catch (_) {
          await sink.close();
          rethrow;
        }

        if (!await partial.exists() || await partial.length() == 0) {
          throw const FormatException('The audio provider returned an empty file.');
        }

        if (await target.exists()) await target.delete();
        final saved = await partial.rename(target.path);
        return saved.path;
      } catch (error) {
        lastError = error;
        if (await partial.exists()) await partial.delete();
        if (error is HttpException && error.message.contains('HTTP 404')) {
          continue;
        }
        rethrow;
      }
    }

    throw HttpException(
      'No supported audio bitrate was found for $safeEdition, surah $surah. '
      'Last error: ${lastError ?? 'not available'}.',
    );
  }

  Future<void> deleteSurah({
    required String edition,
    required int surah,
  }) async {
    final file = await _fileFor(edition, surah);
    if (await file.exists()) await file.delete();
    final partial = File('${file.path}.part');
    if (await partial.exists()) await partial.delete();
  }

  Future<void> deleteAllForEdition(String edition) async {
    final directory = await _editionDirectory(edition);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  void close() => _client.close();
}
