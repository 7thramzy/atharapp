/// Web fallback. Offline downloads are available on Android, iOS and desktop.
class OfflineRecitationStore {
  bool get isSupported => false;

  Future<String?> localSurahPath({
    required String edition,
    required int surah,
  }) async => null;

  Future<bool> isSurahDownloaded({
    required String edition,
    required int surah,
  }) async => false;

  Future<Set<int>> downloadedSurahs(String edition) async => <int>{};

  Future<String> downloadSurah({
    required String edition,
    required int surah,
  }) async {
    throw UnsupportedError('Offline recitation downloads are not available on this platform.');
  }

  Future<void> deleteSurah({
    required String edition,
    required int surah,
  }) async {}

  Future<void> deleteAllForEdition(String edition) async {}
  void close() {}
}
