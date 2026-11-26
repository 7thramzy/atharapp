import 'package:athaar/features/quran_study/data/quran_study_repository.dart';
import 'offline_recitation_storage_stub.dart'
    if (dart.library.io) 'offline_recitation_storage_io.dart' as platform;

/// Stores user-requested recitations in the application's private support area.
/// Audio is never exported, shared, uploaded, or bundled into Athaar.
class OfflineRecitationStorage {
  bool get isSupported => platform.isSupported;

  Future<String?> findAyah({
    required String edition,
    required int surah,
    required int ayah,
  }) =>
      platform.findAyah(edition: edition, surah: surah, ayah: ayah);

  Future<int> downloadedCount({
    required String edition,
    required int surah,
  }) =>
      platform.downloadedCount(edition: edition, surah: surah);

  Future<void> downloadSurah({
    required String edition,
    required int surah,
    required List<QuranAudioTrack> tracks,
    required void Function(int completed, int total) onProgress,
    required bool Function() shouldCancel,
  }) =>
      platform.downloadSurah(
        edition: edition,
        surah: surah,
        tracks: tracks,
        onProgress: onProgress,
        shouldCancel: shouldCancel,
      );

  Future<void> deleteSurah({
    required String edition,
    required int surah,
  }) =>
      platform.deleteSurah(edition: edition, surah: surah);
}

