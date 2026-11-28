import 'dart:async';

import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:athaar/features/sharing/athaar_share_card_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AyahShareScreen extends ConsumerStatefulWidget {
  const AyahShareScreen({
    required this.surahNumber,
    required this.ayahNumber,
    super.key,
  });

  final int surahNumber;
  final int ayahNumber;

  @override
  ConsumerState<AyahShareScreen> createState() => _AyahShareScreenState();
}

class _AyahShareScreenState extends ConsumerState<AyahShareScreen> {
  final _translation = TextEditingController();
  final _tafsir = TextEditingController();
  final _source = TextEditingController();
  Map<String, Object?>? _ayah;
  bool _loading = true;
  bool _sharing = false;
  bool _readMarked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _translation.dispose();
    _tafsir.dispose();
    _source.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final value = await ref.read(athaarFeatureStoreProvider)
          .getAyahForShare(widget.surahNumber, widget.ayahNumber);
      if (!mounted) {
        return;
      }
      setState(() {
        _ayah = value;
        _loading = false;
        if (value == null) {
          _error = 'لم يتم العثور على الآية في النص المحلي.';
        }
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _share() async {
    final translation = _translation.text.trim();
    final tafsir = _tafsir.text.trim();
    final source = _source.text.trim();
    if ((translation.isNotEmpty || tafsir.isNotEmpty) && source.isEmpty) {
      setState(() => _error = 'أدخل مصدر الترجمة أو التفسير قبل تضمينه في البطاقة.');
      return;
    }
    final ayah = _ayah;
    if (ayah == null) {
      return;
    }
    final parts = <String>[
      ayah['text'] as String,
      if (translation.isNotEmpty) '\n\nالترجمة:\n$translation',
      if (tafsir.isNotEmpty) '\n\nالتفسير المختصر:\n$tafsir',
    ];
    setState(() {
      _sharing = true;
      _error = null;
    });
    try {
      await const AthaarShareCardService().share(
        title: 'آية من القرآن الكريم',
        subtitle: 'سورة ${ayah['surah_name']} · الآية ${ayah['ayah']}',
        body: parts.join(),
        footer: source.isEmpty ? 'النص القرآني · أثَر' : 'المصدر: $source · أثَر',
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'تعذرت مشاركة البطاقة: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _sharing = false);
      }
    }
  }

  Future<void> _markRead() async {
    await ref.read(athaarFeatureStoreProvider).recordReadingCompletion(
      '${widget.surahNumber}:${widget.ayahNumber}',
    );
    if (mounted) {
      setState(() => _readMarked = true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('مشاركة آية')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _ayah == null
            ? Center(child: Text(_error ?? 'تعذر تحميل الآية'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _ayah!['text'] as String,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 2.0),
                        ),
                        const SizedBox(height: 12),
                        Text('سورة ${_ayah!['surah_name']} · الآية ${_ayah!['ayah']}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _translation,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'الترجمة (اختياري)',
                      hintText: 'أدخل نص الترجمة التي تملك حق استخدامها',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tafsir,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'التفسير المختصر (اختياري)',
                      hintText: 'أدخل مقتطفاً مرخصاً من تفسير موثوق',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _source,
                    decoration: const InputDecoration(
                      labelText: 'مصدر الترجمة / التفسير',
                      hintText: 'اسم المصدر والمرجع أو رابط الترخيص',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _sharing ? null : _share,
                    icon: _sharing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.image_outlined),
                    label: const Text('إنشاء البطاقة ومشاركتها'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _readMarked ? null : _markRead,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: Text(_readMarked ? 'تم تسجيل القراءة لهذا اليوم' : 'أنهيت قراءة هذه الآية'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'لا يضيف التطبيق ترجمة أو تفسيراً تلقائياً إلى البطاقة؛ لا يُدرج أي نص إضافي إلا مع مصدر يحدده المستخدم.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
  );
}
