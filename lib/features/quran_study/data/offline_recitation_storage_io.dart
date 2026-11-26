import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'quran_study_repository.dart';
import 'offline_recitation_errors.dart';

const bool isSupported = true;

void _validate(String edition, int surah, [int? ayah]) {
  if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(edition)) {
    throw ArgumentError.value(edition, 'edition');
  }
  if (surah < 1 || surah > 114) {
    throw RangeError.range(surah, 1, 114, 'surah');
  }
  if (ayah != null && (ayah < 1 || ayah > 286)) {
    throw RangeError.range(ayah, 1, 286, 'ayah');
  }
}

Future<Directory> _surahDirectory(String edition, int surah) async {
  _validate(edition, surah);
  final root = await getApplicationSupportDirectory();
  return Directory(p.join(root.path, 'athaar', 'recitations', edition, 'surah_' + surah.toString()));
}

Future<String?> findAyah({
  required String edition,
  required int surah,
  required int ayah,
}) async {
  _validate(edition, surah, ayah);
  final directory = await _surahDirectory(edition, surah);
  final file = File(p.join(directory.path, 'ayah_' + ayah.toString() + '.mp3'));
  return await file.exists() ? file.path : null;
}

Future<int> downloadedCount({
  required String edition,
  required int surah,
}) async {
  final directory = await _surahDirectory(edition, surah);
  if (!await directory.exists()) return 0;
  var count = 0;
  await for (final entity in directory.list(followLinks: false)) {
    if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
      count++;
    }
  }
  return count;
}

Future<void> downloadSurah({
  required String edition,
  required int surah,
  required List<QuranAudioTrack> tracks,
  required void Function(int completed, int total) onProgress,
  required bool Function() shouldCancel,
}) async {
  _validate(edition, surah);
  if (tracks.isEmpty || tracks.length > 286) {
    throw ArgumentError.value(tracks.length, 'tracks');
  }
  final directory = await _surahDirectory(edition, surah);
  await directory.create(recursive: true);
  final client = http.Client();
  var completed = 0;

  try {
    for (final track in tracks) {
      if (shouldCancel()) {
        throw const OfflineRecitationDownloadCancelled();
      }
      _validate(edition, surah, track.numberInSurah);
      if (track.uri.scheme != 'https' ||
          track.uri.host != 'cdn.islamic.network') {
        throw const FormatException('Blocked an untrusted recitation download URL.');
      }

      final target = File(p.join(
        directory.path,
        'ayah_' + track.numberInSurah.toString() + '.mp3',
      ));
      if (await target.exists() && await target.length() > 0) {
        completed++;
        onProgress(completed, tracks.length);
        continue;
      }

      final temporary = File(target.path + '.part');
      try {
        final response = await client.get(track.uri).timeout(
          const Duration(seconds: 45),
        );
        if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
          throw HttpException(
            'Audio download failed for ayah ' +
                track.numberInSurah.toString() +
                ' (HTTP ' + response.statusCode.toString() + ').',
            uri: track.uri,
          );
        }
        await temporary.writeAsBytes(response.bodyBytes, flush: true);
        if (await temporary.length() == 0) {
          throw const FormatException('The downloaded audio file is empty.');
        }
        if (await target.exists()) {
          await target.delete();
        }
        await temporary.rename(target.path);
      } catch (_) {
        if (await temporary.exists()) {
          await temporary.delete();
        }
        rethrow;
      }

      completed++;
      onProgress(completed, tracks.length);
    }
  } finally {
    client.close();
  }
}

Future<void> deleteSurah({
  required String edition,
  required int surah,
}) async {
  final directory = await _surahDirectory(edition, surah);
  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }
}
