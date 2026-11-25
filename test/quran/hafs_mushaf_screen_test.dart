import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/database_providers.dart';
import 'package:athaar/features/quran/data/qcf_hafs_renderer_adapter.dart';
import 'package:athaar/features/quran/presentation/hafs_mushaf_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHafsAdapter implements HafsRendererAdapter {
  final requestedPages = <int>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> ensurePageFonts(int pageNumber) async {
    requestedPages.add(pageNumber);
  }

  @override
  int firstVisiblePage(int pageNumber, {required bool twoPageLayout}) {
    return twoPageLayout && pageNumber.isEven ? pageNumber - 1 : pageNumber;
  }

  @override
  HafsPageStart? pageStart(int pageNumber) {
    return const HafsPageStart(surahNumber: 1, ayahNumber: 1);
  }

  @override
  int? pageForAyah(int surahNumber, int ayahNumber) => 1;
}

void main() {
  testWidgets('shows the integrated Hafs Mushaf controls', (tester) async {
    final adapter = _FakeHafsAdapter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final database = AppDatabase.forTesting(NativeDatabase.memory());
            ref.onDispose(database.close);
            return database;
          }),
          hafsRendererAdapterProvider.overrideWithValue(adapter),
        ],
        child: const MaterialApp(home: HafsMushafScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('المصحف المعتمد — حفص عن عاصم'), findsOneWidget);
    expect(find.byTooltip('القراءة النصية المحلية — تنزيل'), findsOneWidget);
    expect(find.text('التجويد الملوّن'), findsOneWidget);
    expect(find.text('صفحة 1 من 604'), findsOneWidget);
    expect(adapter.requestedPages, contains(1));
  });
}
