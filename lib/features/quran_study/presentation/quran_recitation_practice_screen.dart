import 'dart:async';

import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:athaar/features/quran_study/data/quran_asr_model_manager.dart';
import 'package:athaar/features/quran_study/data/quran_offline_recognizer.dart';
import 'package:athaar/features/quran_study/data/quran_recitation_capture_session.dart';
import 'package:athaar/features/quran_study/domain/quran_recitation_aligner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class QuranRecitationPracticeScreen extends ConsumerStatefulWidget {
  const QuranRecitationPracticeScreen({
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
    super.key,
  });

  final int surahNumber;
  final int startAyah;
  final int endAyah;

  @override
  ConsumerState<QuranRecitationPracticeScreen> createState() =>
      _QuranRecitationPracticeScreenState();
}

class _QuranRecitationPracticeScreenState
    extends ConsumerState<QuranRecitationPracticeScreen> {
  late final QuranAsrModelManager _modelManager;

  QuranOfflineRecognizer? _recognizer;
  QuranRecitationCaptureSession? _capture;
  List<_AyahPracticeLine> _lines = const [];
  List<QuranExpectedWord> _expectedWords = const [];

  String _surahName = '';
  String? _error;
  String? _sessionError;
  bool _loading = true;
  bool _modelLoading = false;
  bool _modelReady = false;
  bool _recording = false;
  bool _saving = false;
  int _modelBytes = 0;
  int? _modelTotalBytes;
  int _confirmedWords = 0;
  QuranRecitationAlignment? _alignment;
  String _outcome = 'learning';

  @override
  void initState() {
    super.initState();
    _modelManager = QuranAsrModelManager();
    unawaited(_load());
  }

  @override
  void dispose() {
    final capture = _capture;
    if (capture != null) {
      unawaited(
        capture.stop().whenComplete(() {
          _recognizer?.dispose();
          _recognizer = null;
        }),
      );
    } else {
      _recognizer?.dispose();
    }
    _modelManager.close();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final store = ref.read(athaarFeatureStoreProvider);
      final surahs = await store.listSurahs();
      final matching = surahs.where(
        (row) => row['number'] == widget.surahNumber,
      );
      if (matching.isEmpty) {
        throw StateError('السورة غير موجودة في النص القرآني المحلي.');
      }
      final ayahCount = matching.first['ayah_count'] as int;
      if (widget.startAyah < 1 ||
          widget.endAyah < widget.startAyah ||
          widget.endAyah > ayahCount) {
        throw RangeError('نطاق الآيات المطلوب غير صحيح.');
      }

      final allVerses = await store.getSurahAyahs(widget.surahNumber);
      final selected = allVerses.where((verse) {
        final number = verse['number'] as int;
        return number >= widget.startAyah && number <= widget.endAyah;
      }).toList(growable: false);
      final expected = <QuranExpectedWord>[];
      final lines = <_AyahPracticeLine>[];

      for (final verse in selected) {
        final ayahNumber = verse['number']! as int;
        final text = verse['text']! as String;
        final tokens = text.trim().split(RegExp(r'\s+'));
        final startIndex = expected.length;
        for (var wordIndex = 0; wordIndex < tokens.length; wordIndex++) {
          if (tokens[wordIndex].isEmpty) continue;
          expected.add(
            QuranExpectedWord(
              surahNumber: widget.surahNumber,
              ayahNumber: ayahNumber,
              wordIndex: wordIndex + 1,
              text: tokens[wordIndex],
            ),
          );
        }
        lines.add(
          _AyahPracticeLine(
            ayahNumber: ayahNumber,
            text: text,
            startIndex: startIndex,
            endExclusive: expected.length,
          ),
        );
      }

      if (expected.isEmpty || lines.isEmpty) {
        throw StateError('لم يتم العثور على كلمات في نطاق الآيات المحدد.');
      }

      final installed = await _modelManager.installedModel();
      QuranOfflineRecognizer? recognizer;
      if (installed != null) {
        recognizer = await QuranOfflineRecognizer.fromInstalledModel(installed);
      }
      if (!mounted) {
        recognizer?.dispose();
        return;
      }
      setState(() {
        _surahName = matching.first['name'] as String? ?? '';
        _lines = lines;
        _expectedWords = expected;
        _recognizer = recognizer;
        _modelReady = recognizer != null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _downloadModel() async {
    if (_modelLoading || _modelReady) return;
    setState(() {
      _modelLoading = true;
      _modelBytes = 0;
      _modelTotalBytes = null;
      _error = null;
    });
    try {
      final files = await _modelManager.download(
        userRequested: true,
        onProgress: (received, expected) {
          if (!mounted) return;
          setState(() {
            _modelBytes = received;
            _modelTotalBytes = expected;
          });
        },
      );
      final recognizer = await QuranOfflineRecognizer.fromInstalledModel(files);
      if (!mounted) {
        recognizer.dispose();
        return;
      }
      setState(() {
        _recognizer = recognizer;
        _modelReady = true;
        _modelLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _modelLoading = false;
      });
    }
  }

  Future<void> _startRecording() async {
    final recognizer = _recognizer;
    if (recognizer == null || _recording || _saving) return;

    final capture = QuranRecitationCaptureSession(
      recognizer: recognizer,
      expectedWords: _expectedWords,
    );
    setState(() {
      _sessionError = null;
      _alignment = null;
      _confirmedWords = 0;
      _recording = true;
    });
    _capture = capture;

    try {
      await capture.start(
        onProgress: (recognition, alignment) {
          if (!mounted) return;
          setState(() {
            _alignment = alignment;
            if (alignment.confirmedThroughExclusive > _confirmedWords) {
              _confirmedWords = alignment.confirmedThroughExclusive;
            }
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() => _sessionError = error.toString());
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sessionError = error.toString();
        _recording = false;
      });
      _capture = null;
      await capture.stop();
    }
  }

  Future<void> _stopRecording() async {
    final capture = _capture;
    if (capture == null) return;
    await capture.stop();
    _capture = null;
    if (mounted) setState(() => _recording = false);
  }

  int get _completedAyahCount {
    return _lines
        .where((line) => line.endExclusive <= _confirmedWords)
        .length;
  }

  Future<void> _saveProgress() async {
    if (_saving || _completedAyahCount == 0) return;
    final completedLines = _lines
        .where((line) => line.endExclusive <= _confirmedWords)
        .toList(growable: false);
    if (completedLines.isEmpty) return;
    setState(() => _saving = true);
    try {
      await _stopRecording();
      await ref.read(athaarFeatureStoreProvider).recordMemorizationSession(
            surah: widget.surahNumber,
            startAyah: completedLines.first.ayahNumber,
            endAyah: completedLines.last.ayahNumber,
            outcome: _outcome,
            notes: 'حفظ محلي بمساعدة التعرف الصوتي؛ التقييم النهائي اختاره المستخدم.',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الآيات المكتملة في تقدم الحفظ المحلي.'),
        ),
      );
      setState(() {
        _confirmedWords = 0;
        _alignment = null;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sessionError = error.toString();
        _saving = false;
      });
    }
  }

  bool _sameWord(QuranExpectedWord? left, QuranExpectedWord right) {
    return left != null &&
        left.surahNumber == right.surahNumber &&
        left.ayahNumber == right.ayahNumber &&
        left.wordIndex == right.wordIndex;
  }

  int? get _activeWordIndex {
    final active = _alignment?.activeExpectedWord;
    if (active != null) {
      for (var index = 0; index < _expectedWords.length; index++) {
        if (_sameWord(active, _expectedWords[index])) return index;
      }
    }
    if (_confirmedWords < _expectedWords.length) return _confirmedWords;
    return null;
  }

  Widget _buildAyahLine(_AyahPracticeLine line) {
    final activeIndex = _activeWordIndex;
    final isActiveAyah = activeIndex != null &&
        activeIndex >= line.startIndex &&
        activeIndex < line.endExclusive;
    final isCompleted = line.endExclusive <= _confirmedWords;

    final words = <Widget>[];
    for (var index = line.startIndex; index < line.endExclusive; index++) {
      final word = _expectedWords[index];
      final isConfirmed = index < _confirmedWords;
      final isActive = index == activeIndex;
      final isUncertain = isActive &&
          _alignment?.state == QuranRecitationMatchState.uncertain;
      final opacity = isConfirmed || isActive ? 1.0 : 0.25;
      final color = isUncertain
          ? Theme.of(context).colorScheme.errorContainer
          : isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : null;
      words.add(
        Opacity(
          opacity: opacity,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: isUncertain
                  ? Border.all(color: Theme.of(context).colorScheme.error)
                  : null,
            ),
            child: Text(
              word.text,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    height: 2.0,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
        ),
      );
    }

    return Card(
      color: isActiveAyah
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Chip(
                  label: Text('آية ${line.ayahNumber}'),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                if (isCompleted)
                  const Icon(Icons.check_circle_outline_rounded, size: 19)
                else if (isActiveAyah)
                  const Text(
                    'تُقرأ الآن',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: words,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _statusText {
    switch (_alignment?.state) {
      case QuranRecitationMatchState.matched:
        return 'تمت مطابقة كلمات متتابعة.';
      case QuranRecitationMatchState.uncertain:
        return 'لم تتضح الكلمة التالية. أعدها بهدوء أو راجعها بنفسك.';
      case QuranRecitationMatchState.complete:
        return 'اكتمل نطاق الآيات المحدد.';
      case QuranRecitationMatchState.noSpeech:
      case null:
        return _recording
            ? 'استمع الآن إلى التلاوة من الميكروفون المحلي…'
            : 'ابدأ التسميع بعد تجهيز النموذج.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('التسميع المحلي')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null && _lines.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('التسميع المحلي')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final progress = _expectedWords.isEmpty
        ? 0.0
        : _confirmedWords / _expectedWords.length;

    return Scaffold(
      appBar: AppBar(title: const Text('التسميع المحلي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '$_surahName · ${widget.surahNumber} · الآيات ${widget.startAyah}–${widget.endAyah}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'التعرف يعمل داخل الهاتف. لا يتم رفع صوتك أو حفظ التسجيل. الكلمات التي لم تتأكد مطابقتها تبقى باهتة.',
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 12),
                  if (!_modelReady) ...[
                    const Text(
                      'يلزم تنزيل نموذج التعرف مرة واحدة. حجمه نحو 36 ميغابايت، وسيُحفظ خارج ملف تثبيت التطبيق.',
                    ),
                    const SizedBox(height: 8),
                    if (_modelLoading && _modelTotalBytes != null)
                      LinearProgressIndicator(
                        value: _modelTotalBytes! <= 0
                            ? null
                            : _modelBytes / _modelTotalBytes!,
                      )
                    else if (_modelLoading)
                      const LinearProgressIndicator(),
                    OutlinedButton.icon(
                      onPressed: _modelLoading ? null : _downloadModel,
                      icon: _modelLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_for_offline_outlined),
                      label: Text(
                        _modelLoading
                            ? 'تنزيل النموذج… ${(_modelBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
                            : 'تنزيل نموذج التسميع المحلي',
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('نموذج التعرف المحلي جاهز')),
                        Text(
                          '${(_confirmedWords / _expectedWords.length * 100).round()}%',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
                    const SizedBox(height: 10),
                    Text(_statusText),
                    if (_alignment?.state == QuranRecitationMatchState.uncertain)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'لم نعتبر الكلمة غير المؤكدة صحيحة، ولم نتخطها.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _saving
                          ? null
                          : _recording
                              ? _stopRecording
                              : _startRecording,
                      icon: Icon(
                        _recording
                            ? Icons.stop_circle_outlined
                            : Icons.mic_none_rounded,
                      ),
                      label: Text(
                        _recording ? 'إيقاف التسميع' : 'ابدأ التسميع بالميكروفون',
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (_sessionError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _sessionError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'النص المعتمد: حفص عن عاصم',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ..._lines.map(_buildAyahLine),
          const SizedBox(height: 12),
          if (_modelReady) ...[
            Text(
              'حفظ التقدم بعد المراجعة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            DropdownButtonFormField<String>(
              initialValue: _outcome,
              decoration: const InputDecoration(
                labelText: 'الحالة التي تختارها لهذا النطاق المكتمل',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'learning',
                  child: Text('قيد الحفظ'),
                ),
                DropdownMenuItem(
                  value: 'needs_revision',
                  child: Text('يحتاج مراجعة'),
                ),
                DropdownMenuItem(
                  value: 'stable',
                  child: Text('متقن حسب تقييمي'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _outcome = value);
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving || _completedAyahCount == 0
                  ? null
                  : _saveProgress,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _saving
                    ? 'جارٍ حفظ التقدم…'
                    : 'حفظ $_completedAyahCount آية مكتملة في التقدم',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AyahPracticeLine {
  const _AyahPracticeLine({
    required this.ayahNumber,
    required this.text,
    required this.startIndex,
    required this.endExclusive,
  });

  final int ayahNumber;
  final String text;
  final int startIndex;
  final int endExclusive;
}
