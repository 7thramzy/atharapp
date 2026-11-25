import 'package:athaar/features/quran/data/quran_reader_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuranReaderRoutes', () {
    test('switches to downloaded text at the requested ayah', () {
      expect(
        QuranReaderRoutes.downloadedText(surahNumber: 2, ayahNumber: 255),
        '/quran/text/2?ayah=255',
      );
    });

    test('switches to the Hafs Mushaf at the same surah and ayah', () {
      expect(
        QuranReaderRoutes.hafsMushaf(surahNumber: 2, ayahNumber: 255),
        '/quran/mushaf?surah=2&ayah=255',
      );
    });

    test('rejects invalid locations before building a route', () {
      expect(
        () => QuranReaderRoutes.downloadedText(surahNumber: 115, ayahNumber: 1),
        throwsArgumentError,
      );
      expect(
        () => QuranReaderRoutes.hafsMushaf(surahNumber: 1, ayahNumber: 0),
        throwsArgumentError,
      );
    });
  });
}
