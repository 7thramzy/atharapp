import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
// Keep QCF's parsed-line cache correction isolated in this adapter. The
// package parser reverses ayah segments, while QuranLine renders them inside
// an RTL RichText; the outer paragraph then places the reversed first segment
// at the right edge, visibly reversing the Mushaf reading order.
// ignore: implementation_imports
import 'package:qcf_quran_plus/src/widgets/quran_page/parsed_quran_data.dart'
    show ParsedAyahData, ParsedLineCache, parsedLineKey;

import 'qcf_web_font_loader.dart';

// The QCF package does not expose its page-data repository from its public
// barrel. Keep this pinned internal import inside this adapter only.
// ignore: implementation_imports
import 'package:qcf_quran_plus/src/widgets/quran_page/quran_repository.dart'
    show QuranRepository;

/// The first ayah represented by a standard Hafs Mushaf page.
class HafsPageStart {
  const HafsPageStart({required this.surahNumber, required this.ayahNumber});

  final int surahNumber;
  final int ayahNumber;
}

/// Athaar-facing contract for the Hafs renderer.
///
/// Package types and package-specific page/font lifecycle stay behind this
/// boundary so the presentation layer can be changed without affecting
/// QuranPosition, Drift, or the rest of Athaar.
abstract interface class HafsRendererAdapter {
  Future<void> initialize();

  /// Loads the requested page's font and the next page's font.
  ///
  /// This is intentionally page-scoped. Do not call
  /// [QcfFontLoader.setupFontsAtStartup], which eagerly iterates all 604 pages.
  Future<void> ensurePageFonts(int pageNumber);

  /// Returns the first page of the currently visible spread.
  /// A two-page spread is anchored on an odd page (1-2, 3-4, ...).
  int firstVisiblePage(int pageNumber, {required bool twoPageLayout});

  /// Returns the first surah/ayah on a one-based QCF Mushaf page.
  HafsPageStart? pageStart(int pageNumber);

  /// Returns the last surah/ayah on a one-based QCF Mushaf page.
  HafsPageStart? pageEnd(int pageNumber);

  /// Resolves a stored surah/ayah pair to its one-based Mushaf page.
  int? pageForAyah(int surahNumber, int ayahNumber);
}

/// QCF 604-page Hafs implementation, pinned to qcf_quran_plus 0.1.1.
typedef HafsPageFontLoader = Future<void> Function(int pageNumber);

class QcfQuranPlusHafsRendererAdapter implements HafsRendererAdapter {
  QcfQuranPlusHafsRendererAdapter({
    bool? isWebOverride,
    HafsPageFontLoader? webPageFontLoader,
    HafsPageFontLoader? nativePageFontLoader,
  }) : _isWeb = isWebOverride ?? kIsWeb,
       _webPageFontLoader =
           webPageFontLoader ?? QcfWebFontLoader.ensureFontLoaded,
       _nativePageFontLoader =
           nativePageFontLoader ?? QcfFontLoader.ensureFontLoaded;

  final bool _isWeb;
  final HafsPageFontLoader _webPageFontLoader;
  final HafsPageFontLoader _nativePageFontLoader;
  Future<void>? _initialization;

  @override
  Future<void> initialize() {
    return _initialization ??= _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    final repository = QuranRepository.instance;
    await repository.ensureLoaded(totalPagesCount);

    // qcf_quran_plus 0.1.1 pre-parses each line in reverse ayah order.
    // QuranLine then embeds each ayah as a WidgetSpan in an RTL RichText.
    // That outer RTL paragraph already positions the first span at the right,
    // so the parser reversal makes multi-ayah lines read backwards. Restore
    // the canonical source order in the cached presentation list only; never
    // modify Quran text, QCF glyph data, or page metadata.
    final correctedLines = <int, List<ParsedAyahData>>{};
    for (var pageNumber = 1; pageNumber <= totalPagesCount; pageNumber++) {
      final page = repository.pages[pageNumber - 1];
      for (var lineIndex = 0; lineIndex < page.lines.length; lineIndex++) {
        final parsed = ParsedLineCache.instance.tryGet(pageNumber, lineIndex);
        if (parsed == null) {
          throw StateError(
            'Missing pre-parsed QCF line: page $pageNumber, line $lineIndex',
          );
        }
        correctedLines[parsedLineKey(pageNumber, lineIndex)] = parsed.reversed
            .toList(growable: false);
      }
    }
    ParsedLineCache.instance.prefill(correctedLines);
  }

  @override
  Future<void> ensurePageFonts(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > totalPagesCount) {
      throw RangeError.range(pageNumber, 1, totalPagesCount, 'pageNumber');
    }

    final pagesToLoad = <int>[
      pageNumber,
      if (pageNumber < totalPagesCount) pageNumber + 1,
    ];

    // qcf_quran_plus defaults to permanentDisk and calls
    // getApplicationDocumentsDirectory(), which has no browser implementation.
    // The web loader extracts only the visible page fonts from package assets
    // and registers them in Flutter's in-memory font registry. Native targets
    // retain the package's persistent disk cache.
    final loadFont = _isWeb ? _webPageFontLoader : _nativePageFontLoader;
    await Future.wait(pagesToLoad.map(loadFont));
  }

  @override
  HafsPageStart? pageEnd(int pageNumber) {
    if (pageNumber < 1 || pageNumber > totalPagesCount) {
      return null;
    }

    final segments = getPageData(pageNumber);
    if (segments.isEmpty) {
      return null;
    }

    final last = segments.last;
    if (last is! Map) {
      return null;
    }

    final surah = int.tryParse('${last['surah']}');
    final ayah = int.tryParse('${last['end']}');
    if (surah == null || ayah == null) {
      return null;
    }

    return HafsPageStart(surahNumber: surah, ayahNumber: ayah);
  }

  @override
  int? pageForAyah(int surahNumber, int ayahNumber) {
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) {
      return null;
    }

    try {
      final page = getPageNumber(surahNumber, ayahNumber);
      return page >= 1 && page <= totalPagesCount ? page : null;
    } on Object {
      return null;
    }
  }

  @override
  int firstVisiblePage(int pageNumber, {required bool twoPageLayout}) {
    if (pageNumber < 1 || pageNumber > totalPagesCount) {
      throw RangeError.range(pageNumber, 1, totalPagesCount, 'pageNumber');
    }
    return twoPageLayout && pageNumber.isEven ? pageNumber - 1 : pageNumber;
  }

  @override
  HafsPageStart? pageStart(int pageNumber) {
    if (pageNumber < 1 || pageNumber > totalPagesCount) {
      return null;
    }

    final segments = getPageData(pageNumber);
    if (segments.isEmpty) {
      return null;
    }

    final first = segments.first;
    if (first is! Map) {
      return null;
    }

    final surah = int.tryParse('${first['surah']}');
    final ayah = int.tryParse('${first['start']}');
    if (surah == null || ayah == null) {
      return null;
    }

    return HafsPageStart(surahNumber: surah, ayahNumber: ayah);
  }
}

final hafsRendererAdapterProvider = Provider<HafsRendererAdapter>(
  (ref) => QcfQuranPlusHafsRendererAdapter(),
);
