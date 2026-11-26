import 'dart:async';

import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:athaar/features/quran_study/data/quran_study_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

String _studyText(BuildContext context, String ar, String en) =>
    Localizations.localeOf(context).languageCode == 'ar' ? ar : en;

class QuranStudyScreen extends ConsumerStatefulWidget {
  const QuranStudyScreen({
    required this.surahNumber,
    required this.ayahNumber,
    super.key,
  });

  final int surahNumber;
  final int ayahNumber;

  @override
  ConsumerState<QuranStudyScreen> createState() => _QuranStudyScreenState();
}

class _QuranStudyScreenState extends ConsumerState<QuranStudyScreen> {
  late final AudioPlayer _audioPlayer;

  bool _loadingAyah = true;
  bool _loadingTafsir = true;
  bool _loadingTranslations = true;
  bool _loadingTranslation = false;
  bool _loadingReciters = true;
  bool _loadingAudio = false;

  String? _ayahError;
  String? _tafsirError;
  String? _translationsError;
  String? _translationError;
  String? _recitersError;
  String? _audioError;

  String _surahName = '';
  String _ayahText = '';
  List<QuranTranslationEdition> _translations = const [];
  List<QuranAudioEdition> _reciters = const [];
  QuranTranslationEdition? _selectedTranslation;
  QuranAudioEdition? _selectedReciter;
  String? _loadedReciterIdentifier;
  QuranTranslationText? _translation;
  QuranTafsirText? _tafsir;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    unawaited(_loadLocalAyah());
    unawaited(_loadTafsir());
    unawaited(_loadTranslationCatalog());
    unawaited(_loadReciterCatalog());
  }

  @override
  void dispose() {
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  Future<void> _loadLocalAyah() async {
    try {
      final store = ref.read(athaarFeatureStoreProvider);
      final surahs = await store.listSurahs();
      final verses = await store.getSurahAyahs(widget.surahNumber);
      final matchingSurah = surahs.where(
        (item) => item['number'] == widget.surahNumber,
      );
      final matchingAyah = verses.where(
        (item) => item['number'] == widget.ayahNumber,
      );

      if (matchingAyah.isEmpty) {
        throw StateError(
          'The selected ayah is not present in the local Quran dataset.',
        );
      }
      if (!mounted) return;
      setState(() {
        _surahName = matchingSurah.isEmpty
            ? 'السورة ${widget.surahNumber}'
            : matchingSurah.first['name'] as String? ?? '';
        _ayahText = matchingAyah.first['text'] as String? ?? '';
        _loadingAyah = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _ayahError = error.toString();
        _loadingAyah = false;
      });
    }
  }

  Future<void> _loadTafsir() async {
    try {
      final text = await ref
          .read(quranStudyRepositoryProvider)
          .getTafsir(surah: widget.surahNumber, ayah: widget.ayahNumber);
      if (!mounted) return;
      setState(() {
        _tafsir = text;
        _loadingTafsir = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _tafsirError = error.toString();
        _loadingTafsir = false;
      });
    }
  }

  Future<void> _loadTranslationCatalog() async {
    try {
      final items = await ref
          .read(quranStudyRepositoryProvider)
          .getTranslations(localization: 'ar');
      final preferred = items.where((item) => item.key == 'english_rwwad');
      final english = items.where((item) => item.languageCode == 'en');
      final selected = preferred.isNotEmpty
          ? preferred.first
          : english.isNotEmpty
          ? english.first
          : items.isNotEmpty
          ? items.first
          : null;
      if (!mounted) return;
      setState(() {
        _translations = items;
        _selectedTranslation = selected;
        _loadingTranslations = false;
      });
      if (selected != null) {
        unawaited(_loadTranslation(selected));
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _translationsError = error.toString();
        _loadingTranslations = false;
      });
    }
  }

  Future<void> _loadTranslation(QuranTranslationEdition edition) async {
    setState(() {
      _loadingTranslation = true;
      _translationError = null;
      _translation = null;
    });
    try {
      final text = await ref
          .read(quranStudyRepositoryProvider)
          .getTranslation(
            key: edition.key,
            surah: widget.surahNumber,
            ayah: widget.ayahNumber,
          );
      if (!mounted) return;
      setState(() {
        _translation = text;
        _loadingTranslation = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _translationError = error.toString();
        _loadingTranslation = false;
      });
    }
  }

  Future<void> _loadReciterCatalog() async {
    try {
      final items = await ref
          .read(quranStudyRepositoryProvider)
          .getAudioEditions();
      final preferred = items.where((item) => item.identifier == 'ar.husary');
      final selected = preferred.isNotEmpty
          ? preferred.first
          : items.isNotEmpty
          ? items.first
          : null;
      if (!mounted) return;
      setState(() {
        _reciters = items;
        _selectedReciter = selected;
        _loadingReciters = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _recitersError = error.toString();
        _loadingReciters = false;
      });
    }
  }

  Future<void> _playAyah() async {
    final reciter = _selectedReciter;
    if (reciter == null) return;

    setState(() {
      _loadingAudio = true;
      _audioError = null;
    });

    try {
      final uri = await ref
          .read(quranStudyRepositoryProvider)
          .getAyahAudioUri(
            surah: widget.surahNumber,
            ayah: widget.ayahNumber,
            edition: reciter.identifier,
          );
      await _audioPlayer.setUrl(uri.toString());
      _loadedReciterIdentifier = reciter.identifier;
      if (!mounted) return;
      setState(() => _loadingAudio = false);
      unawaited(_audioPlayer.play());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _audioError = error.toString();
        _loadingAudio = false;
      });
    }
  }

  Future<void> _openSource(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _studyText(
              context,
              'تعذّر فتح المصدر الخارجي.',
              'Unable to open the external source.',
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTafsirTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_loadingTafsir)
          const Center(child: CircularProgressIndicator())
        else if (_tafsirError != null)
          _InfoError(message: _tafsirError!)
        else if (_tafsir == null)
          _InfoCard(
            message: _studyText(
              context,
              'لا يتوفر نص تفسير لهذا الموضع في الإصدار المحدد.',
              'No tafsir text is available for this ayah in the pinned edition.',
            ),
          )
        else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SelectableText(
                _tafsir!.text,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(height: 1.95, fontSize: 16),
              ),
            ),
          ),
          _SourceAttribution(
            title: 'الجامع الوجيز في تفسير آي الكتاب العزيز',
            description: _studyText(
              context,
              'تأليف الشيخ الدكتور أيمن فاتح آل عامر',
              'Authored by Sheikh Dr. Ayman Fathih Al-Amer',
            ),
            version: 'v1.2.3 · CC BY-ND 4.0',
            onOpen: () => _openSource(
              Uri.https(
                'github.com',
                '/yamanamr/quran-tafsir-jami-wajiz/blob/main/LICENSE',
              ),
            ),
            extraNote: _studyText(
              context,
              'يُعرض نص التفسير كما ورد من المصدر دون تعديل. الرخصة تسمح بإعادة التوزيع مع نسب المؤلف ورابط الرخصة، ولا تسمح بتوزيع نص معدل.',
              'The publisher text is displayed verbatim. CC BY-ND 4.0 permits redistribution with attribution and a licence link, but not distribution of modified text.',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTranslationTab(BuildContext context) {
    final selected = _selectedTranslation;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_loadingTranslations)
          const LinearProgressIndicator()
        else if (_translationsError != null)
          _InfoError(message: _translationsError!)
        else if (_translations.isEmpty)
          _InfoCard(
            message: _studyText(
              context,
              'لم تصل قائمة الترجمات من المصدر.',
              'The translation catalogue is unavailable.',
            ),
          )
        else
          DropdownButtonFormField<QuranTranslationEdition>(
            initialValue: selected,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: _studyText(
                context,
                'اختر ترجمة المعاني',
                'Choose a translation of the meanings',
              ),
              border: const OutlineInputBorder(),
            ),
            items: _translations
                .map(
                  (item) => DropdownMenuItem<QuranTranslationEdition>(
                    value: item,
                    child: Text(item.title, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (item) {
              if (item == null) return;
              setState(() => _selectedTranslation = item);
              unawaited(_loadTranslation(item));
            },
          ),
        const SizedBox(height: 12),
        if (_loadingTranslation)
          const Center(child: CircularProgressIndicator())
        else if (_translationError != null)
          _InfoError(message: _translationError!)
        else if (_translation == null)
          _InfoCard(
            message: _studyText(
              context,
              'اختر ترجمة متاحة لعرض معنى الآية.',
              'Choose an available translation to view the meaning of this ayah.',
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SelectableText(
                _translation!.text,
                textDirection: selected?.direction == 'rtl'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(height: 1.8, fontSize: 16),
              ),
            ),
          ),
        if (_translation?.footnotes.isNotEmpty == true)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _translation!.footnotes,
                textDirection: selected?.direction == 'rtl'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(height: 1.6),
              ),
            ),
          ),
        if (_translation != null && selected != null)
          _SourceAttribution(
            title: selected.title,
            description: selected.description,
            version: selected.version,
            onOpen: () =>
                _openSource(Uri.https('quranenc.com', '/ar/home/api')),
          ),
      ],
    );
  }

  Widget _buildRecitationTab(BuildContext context) {
    final selected = _selectedReciter;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_loadingReciters)
          const LinearProgressIndicator()
        else if (_recitersError != null)
          _InfoError(message: _recitersError!)
        else if (_reciters.isEmpty)
          _InfoCard(
            message: _studyText(
              context,
              'قائمة القرّاء غير متاحة حاليًا.',
              'The reciter catalogue is unavailable.',
            ),
          )
        else
          DropdownButtonFormField<QuranAudioEdition>(
            initialValue: selected,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: _studyText(context, 'اختر القارئ', 'Choose a reciter'),
              border: const OutlineInputBorder(),
            ),
            items: _reciters
                .map(
                  (item) => DropdownMenuItem<QuranAudioEdition>(
                    value: item,
                    child: Text(
                      item.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (item) {
              if (item == null) return;
              setState(() {
                _selectedReciter = item;
                _loadedReciterIdentifier = null;
                _audioError = null;
              });
              unawaited(_audioPlayer.stop());
            },
          ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(Icons.graphic_eq_rounded, size: 42),
                const SizedBox(height: 8),
                Text(
                  selected?.displayName ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  _studyText(
                    context,
                    'بث مباشر للآية المحددة',
                    'Stream the selected ayah',
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final playing = state?.playing ?? false;
                    final completed =
                        state?.processingState == ProcessingState.completed;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          tooltip: playing
                              ? _studyText(context, 'إيقاف مؤقت', 'Pause')
                              : _studyText(context, 'تشغيل', 'Play'),
                          onPressed: _loadingAudio || selected == null
                              ? null
                              : playing
                              ? _audioPlayer.pause
                              : completed ||
                                    _loadedReciterIdentifier !=
                                        selected.identifier
                              ? _playAyah
                              : _audioPlayer.play,
                          icon: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: _studyText(context, 'إيقاف', 'Stop'),
                          onPressed: _audioPlayer.stop,
                          icon: const Icon(Icons.stop_rounded),
                        ),
                        if (_loadingAudio)
                          const Padding(
                            padding: EdgeInsetsDirectional.only(start: 10),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                StreamBuilder<Duration?>(
                  stream: _audioPlayer.durationStream,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration>(
                      stream: _audioPlayer.positionStream,
                      builder: (context, positionSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;
                        final max = duration.inMilliseconds.toDouble();
                        final value = max <= 0
                            ? 0.0
                            : position.inMilliseconds
                                  .toDouble()
                                  .clamp(0.0, max)
                                  .toDouble();
                        return Column(
                          children: [
                            Slider(
                              min: 0,
                              max: max <= 0 ? 1 : max,
                              value: value,
                              onChanged: max <= 0
                                  ? null
                                  : (next) => _audioPlayer.seek(
                                      Duration(milliseconds: next.round()),
                                    ),
                            ),
                            Text(
                              '${_formatDuration(position)} / ${_formatDuration(duration)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                if (_audioError != null) ...[
                  const SizedBox(height: 8),
                  _InfoError(message: _audioError!),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _SourceAttribution(
          title: 'AlQuran Cloud / Islamic Network',
          description: _studyText(context, 'تلاوة قرآنية', 'Quran recitation'),
          version: 'API v1 · ${selected?.identifier ?? '—'}',
          onOpen: () =>
              _openSource(Uri.https('alquran.cloud', '/terms-and-conditions')),
          extraNote: _studyText(
            context,
            'تشغيل مباشر بطلب المستخدم فقط. لا تنزيل، ولا تخزين دائم أو إعادة استضافة أو إدراج ملفات الصوت داخل التطبيق. حقوق كل تسجيل تعود للقارئ أو صاحب التسجيل، ويجب تعطيل المورد إذا سُحبت إتاحته.',
            'User-initiated streaming only. No download, permanent cache, re-hosting, or bundled audio. Each recording remains the property of its reciter or rights holder and must be disabled if withdrawn.',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_studyText(context, 'دراسة الآية', 'Study this ayah')),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.menu_book_outlined),
                text: _studyText(context, 'التفسير', 'Tafsir'),
              ),
              Tab(
                icon: const Icon(Icons.translate_rounded),
                text: _studyText(context, 'الترجمة', 'Translation'),
              ),
              Tab(
                icon: const Icon(Icons.headphones_rounded),
                text: _studyText(context, 'التلاوة', 'Recitation'),
              ),
            ],
          ),
        ),
        body: _loadingAyah
            ? const Center(child: CircularProgressIndicator())
            : _ayahError != null
            ? _InfoError(message: _ayahError!)
            : Column(
                children: [
                  Card(
                    margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '$_surahName · ${widget.surahNumber}:${widget.ayahNumber}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 10),
                          SelectableText(
                            _ayahText,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(height: 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTafsirTab(context),
                        _buildTranslationTab(context),
                        _buildRecitationTab(context),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SourceAttribution extends StatelessWidget {
  const _SourceAttribution({
    required this.title,
    required this.description,
    required this.version,
    required this.onOpen,
    this.extraNote,
  });

  final String title;
  final String description;
  final String version;
  final VoidCallback onOpen;
  final String? extraNote;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _studyText(
                context,
                'المصدر وحقوق المحتوى',
                'Source and content rights',
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(title),
            if (description.isNotEmpty) Text(description),
            if (version.isNotEmpty) Text('Version: $version'),
            if (extraNote != null) ...[
              const SizedBox(height: 6),
              Text(extraNote!, style: Theme.of(context).textTheme.bodySmall),
            ],
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(_studyText(context, 'صفحة المصدر', 'Source page')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoError extends StatelessWidget {
  const _InfoError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SelectableText(message),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

String _formatDuration(Duration value) {
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
