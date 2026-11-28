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

    test('rejects invalid surah numbers', () {
      expect(SurahBasmalaHeader.shouldDisplay(0), isFalse);
      expect(SurahBasmalaHeader.shouldDisplay(115), isFalse);
    });
  });
}
