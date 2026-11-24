import 'dart:async';

import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                        onTap: () async {
                          final n = s['number'] as int;
                          await store.saveReadingPosition(n, 1);
                          final verses = await store.getSurahAyahs(n);
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  _SurahReaderScreen(surah: s, verses: verses),
                            ),
                          );
                        },
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
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark_add_outlined),
                          onPressed: () => store.addBookmark(
                            v['surah_number'] as int,
                            v['ayah_number'] as int,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SurahReaderScreen extends ConsumerWidget {
  const _SurahReaderScreen({required this.surah, required this.verses});
  final Map<String, Object?> surah;
  final List<Map<String, Object?>> verses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(athaarFeatureStoreProvider);
    return Scaffold(
      appBar: AppBar(title: Text(surah['name'] as String)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: verses
            .map(
              (verse) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        verse['text'] as String,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(height: 2),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${verse['number']}'),
                          IconButton(
                            tooltip: _t(context, 'حفظ علامة', 'Bookmark'),
                            icon: const Icon(Icons.bookmark_add_outlined),
                            onPressed: () => store.addBookmark(
                              surah['number'] as int,
                              verse['number'] as int,
                            ),
                          ),
                          IconButton(
                            tooltip: _t(context, 'إضافة ملاحظة', 'Add note'),
                            icon: const Icon(Icons.note_add_outlined),
                            onPressed: () async {
                              final controller = TextEditingController();
                              final note = await showDialog<String>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: Text(
                                    _t(context, 'ملاحظة خاصة', 'Private note'),
                                  ),
                                  content: TextField(
                                    controller: controller,
                                    maxLines: 4,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: Text(
                                        _t(context, 'إلغاء', 'Cancel'),
                                      ),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(
                                        dialogContext,
                                        controller.text,
                                      ),
                                      child: Text(_t(context, 'حفظ', 'Save')),
                                    ),
                                  ],
                                ),
                              );
                              if (note != null && note.trim().isNotEmpty) {
                                await store.saveNote(
                                  surah['number'] as int,
                                  verse['number'] as int,
                                  note,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
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
  final _surah = TextEditingController(text: '1');
  final _start = TextEditingController(text: '1');
  final _end = TextEditingController(text: '1');
  String _status = 'learning';
  Map<String, int> _summary = {};
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final data = await ref
        .read(athaarFeatureStoreProvider)
        .memorizationSummary();
    if (mounted) {
      setState(() => _summary = data);
    }
  }

  @override
  void dispose() {
    _surah.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_t(context, 'الحفظ والمراجعة', 'Memorization'))),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _t(
            context,
            'سجّل نطاق الحفظ الذي راجعته',
            'Record the range you reviewed',
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _surah,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _t(context, 'رقم السورة', 'Surah number'),
          ),
        ),
        TextField(
          controller: _start,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _t(context, 'من الآية', 'From ayah'),
          ),
        ),
        TextField(
          controller: _end,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _t(context, 'إلى الآية', 'To ayah'),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _status,
          items: [
            DropdownMenuItem(
              value: 'learning',
              child: Text(_t(context, 'قيد الحفظ', 'Learning')),
            ),
            DropdownMenuItem(
              value: 'needs_revision',
              child: Text(_t(context, 'يحتاج مراجعة', 'Needs revision')),
            ),
            DropdownMenuItem(
              value: 'stable',
              child: Text(
                _t(context, 'متقن حسب تقييمك', 'Stable by your own review'),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _status = value ?? 'learning'),
          decoration: InputDecoration(
            labelText: _t(context, 'الحالة', 'Status'),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () async {
            final s = int.tryParse(_surah.text) ?? 0;
            final a = int.tryParse(_start.text) ?? 0;
            final b = int.tryParse(_end.text) ?? 0;
            if (s < 1 || s > 114 || a < 1 || b < a) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _t(
                      context,
                      'تحقق من أرقام السورة والآيات',
                      'Check the surah and ayah numbers',
                    ),
                  ),
                ),
              );
              return;
            }
            await ref
                .read(athaarFeatureStoreProvider)
                .recordMemorizationSession(
                  surah: s,
                  startAyah: a,
                  endAyah: b,
                  outcome: _status,
                );
            await _load();
          },
          icon: const Icon(Icons.save_outlined),
          label: Text(
            _t(context, 'حفظ جلسة المراجعة', 'Save revision session'),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _t(context, 'ملخص تقدمك', 'Your progress'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...[
          ('learning', _t(context, 'قيد الحفظ', 'Learning')),
          ('needs_revision', _t(context, 'يحتاج مراجعة', 'Needs revision')),
          ('stable', _t(context, 'مستقر', 'Stable')),
        ].map(
          (entry) => ListTile(
            title: Text(entry.$2),
            trailing: Text('${_summary[entry.$1] ?? 0}'),
          ),
        ),
      ],
    ),
  );
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
          children: labels.entries
              .map(
                (e) => Card(
                  child: ListTile(
                    title: Text(e.value),
                    trailing: Text(
                      '${values[e.key] ?? 0}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    ),
  );
}
