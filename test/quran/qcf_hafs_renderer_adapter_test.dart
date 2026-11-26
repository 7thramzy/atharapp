import 'package:athaar/features/quran/data/qcf_hafs_renderer_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QCF font platform routing', () {
    test('uses the browser memory loader for the current and next page', () async {
      final webPages = <int>[];
      final nativePages = <int>[];
      final adapter = QcfQuranPlusHafsRendererAdapter(
        isWebOverride: true,
        webPageFontLoader: (page) async => webPages.add(page),
        nativePageFontLoader: (page) async => nativePages.add(page),
      );

      await adapter.ensurePageFonts(12);

      expect(webPages, [12, 13]);
      expect(nativePages, isEmpty);
    });

    test('retains the package disk loader on native platforms', () async {
      final webPages = <int>[];
      final nativePages = <int>[];
      final adapter = QcfQuranPlusHafsRendererAdapter(
        isWebOverride: false,
        webPageFontLoader: (page) async => webPages.add(page),
        nativePageFontLoader: (page) async => nativePages.add(page),
      );

      await adapter.ensurePageFonts(21);

      expect(nativePages, [21, 22]);
      expect(webPages, isEmpty);
    });

    test('does not request a page beyond the end of the Mushaf', () async {
      final requestedPages = <int>[];
      final adapter = QcfQuranPlusHafsRendererAdapter(
        isWebOverride: true,
        webPageFontLoader: (page) async => requestedPages.add(page),
      );

      await adapter.ensurePageFonts(604);

      expect(requestedPages, [604]);
    });
  });

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

    test('validates the complete 604-page map against all 6,236 surah/ayah coordinates', () {
      const ayahCounts = <int>[
        7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6,
      ];

      expect(ayahCounts, hasLength(114));
      expect(ayahCounts.fold<int>(0, (sum, count) => sum + count), 6236);

      final firstAyahByPage = <int, HafsPageStart>{};
      var previousPage = 1;
      var verifiedAyahs = 0;

      for (var surah = 1; surah <= ayahCounts.length; surah++) {
        for (var ayah = 1; ayah <= ayahCounts[surah - 1]; ayah++) {
          final page = adapter.pageForAyah(surah, ayah);
          expect(
            page,
            inInclusiveRange(1, 604),
            reason: 'Invalid page for $surah:$ayah',
          );
          expect(
            page,
            greaterThanOrEqualTo(previousPage),
            reason: 'QCF page order moved backwards at $surah:$ayah',
          );
          firstAyahByPage.putIfAbsent(
            page!,
            () => HafsPageStart(surahNumber: surah, ayahNumber: ayah),
          );
          previousPage = page;
          verifiedAyahs++;
        }
      }

      expect(verifiedAyahs, 6236);
      expect(firstAyahByPage.keys.toSet(), Set<int>.from(List<int>.generate(604, (i) => i + 1)));

      for (var page = 1; page <= 604; page++) {
        final expectedStart = firstAyahByPage[page]!;
        final actualStart = adapter.pageStart(page);
        expect(actualStart, isNotNull, reason: 'Page $page has no start coordinate');
        expect(actualStart!.surahNumber, expectedStart.surahNumber, reason: 'Wrong surah at page $page');
        expect(actualStart.ayahNumber, expectedStart.ayahNumber, reason: 'Wrong ayah at page $page');
        expect(
          adapter.pageForAyah(actualStart.surahNumber, actualStart.ayahNumber),
          page,
          reason: 'Page $page start does not map back to the same page',
        );
      }
    });

  });
}
