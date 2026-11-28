import 'dart:async';

import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:athaar/features/sharing/athaar_share_card_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:athaar/features/quran/data/quran_reader_routes.dart';

String _t(BuildContext context, String ar, String en) =>
    Localizations.localeOf(context).languageCode == 'ar' ? ar : en;

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});
  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  final _search = TextEditingController();
  List<Map<String, Object?>> _results = [];
  List<Map<String, Object?>> _surahs = [];
  Map<String, Object?>? _sourceManifest;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final store = ref.read(athaarFeatureStoreProvider);
      final rows = await store.listSurahs();
      final sourceManifest = await store.quranManifest;
      if (mounted) {
        setState(() {
          _surahs = rows;
          _sourceManifest = sourceManifest;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _showSourceInfo() async {
    final manifest =
        _sourceManifest ??
        await ref.read(athaarFeatureStoreProvider).quranManifest;
    if (!mounted || manifest == null) return;
    final sourceUrl = manifest['source_url'] as String? ?? 'https://tanzil.net';
    final licenseNotice = manifest['license_notice'] as String? ?? '';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          _t(context, 'مصدر النص والترخيص', 'Text source and license'),
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            '${manifest['source']}\n${manifest['edition']} — ${manifest['version']}\n$sourceUrl\n\n$licenseNotice',
            textDirection: TextDirection.ltr,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(_t(context, 'إغلاق', 'Close')),
          ),
        ],
      ),
    );
  }

  Future<void> _openDownloadedText() async {
    final position = await ref
        .read(athaarFeatureStoreProvider)
        .getReadingPosition();
    if (!mounted) return;
    await context.push<void>(
      QuranReaderRoutes.downloadedText(
        surahNumber: position?.surahNumber ?? 1,
        ayahNumber: position?.ayahNumber ?? 1,
      ),
    );
  }

  Future<void> _find(String value) async {
    final rows = await ref.read(athaarFeatureStoreProvider).searchAyahs(value);
    if (mounted) {
      setState(() => _results = rows);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.read(athaarFeatureStoreProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, 'القرآن الكريم', 'The Quran')),
        actions: [
          IconButton(
            tooltip: _t(
              context,
              'مصدر النص والترخيص',
              'Text source and license',
            ),
            icon: const Icon(Icons.info_outline),
            onPressed: _showSourceInfo,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF087C83), Color(0xFF004D5C)],
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.push<void>('/quran/mushaf'),
                    child: Row(
                      children: [
                        Container(
                          width: 66,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFFE1C78E),
                            size: 42,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'فتح المصحف المعتمد — حفص عن عاصم',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(height: 7),
                              Text(
                                'المصحف المرجعي في أثَر · 604 صفحات · تجويد وتظليل',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text('قراءة النص المحلي — وضع مساعد'),
                    subtitle: Text(
                      'Tanzil Uthmani 1.1 · استئناف آخر موضع محفوظ',
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: _openDownloadedText,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  onChanged: _find,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: _t(
                      context,
                      'ابحث في الآيات بعد استيراد النص',
                      'Search ayahs after importing the text',
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (_sourceManifest != null)
                  Card(
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.verified_outlined),
                      title: Text(
                        _t(
                          context,
                          'النص العثماني — مشروع تنزيل',
                          'Uthmani text — Tanzil Project',
                        ),
                      ),
                      subtitle: Text(
                        '${_sourceManifest!['edition']} · ${_sourceManifest!['version']}',
                      ),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: _showSourceInfo,
                    ),
                  ),
                const SizedBox(height: 8),
                if (_surahs.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 32),
                          const SizedBox(height: 10),
                          Text(
                            _t(
                              context,
                              'مصدر القرآن لم يُستورد بعد',
                              'Quran source has not been imported',
                            ),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _t(
                              context,
                              'القارئ جاهز، لكننا لا نعرض نصاً تجريبياً. يلزم استيراد نسخة Tanzil Uthmani v1.1 بعد التحقق من الملف والبصمة والترخيص.',
                              'The reader is ready, but no sample Quran text is shown. Import Tanzil Uthmani v1.1 only after verifying the file, checksum, and license notice.',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const SelectableText('https://tanzil.net/download/'),
                        ],
                      ),
                    ),
                  ),
                if (_surahs.isNotEmpty && _results.isEmpty)
                  ..._surahs.map(
                    (s) => Card(
                      child: ListTile(
                        title: Text(s['name'] as String),
                        subtitle: Text(
                          '${s['ayah_count']} ${_t(context, 'آية', 'ayahs')}',
                        ),
                        leading: CircleAvatar(child: Text('${s['number']}')),
                        onTap: () => context.push<void>(
                          QuranReaderRoutes.downloadedText(
                            surahNumber: s['number'] as int,
                            ayahNumber: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_results.isNotEmpty)
                  ..._results.map(
                    (v) => Card(
                      child: ListTile(
                        title: Text(
                          v['text'] as String,
                          textDirection: TextDirection.rtl,
                        ),
                        subtitle: Text(
                          '${v['surah_name']} — ${v['ayah_number']}',
                        ),
                        onTap: () => context.push<void>(
                          QuranReaderRoutes.downloadedText(
                            surahNumber: v['surah_number'] as int,
                            ayahNumber: v['ayah_number'] as int,
                          ),
                        ),
                        trailing: Wrap(
                          spacing: 0,
                          children: [
                            IconButton(
                              tooltip: 'مشاركة الآية',
                              icon: const Icon(Icons.image_outlined),
                              onPressed: () => context.push(
                                '/share-ayah/${v['surah_number']}/${v['ayah_number']}',
                              ),
                            ),
                            IconButton(
                              tooltip: 'حفظ',
                              icon: const Icon(Icons.bookmark_add_outlined),
                              onPressed: () => store.addBookmark(
                                v['surah_number'] as int,
                                v['ayah_number'] as int,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class AdhkarScreen extends ConsumerStatefulWidget {
  const AdhkarScreen({super.key});
  @override
  ConsumerState<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends ConsumerState<AdhkarScreen> {
  List<Map<String, Object?>> _items = [];
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final rows = await ref.read(athaarFeatureStoreProvider).listAdhkar();
    if (mounted) {
      setState(() => _items = rows);
    }
  }

  Future<void> _add() async {
    final text = TextEditingController();
    final source = TextEditingController();
    final target = TextEditingController(text: '33');
    final result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t(context, 'إضافة ذكر', 'Add a dhikr')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: text,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _t(context, 'نص الذكر', 'Dhikr text'),
              ),
            ),
            TextField(
              controller: target,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _t(context, 'العدد المستهدف', 'Target count'),
              ),
            ),
            TextField(
              controller: source,
              decoration: InputDecoration(
                labelText: _t(context, 'المصدر / المرجع', 'Source / reference'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t(context, 'إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, [text.text, target.text, source.text]),
            child: Text(_t(context, 'إضافة', 'Add')),
          ),
        ],
      ),
    );
    if (result == null) {
      return;
    }
    await ref
        .read(athaarFeatureStoreProvider)
        .createAdhkarItem(
          textArabic: result[0],
          targetCount: int.tryParse(result[1]) ?? 0,
          sourceReference: result[2],
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_t(context, 'الأذكار', 'Adhkar'))),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _add,
      icon: const Icon(Icons.add),
      label: Text(_t(context, 'إضافة ذكر', 'Add dhikr')),
    ),
    body: _items.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _t(
                  context,
                  'لا توجد أذكار مضافة بعد. أضف نصاً مع مرجعه حتى لا ننسب ذكراً إلى مصدر غير موثّق.',
                  'No adhkar added yet. Add wording with its reference so content is not attributed to an unverified source.',
                ),
              ),
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: _items.map((item) {
              final count = item['count'] as int;
              final target = item['target'] as int;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        item['text'] as String,
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(height: 1.8),
                      ),
                      const SizedBox(height: 8),
                      Text('${item['source']}'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (count / target).clamp(0.0, 1.0),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$count / $target'),
                          FilledButton.tonal(
                            onPressed: () async {
                              await ref
                                  .read(athaarFeatureStoreProvider)
                                  .incrementAdhkar(item['id'] as String);
                              await _load();
                            },
                            child: Text(_t(context, 'تسبيح +1', '+1')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
  );
}

class MemorizationScreen extends ConsumerStatefulWidget {
  const MemorizationScreen({super.key});
  @override
  ConsumerState<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends ConsumerState<MemorizationScreen> {
  List<Map<String, Object?>> _surahs = const [];
  int _selectedSurah = 1;
  int _ayahCount = 7;
  int _startAyah = 1;
  int _endAyah = 1;
  String _status = 'learning';
  Map<String, int> _summary = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final store = ref.read(athaarFeatureStoreProvider);
      final results = await Future.wait([
        store.listSurahs(),
        store.memorizationSummary(),
      ]);
      if (!mounted) return;
      final surahs = results[0] as List<Map<String, Object?>>;
      final summary = results[1] as Map<String, int>;
      final selected = surahs.where((item) => item['number'] == _selectedSurah);
      final count = selected.isEmpty ? 7 : selected.first['ayah_count'] as int;
      setState(() {
        _surahs = surahs;
        _summary = summary;
        _ayahCount = count;
        _startAyah = _startAyah.clamp(1, count).toInt();
        _endAyah = _endAyah.clamp(_startAyah, count).toInt();
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _selectSurah(int? number) {
    if (number == null) return;
    final selected = _surahs.where((item) => item['number'] == number);
    if (selected.isEmpty) return;
    final count = selected.first['ayah_count'] as int;
    setState(() {
      _selectedSurah = number;
      _ayahCount = count;
      _startAyah = 1;
      _endAyah = 1;
    });
  }

  Future<void> _saveSession() async {
    if (_startAyah < 1 || _endAyah < _startAyah || _endAyah > _ayahCount) {
      setState(
        () => _error = _t(
          context,
          'نطاق الآيات غير صحيح لهذه السورة.',
          'The ayah range is invalid for this surah.',
        ),
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(athaarFeatureStoreProvider)
          .recordMemorizationSession(
            surah: _selectedSurah,
            startAyah: _startAyah,
            endAyah: _endAyah,
            outcome: _status,
          );
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recorded =
        (_summary['learning'] ?? 0) +
        (_summary['needs_revision'] ?? 0) +
        (_summary['stable'] ?? 0);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, 'الحفظ والمراجعة', 'Memorization')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _surahs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _error ??
                      _t(
                        context,
                        'استورد نص القرآن المعتمد أولاً لتفعيل جلسات الحفظ.',
                        'Import the approved Quran dataset to enable memorization sessions.',
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _t(
                    context,
                    'جلسة حفظ ومراجعة',
                    'Memorization and revision session',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  _t(
                    context,
                    'اختر السورة ونطاق الآيات من بيانات المصحف المستوردة؛ لن نقبل نطاقًا يتجاوز عدد آيات السورة.',
                    'Choose a surah and ayah range from the imported Mushaf data. Ranges beyond the surah length are rejected.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: _selectedSurah,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _t(context, 'السورة', 'Surah'),
                    border: const OutlineInputBorder(),
                  ),
                  items: _surahs
                      .map(
                        (item) => DropdownMenuItem<int>(
                          value: item['number'] as int,
                          child: Text('${item['number']} — ${item['name']}'),
                        ),
                      )
                      .toList(),
                  onChanged: _selectSurah,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _startAyah,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _t(context, 'من الآية', 'From ayah'),
                          border: const OutlineInputBorder(),
                        ),
                        items: List.generate(
                          _ayahCount,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text('${index + 1}'),
                          ),
                        ),
                        onChanged: (value) => setState(() {
                          if (value == null) return;
                          _startAyah = value;
                          if (_endAyah < value) _endAyah = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _endAyah,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _t(context, 'إلى الآية', 'To ayah'),
                          border: const OutlineInputBorder(),
                        ),
                        items: List.generate(
                          _ayahCount - _startAyah + 1,
                          (index) => DropdownMenuItem(
                            value: _startAyah + index,
                            child: Text('${_startAyah + index}'),
                          ),
                        ),
                        onChanged: (value) => setState(() {
                          if (value != null) _endAyah = value;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: _t(context, 'نتيجة المراجعة', 'Review outcome'),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'learning',
                      child: Text(_t(context, 'قيد الحفظ', 'Learning')),
                    ),
                    DropdownMenuItem(
                      value: 'needs_revision',
                      child: Text(
                        _t(context, 'يحتاج مراجعة', 'Needs revision'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'stable',
                      child: Text(
                        _t(
                          context,
                          'مستقر حسب تقييمك',
                          'Stable by your own review',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _status = value ?? 'learning'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _saving || _surahs.isEmpty ? null : _saveSession,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _t(context, 'حفظ جلسة المراجعة', 'Save revision session'),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  _t(context, 'ملخص تقدمك', 'Your progress'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  _t(
                    context,
                    'آيات لها حالة محفوظة: $recorded من 6236',
                    'Ayahs with a saved status: $recorded of 6236',
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (recorded / 6236).clamp(0.0, 1.0),
                ),
                const SizedBox(height: 12),
                ...[
                  (
                    'learning',
                    _t(context, 'قيد الحفظ', 'Learning'),
                    Icons.menu_book_outlined,
                  ),
                  (
                    'needs_revision',
                    _t(context, 'تحتاج مراجعة', 'Needs revision'),
                    Icons.replay_rounded,
                  ),
                  (
                    'stable',
                    _t(context, 'مستقرة حسب تقييمك', 'Stable by your review'),
                    Icons.check_circle_outline_rounded,
                  ),
                ].map(
                  (entry) => Card(
                    child: ListTile(
                      leading: Icon(entry.$3),
                      title: Text(entry.$2),
                      trailing: Text(
                        '${_summary[entry.$1] ?? 0}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _t(
                    context,
                    'الحالة «مستقر» تعكس تقييمك الشخصي للمراجعة، وليست حكمًا آليًا على صحة التلاوة أو الإتقان.',
                    '“Stable” reflects your own review, not an automated judgement of recitation accuracy or mastery.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}

class PersonalImpactScreen extends ConsumerWidget {
  const PersonalImpactScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: Text(_t(context, 'أثري الشخصي', 'My personal impact')),
    ),
    body: FutureBuilder<Map<String, int>>(
      future: ref.read(athaarFeatureStoreProvider).personalImpactSummary(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final values = snapshot.data!;
        final labels = {
          'bookmarks': _t(context, 'مواضع محفوظة', 'Bookmarks'),
          'notes': _t(context, 'ملاحظات خاصة', 'Private notes'),
          'sessions': _t(context, 'جلسات مراجعة', 'Revision sessions'),
          'adhkar_counts': _t(context, 'مرات الذكر المسجلة', 'Dhikr counts'),
          'stable_ayahs': _t(
            context,
            'آيات صنّفتها مستقرة',
            'Ayahs marked stable',
          ),
          'learning_ayahs': _t(context, 'آيات قيد الحفظ', 'Ayahs in progress'),
        };
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.stars_rounded, color: Color(0xFFB58A35)),
                title: const Text('نقاط النشاط'),
                subtitle: const Text('نقاط القراءة وجلسات الحفظ المسجلة، وليست تقييماً لصحة التلاوة.'),
                trailing: FutureBuilder<Map<String, int>>(
                  future: ref.read(athaarFeatureStoreProvider).activityPointsSummary(),
                  builder: (context, pointsSnapshot) => Text(
                    '${pointsSnapshot.data?['points'] ?? 0}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () async {
                final points = await ref.read(athaarFeatureStoreProvider).activityPointsSummary();
                await const AthaarShareCardService().share(
                  title: 'إنجازي في أثَر',
                  subtitle: 'رحلة قراءة وحفظ ومراجعة',
                  body: 'إجمالي النقاط: ${points['points'] ?? 0}\nنقاط القراءة: ${points['reading_points'] ?? 0} من ${points['reading_events'] ?? 0} مواضع\nنقاط الحفظ: ${points['memorization_points'] ?? 0} من ${points['memorization_events'] ?? 0} جلسات\nكل خطوة صغيرة تقرّبني من الاستمرار.',
                  footer: 'النقاط للنشاط المسجل فقط · لا تمثل حكماً على جودة التلاوة',
                );
              },
              icon: const Icon(Icons.share_outlined),
              label: const Text('مشاركة إنجازي ونقاطي'),
            ),
            const SizedBox(height: 8),
            ...labels.entries.map(
              (e) => Card(
                child: ListTile(
                  title: Text(e.value),
                  trailing: Text(
                    '${values[e.key] ?? 0}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
