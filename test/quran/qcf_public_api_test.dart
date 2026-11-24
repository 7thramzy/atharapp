import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

void main() {
  test('QCF Hafs package exposes the page and word interaction API', () {
    final controller = PageController(initialPage: 0);

    try {
      final wordHighlight = WordHighlight(
        surah: 1,
        verseNumber: 1,
        wordIndex: 0,
      );

      void handleWordTap(
        int surahNumber,
        int verseNumber,
        int wordIndex,
        String rawWord,
      ) {}

      final pageView = QuranPageView(
        pageController: controller,
        highlights: const [],
        wordHighlights: [wordHighlight],
        onWordTap: handleWordTap,
        isDarkMode: false,
        isTajweed: true,
        enableTwoPageLayout: true,
      );

      expect(totalPagesCount, 604);
      expect(pageView.quranPagesCount, 604);
      expect(pageView.enableTwoPageLayout, isTrue);
      expect(pageView.wordHighlights, hasLength(1));
      expect(pageView.wordHighlights.single, same(wordHighlight));
      expect(pageView.onWordTap, same(handleWordTap));
    } finally {
      controller.dispose();
    }
  });
}
