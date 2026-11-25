import 'dart:async';

import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:athaar/features/quran/data/qcf_hafs_renderer_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:go_router/go_router.dart';

class HafsMushafScreen extends ConsumerStatefulWidget {
  const HafsMushafScreen({super.key});

  @override
  ConsumerState<HafsMushafScreen> createState() => _HafsMushafScreenState();
}

class _HafsMushafScreenState extends ConsumerState<HafsMushafScreen> {
  static const _totalPages = 604;

  PageController? _pageController;
  int _currentPage = 1;
  int _loadGeneration = 0;
  bool _initializing = true;
  bool _loadingPage = false;
  bool _tajweedEnabled = true;
  bool _twoPageLayoutEnabled = true;
  bool _isWide = false;
  String? _error;
  _SelectedAyah? _selectedAyah;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isWide = MediaQuery.sizeOf(context).width >= 750;
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final adapter = ref.read(hafsRendererAdapterProvider);
      await adapter.initialize();

      final savedPosition = await ref
          .read(athaarFeatureStoreProvider)
          .getReadingPosition();
      final restoredPage = savedPosition == null
          ? 1
          : adapter.pageForAyah(
                  savedPosition.surahNumber,
                  savedPosition.ayahNumber,
                ) ??
                1;

      final useTwoPageLayout = _isWide && _twoPageLayoutEnabled;
      final fontPage = adapter.firstVisiblePage(
        restoredPage,
        twoPageLayout: useTwoPageLayout,
      );
      await adapter.ensurePageFonts(fontPage);
      if (!mounted) return;
      _currentPage = restoredPage;
      _pageController = PageController(initialPage: restoredPage - 1);
      setState(() => _initializing = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = error.toString();
      });
    }
  }

  void _onPageChanged(int pageNumber) {
    if (pageNumber < 1 || pageNumber > _totalPages) return;
    if (pageNumber == _currentPage && !_loadingPage) return;
    unawaited(_loadPage(pageNumber));
  }

  Future<void> _loadPage(int pageNumber) async {
    final generation = ++_loadGeneration;
    setState(() {
      _currentPage = pageNumber;
      _selectedAyah = null;
      _loadingPage = true;
      _error = null;
    });

    try {
      final adapter = ref.read(hafsRendererAdapterProvider);
      final useTwoPageLayout = _isWide && _twoPageLayoutEnabled;
      final fontPage = adapter.firstVisiblePage(
        pageNumber,
        twoPageLayout: useTwoPageLayout,
      );
      await adapter.ensurePageFonts(fontPage);
      if (!mounted || generation != _loadGeneration) return;

      final start = adapter.pageStart(pageNumber);
      if (start != null) {
        await ref
            .read(athaarFeatureStoreProvider)
            .saveReadingPosition(start.surahNumber, start.ayahNumber);
      }
    } catch (error) {
      if (mounted && generation == _loadGeneration) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _loadingPage = false);
      }
    }
  }

  void _onWordTap(
    int surahNumber,
    int ayahNumber,
    int wordIndex,
    String rawWord,
  ) {
    setState(() {
      _selectedAyah = _SelectedAyah(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        wordIndex: wordIndex,
        word: rawWord,
      );
    });
  }

  void _onVerseTap(int surahNumber, int ayahNumber) {
    setState(() {
      _selectedAyah = _SelectedAyah(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      );
    });
  }

  void _clearSelection() {
    setState(() => _selectedAyah = null);
  }

  Future<void> _bookmarkSelectedAyah() async {
    final selected = _selectedAyah;
    if (selected == null) return;

    await ref
        .read(athaarFeatureStoreProvider)
        .addBookmark(selected.surahNumber, selected.ayahNumber);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ علامة الآية في أثَر')));
  }

  Future<void> _askForPage() async {
    final controller = TextEditingController(text: '$_currentPage');
    final requestedPage = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('الانتقال إلى صفحة'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'رقم الصفحة من 1 إلى 604',
          ),
          onSubmitted: (value) =>
              Navigator.of(dialogContext).pop(int.tryParse(value)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(int.tryParse(controller.text)),
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (!mounted || requestedPage == null) return;
    if (requestedPage < 1 || requestedPage > _totalPages) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رقم الصفحة خارج النطاق')));
      return;
    }

    final pageController = _pageController;
    if (pageController == null) return;
    await pageController.animateToPage(
      requestedPage - 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _movePage(int direction, {required bool wide}) async {
    final step = wide && _twoPageLayoutEnabled ? 2 : 1;
    final targetIndex = (_currentPage - 1 + direction * step)
        .clamp(0, _totalPages - 1)
        .toInt();
    final controller = _pageController;
    if (controller == null || !controller.hasClients) return;

    await controller.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width >= 750;
    final wordHighlights = _selectedAyah?.wordIndex == null
        ? const <WordHighlight>[]
        : [
            WordHighlight(
              surah: _selectedAyah!.surahNumber,
              verseNumber: _selectedAyah!.ayahNumber,
              wordIndex: _selectedAyah!.wordIndex!,
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المصحف الشريف — حفص'),
        actions: [
          IconButton(
            tooltip: 'الانتقال إلى صفحة',
            onPressed: _initializing || _error != null ? null : _askForPage,
            icon: const Icon(Icons.find_in_page_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: _initializing
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري تجهيز بيانات المصحف وخط الصفحة الأولى...'),
                  ],
                ),
              )
            : _error != null && _currentPage == 1
            ? _ErrorState(message: _error!)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilterChip(
                          selected: _tajweedEnabled,
                          avatar: const Icon(Icons.palette_outlined, size: 18),
                          label: const Text('التجويد الملوّن'),
                          onSelected: (value) {
                            setState(() => _tajweedEnabled = value);
                          },
                        ),
                        if (isWide)
                          FilterChip(
                            selected: _twoPageLayoutEnabled,
                            avatar: const Icon(
                              Icons.menu_book_outlined,
                              size: 18,
                            ),
                            label: const Text('عرض صفحتين'),
                            onSelected: (value) {
                              setState(() => _twoPageLayoutEnabled = value);
                              if (value) {
                                unawaited(_loadPage(_currentPage));
                              }
                            },
                          ),
                        Chip(
                          avatar: const Icon(
                            Icons.auto_stories_outlined,
                            size: 18,
                          ),
                          label: Text('صفحة $_currentPage / $_totalPages'),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedAyah != null)
                    _SelectedAyahPanel(
                      selection: _selectedAyah!,
                      onBookmark: _bookmarkSelectedAyah,
                      onStudy: () => context.push<void>(
                        '/quran/study/${_selectedAyah!.surahNumber}/${_selectedAyah!.ayahNumber}',
                      ),
                      onClear: _clearSelection,
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: QuranPageView(
                            pageController: _pageController!,
                            highlights: const [],
                            wordHighlights: wordHighlights,
                            onWordTap: _onWordTap,
                            onLongPress: (surahNumber, ayahNumber, details) =>
                                _onVerseTap(surahNumber, ayahNumber),
                            onPageChanged: _onPageChanged,
                            isDarkMode: isDark,
                            isTajweed: _tajweedEnabled,
                            enableTwoPageLayout: _twoPageLayoutEnabled,
                            pageBackgroundColor: isDark
                                ? const Color(0xFF202529)
                                : const Color(0xFFFFFCF4),
                          ),
                        ),
                        if (_loadingPage)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                        if (_error != null)
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Material(
                              color: Theme.of(context)
                                  .colorScheme
                                  .errorContainer,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  'تعذّر تجهيز الخط لهذه الصفحة: $_error',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _PageNavigation(
                    currentPage: _currentPage,
                    onPrevious: () => _movePage(-1, wide: isWide),
                    onNext: () => _movePage(1, wide: isWide),
                    onSelectPage: _askForPage,
                  ),
                ],
              ),
      ),
    );
  }
}

class _SelectedAyahPanel extends StatelessWidget {
  const _SelectedAyahPanel({
    required this.selection,
    required this.onBookmark,
    required this.onStudy,
    required this.onClear,
  });

  final _SelectedAyah selection;
  final VoidCallback onBookmark;
  final VoidCallback onStudy;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final subtitle = selection.wordIndex == null
        ? 'السورة ${selection.surahNumber} · الآية ${selection.ayahNumber}'
        : 'السورة ${selection.surahNumber} · الآية ${selection.ayahNumber} · الكلمة ${selection.wordIndex! + 1}';

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 2, 12, 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selection.word != null)
                    Text(
                      selection.word!,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'التفسير والترجمة والتلاوة',
              onPressed: onStudy,
              icon: const Icon(Icons.menu_book_outlined),
            ),
            IconButton.filledTonal(
              tooltip: 'حفظ علامة للآية',
              onPressed: onBookmark,
              icon: const Icon(Icons.bookmark_add_outlined),
            ),
            IconButton(
              tooltip: 'إغلاق التحديد',
              onPressed: onClear,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageNavigation extends StatelessWidget {
  const _PageNavigation({
    required this.currentPage,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectPage,
  });

  final int currentPage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSelectPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'الصفحة السابقة',
            onPressed: currentPage > 1 ? onPrevious : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          Expanded(
            child: Center(
              child: TextButton(
                onPressed: onSelectPage,
                child: Text('صفحة $currentPage من 604'),
              ),
            ),
          ),
          IconButton(
            tooltip: 'الصفحة التالية',
            onPressed: currentPage < 604 ? onNext : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 36),
            const SizedBox(height: 12),
            const Text(
              'تعذّر تهيئة قارئ حفص',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedAyah {
  const _SelectedAyah({
    required this.surahNumber,
    required this.ayahNumber,
    this.wordIndex,
    this.word,
  });

  final int surahNumber;
  final int ayahNumber;
  final int? wordIndex;
  final String? word;
}
