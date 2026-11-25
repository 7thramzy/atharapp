import 'package:athaar/features/quran/data/hafs_page_font_loader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

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
  /// This is intentionally page-scoped. Browsers use an in-memory loader
  /// because qcf_quran_plus does not register a path_provider web plugin.
  Future<void> ensurePageFonts(int pageNumber);

  /// Returns the first page of the currently visible spread.
  /// A two-page spread is anchored on an odd page (1-2, 3-4, ...).
  int firstVisiblePage(int pageNumber, {required bool twoPageLayout});

  /// Returns the first surah/ayah on a one-based QCF Mushaf page.
  HafsPageStart? pageStart(int pageNumber);

  /// Resolves a stored surah/ayah pair to its one-based Mushaf page.
  int? pageForAyah(int surahNumber, int ayahNumber);
}

/// QCF 604-page Hafs implementation, pinned to qcf_quran_plus 0.1.1.
class QcfQuranPlusHafsRendererAdapter implements HafsRendererAdapter {
  Future<void>? _initialization;

  @override
  Future<void> initialize() {
    return _initialization ??= QuranRepository.instance.ensureLoaded(
      totalPagesCount,
    );
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

    if (kIsWeb) {
      await Future.wait(pagesToLoad.map(HafsPageFontLoader.ensurePageLoaded));
      return;
    }

    await Future.wait(pagesToLoad.map(QcfFontLoader.ensureFontLoaded));
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
