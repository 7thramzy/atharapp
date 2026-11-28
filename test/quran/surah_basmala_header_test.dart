import 'package:athaar/features/quran/presentation/surah_basmala_header.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SurahBasmalaHeader', () {
    test('shows a separate basmala for surahs that open with it', () {
      for (final surah in [2, 3, 13, 18, 114]) {
        expect(SurahBasmalaHeader.shouldDisplay(surah), isTrue);
      }
    });

    test('does not add a separate basmala to Al-Fatihah or At-Tawbah', () {
      expect(SurahBasmalaHeader.shouldDisplay(1), isFalse);
      expect(SurahBasmalaHeader.shouldDisplay(9), isFalse);
    });

    test('removes a basmala prefix from the displayed first ayah', () {
      const firstAyah =
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ المر تِلْكَ آيَاتُ الْكِتَابِ';
      expect(
        SurahBasmalaHeader.displayAyahText(
          surahNumber: 13,
          ayahNumber: 1,
          text: firstAyah,
        ),
        'المر تِلْكَ آيَاتُ الْكِتَابِ',
      );
    });

    test('preserves canonical text for exceptions and non-prefixed ayahs', () {
      const firstAyah =
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ الْحَمْدُ لِلَّهِ';
      expect(
        SurahBasmalaHeader.displayAyahText(
          surahNumber: 1,
          ayahNumber: 1,
          text: firstAyah,
        ),
        firstAyah,
      );
      expect(
        SurahBasmalaHeader.displayAyahText(
          surahNumber: 9,
          ayahNumber: 1,
          text: firstAyah,
        ),
        firstAyah,
      );
      expect(
        SurahBasmalaHeader.displayAyahText(
          surahNumber: 27,
          ayahNumber: 1,
          text: 'طس تِلْكَ آيَاتُ الْقُرْآنِ',
        ),
        'طس تِلْكَ آيَاتُ الْقُرْآنِ',
      );
      expect(
        SurahBasmalaHeader.displayAyahText(
          surahNumber: 13,
          ayahNumber: 2,
          text: firstAyah,
        ),
        firstAyah,
      );
    });

    test('rejects invalid surah numbers', () {
      expect(SurahBasmalaHeader.shouldDisplay(0), isFalse);
      expect(SurahBasmalaHeader.shouldDisplay(115), isFalse);
    });
  });
}
