import 'dart:async';

import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdhkarLibraryScreen extends ConsumerStatefulWidget {
  const AdhkarLibraryScreen({super.key});

  @override
  ConsumerState<AdhkarLibraryScreen> createState() => _AdhkarLibraryScreenState();
}

class _AdhkarLibraryScreenState extends ConsumerState<AdhkarLibraryScreen> {
  List<Map<String, Object?>> _items = const [];
  List<Map<String, Object?>> _categories = const [];
  String _selectedCategory = 'morning';
  bool _favoritesOnly = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final store = ref.read(athaarFeatureStoreProvider);
      final items = await store.listAdhkar();
      final categories = await store.listAdhkarCategories();
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
        _categories = categories;
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

  Future<void> _increment(String id) async {
    await ref.read(athaarFeatureStoreProvider).incrementAdhkar(id);
    await _load();
  }

  Future<void> _favorite(String id) async {
    await ref.read(athaarFeatureStoreProvider).toggleAdhkarFavorite(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _items.where((item) {
      final categoryMatches = _selectedCategory == 'all' ||
          item['category_id'] == _selectedCategory;
      return categoryMatches && (!_favoritesOnly || item['favorite'] == true);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار والأوراد'),
        actions: [
          IconButton(
            tooltip: _favoritesOnly ? 'عرض الكل' : 'المفضلة',
            onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
            icon: Icon(_favoritesOnly ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!, textAlign: TextAlign.center),
                ))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFF153E38), Color(0xFF28685A)],
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('وِردك اليومي', style: TextStyle(
                            color: Colors.white70, fontSize: 13,
                          )),
                          SizedBox(height: 6),
                          Text('قليلٌ دائم، خيرٌ من كثيرٍ منقطع',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text('ابدأ بما تيسر، وتابع تقدمك بهدوء.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('الكل'),
                          selected: _selectedCategory == 'all',
                          onSelected: (_) => setState(() => _selectedCategory = 'all'),
                        ),
                        ..._categories.map((category) {
                          final id = category['id'] as String;
                          return ChoiceChip(
                            label: Text(category['name'] as String),
                            selected: _selectedCategory == id,
                            onSelected: (_) => setState(() {
                              _selectedCategory = id;
                              _favoritesOnly = false;
                            }),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_favoritesOnly)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('الأذكار المفضلة'),
                      ),
                    if (visible.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'لا توجد عناصر في هذا القسم حالياً.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ...visible.map((item) {
                      final count = item['count'] as int;
                      final target = item['target'] as int;
                      final verified = item['verified'] == true;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['category'] as String,
                                      style: Theme.of(context).textTheme.labelLarge,
                                    ),
                                  ),
                                  if (verified)
                                    const Tooltip(
                                      message: 'النص من مرجع قرآني محلي',
                                      child: Icon(Icons.verified_outlined,
                                        size: 18, color: Color(0xFF28745B)),
                                    ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _favorite(item['id'] as String),
                                    icon: Icon(
                                      item['favorite'] == true
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: item['favorite'] == true
                                          ? Colors.redAccent
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['text'] as String,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  height: 2.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item['source'] as String,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  minHeight: 6,
                                  value: (count / target).clamp(0.0, 1.0),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$count / $target'),
                                  FilledButton.tonalIcon(
                                    onPressed: count >= target ? null : () => _increment(item['id'] as String),
                                    icon: const Icon(Icons.add),
                                    label: const Text('تسبيح'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      'المحتوى المتاح حالياً يتضمن آيات قرآنية مخصصة للورد الصباحي والمسائي. ستضاف الأذكار النبوية بعد تدقيق نصوصها ومراجعها.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
    );
  }
}
