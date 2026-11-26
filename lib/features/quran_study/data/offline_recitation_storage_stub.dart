import 'quran_study_repository.dart';

const bool isSupported = false;

Future<String?> findAyah({
  required String edition,
  required int surah,
  required int ayah,
}) async =>
    null;

Future<int> downloadedCount({
  required String edition,
  required int surah,
}) async =>
    0;

Future<void> downloadSurah({
  required String edition,
  required int surah,
  required List<QuranAudioTrack> tracks,
  required void Function(int completed, int total) onProgress,
  required bool Function() shouldCancel,
}) =>
    Future.error(
      UnsupportedError('Offline recitation downloads are not supported on web.'),
    );

Future<void> deleteSurah({
  required String edition,
  required int surah,
}) async =>
    throw UnsupportedError('Offline recitation storage is not supported on web.');
