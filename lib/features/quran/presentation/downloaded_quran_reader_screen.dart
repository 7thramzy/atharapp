import 'dart:async';

import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:athaar/features/quran/data/quran_reader_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class DownloadedQuranReaderScreen extends ConsumerStatefulWidget {
  const DownloadedQuranReaderScreen({
    required this.surahNumber,
    this.initialAyahNumber = 1,
    super.key,
  });

  final int surahNumber;
  final int initialAyahNumber;

  @override
  ConsumerState<DownloadedQuranReaderScreen> createState() =>
      _DownloadedQuranReaderScreenState();
}

class _DownloadedQuranReaderScreenState
    extends ConsumerState<DownloadedQuranReaderScreen> {
  final GlobalKey _activeAyahKey = GlobalKey();

  bool _loading = true;
  String? _error;
  String _surahName = '';
  int _currentAyah = 1;
  List<Map<String, Object?>> _verses = const [];
  Map<String, Object?>? _sourceManifest;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final store = ref.read(athaarFeatureStoreProvider);
      final surahs = await store.listSurahs();
      final matchingSurahs = surahs.where(
        (row) => row['number'] == widget.surahNumber,
      );
      if (matchingSurahs.isEmpty) {
        throw StateError(
          'The selected surah is not available in the local Quran dataset.',
        );
      }

      final verses = await store.getSurahAyahs(widget.surahNumber);
      if (verses.isEmpty) {
        throw StateError('No downloaded ayahs were found for this surah.');
      }

      final safeAyah = widget.initialAyahNumber.clamp(1, verses.length).toInt();
      final manifest = await store.quranManifest;

      await store.saveReadingPosition(
        widget.surahNumber,
        safeAyah,
        readingMode: 'downloaded_text',
      );

      if (!mounted) return;
      setState(() {
        _surahName = matchingSurahs.first['name'] as String? ?? '';
        _verses = verses;
        _currentAyah = safeAyah;
        _sourceManifest = manifest;
        _loading = false;
      });
      _scrollToCurrentAyah();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  static const _basmalaText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  String? get _standaloneBasmala {
    // Al-Fatihah contains the basmala as its first numbered ayah, while
    // At-Tawbah has no opening basmala. Other surahs may have it prefixed
    // in the imported Tanzil row; expose it as a separate presentation line.
    if (widget.surahNumber == 1 || widget.surahNumber == 9 || _verses.isEmpty) {
      return null;
    }
    final first = _verses.first;
    if (first['number'] != 1) return null;
    final text = first['text'] as String? ?? '';
    if (!text.startsWith(_basmalaText)) return null;
    return _basmalaText;
  }

  String _displayAyahText(Map<String, Object?> verse) {
    final text = verse['text'] as String? ?? '';
    if (verse['number'] == 1 && _standaloneBasmala != null) {
      final remainder = text.substring(_basmalaText.length).trimLeft();
      return remainder;
    }
    return text;
  }

  void _scrollToCurrentAyah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _activeAyahKey.currentContext;
      if (targetContext == null || !mounted) return;
      unawaited(
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.16,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  Future<void> _setCurrentAyah(int ayahNumber) async {
    setState(() => _currentAyah = ayahNumber);
    await ref
        .read(athaarFeatureStoreProvider)
        .saveReadingPosition(
          widget.surahNumber,
          ayahNumber,
          readingMode: 'downloaded_text',
        );
    if (mounted) _scrollToCurrentAyah();
  }

  Future<void> _openHafsMushaf() async {
    await ref
        .read(athaarFeatureStoreProvider)
        .saveReadingPosition(
          widget.surahNumber,
          _currentAyah,
          readingMode: 'downloaded_text',
        );
    if (!mounted) return;
    await context.push<void>(
      QuranReaderRoutes.hafsMushaf(
        surahNumber: widget.surahNumber,
        ayahNumber: _currentAyah,
      ),
    );
  }

  Future<void> _openAyahStudy(int ayahNumber) async {
    await _setCurrentAyah(ayahNumber);
    if (!mounted) return;
    await context.push<void>('/quran/study/${widget.surahNumber}/$ayahNumber');
  }

  Future<void> _bookmark(int ayahNumber) async {
    await ref
        .read(athaarFeatureStoreProvider)
        .addBookmark(widget.surahNumber, ayahNumber);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ علامة الآية في أثَر')));
  }

  Future<void> _addNote(int ayahNumber) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ملاحظة خاصة'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'اكتب ملاحظتك حول الآية'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (note == null || note.trim().isEmpty) return;
    await ref
        .read(athaarFeatureStoreProvider)
        .saveNote(widget.surahNumber, ayahNumber, note.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم حفظ الملاحظة محليًا')));
  }

  @override
  Widget build(BuildContext context) {
    final edition = _sourceManifest?['edition'] as String? ?? 'Uthmani';
    final version = _sourceManifest?['version'] as String? ?? '1.1';

    return Scaffold(
      appBar: AppBar(
        title: Text(_surahName.isEmpty ? 'القراءة النصية' : _surahName),
        actions: [
          IconButton(
            tooltip: 'المصحف المعتمد — حفص عن عاصم',
            onPressed: _loading || _error != null ? null : _openHafsMushaf,
            icon: const Icon(Icons.menu_book_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectableText(_error!, textAlign: TextAlign.center),
              ),
            )
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.download_done_rounded),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'النص المحلي — Tanzil $edition $version',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            const Chip(
                              avatar: Icon(Icons.menu_book_outlined, size: 16),
                              label: Text('وضع مساعد'),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'المصحف المعتمد داخل أثَر هو مصحف حفص عن عاصم. يمكنك الانتقال إليه في الموضع نفسه من زر المصحف بالأعلى.',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _openHafsMushaf,
                                icon: const Icon(Icons.verified_outlined),
                                label: const Text('فتح مصحف حفص المعتمد'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              tooltip: 'تفسير وترجمة الآية',
                              onPressed: () => _openAyahStudy(_currentAyah),
                              icon: const Icon(Icons.menu_book_outlined),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    children: [
                      if (_standaloneBasmala != null)
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            child: Text(
                              _standaloneBasmala!,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(height: 2),
                            ),
                          ),
                        ),
                      ..._verses.map((verse) {
                        final number = verse['number'] as int;
                        final isCurrent = number == _currentAyah;
                        return Card(
                          key: isCurrent ? _activeAyahKey : null,
                          color: isCurrent
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : null,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              unawaited(_setCurrentAyah(number));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text('آية $number'),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      const Spacer(),
                                      if (isCurrent)
                                        const Text(
                                          'موضع القراءة',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _displayAyahText(verse),
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.justify,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(height: 2),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        tooltip: 'دراسة الآية',
                                        onPressed: () => _openAyahStudy(number),
                                        icon: const Icon(
                                          Icons.menu_book_outlined,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'إضافة ملاحظة',
                                        onPressed: () => _addNote(number),
                                        icon: const Icon(
                                          Icons.note_add_outlined,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'حفظ علامة',
                                        onPressed: () => _bookmark(number),
                                        icon: const Icon(
                                          Icons.bookmark_add_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
