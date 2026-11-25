/// Stable locations for switching between Athaar Quran reading modes.
abstract final class QuranReaderRoutes {
  static String downloadedText({
    required int surahNumber,
    required int ayahNumber,
  }) {
    _validate(surahNumber, ayahNumber);
    return '/quran/text/$surahNumber?ayah=$ayahNumber';
  }

  static String hafsMushaf({
    required int surahNumber,
    required int ayahNumber,
  }) {
    _validate(surahNumber, ayahNumber);
    return '/quran/mushaf?surah=$surahNumber&ayah=$ayahNumber';
  }

  static void _validate(int surahNumber, int ayahNumber) {
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) {
      throw ArgumentError(
        'A Quran reading location must contain a valid surah and positive ayah.',
      );
    }
  }
}
