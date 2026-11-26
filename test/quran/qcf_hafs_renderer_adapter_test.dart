import 'package:athaar/features/quran/data/qcf_hafs_renderer_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QCF Hafs page map', () {
    final adapter = QcfQuranPlusHafsRendererAdapter();

    test('maps the first Mushaf page to Al-Fatiha 1:1', () {
      final position = adapter.pageStart(1);

      expect(position, isNotNull);
      expect(position!.surahNumber, 1);
      expect(position.ayahNumber, 1);
    });

    test('maps the second Mushaf page to Al-Baqarah 2:1', () {
      final position = adapter.pageStart(2);

      expect(position, isNotNull);
      expect(position!.surahNumber, 2);
      expect(position.ayahNumber, 1);
    });

    test('aligns an even page to the first page of its two-page spread', () {
      expect(adapter.firstVisiblePage(2, twoPageLayout: true), 1);
      expect(adapter.firstVisiblePage(604, twoPageLayout: true), 603);
      expect(adapter.firstVisiblePage(3, twoPageLayout: true), 3);
      expect(adapter.firstVisiblePage(2, twoPageLayout: false), 2);
    });

    test('resolves Al-Fatiha 1:1 to the first Mushaf page', () {
      expect(adapter.pageForAyah(1, 1), 1);
    });

    test('resolves Al-Baqarah 2:1 to the second Mushaf page', () {
      expect(adapter.pageForAyah(2, 1), 2);
    });

    test('rejects invalid surah and ayah positions', () {
      expect(adapter.pageForAyah(0, 1), isNull);
      expect(adapter.pageForAyah(1, 0), isNull);
    });

    test('rejects page numbers outside the 604-page Hafs Mushaf', () {
      expect(adapter.pageStart(0), isNull);
      expect(adapter.pageStart(605), isNull);
    });
  });
}
