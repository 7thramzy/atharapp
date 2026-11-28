import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/database_providers.dart';
import 'package:athaar/features/quran/data/qcf_hafs_renderer_adapter.dart';
import 'package:athaar/features/quran/presentation/hafs_mushaf_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:drift/native.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
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
  HafsPageStart? pageEnd(int pageNumber) {
    return const HafsPageStart(surahNumber: 1, ayahNumber: 7);
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
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: [Locale('en')],
          home: HafsMushafScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final mushafView = find.byType(QuranPageView);
    expect(mushafView, findsOneWidget);
    expect(
      find.ancestor(
        of: mushafView,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Directionality &&
              widget.textDirection == TextDirection.rtl,
        ),
      ),
      findsOneWidget,
      reason: 'The Hafs Mushaf must stay RTL even when the app locale is LTR.',
    );

    expect(find.text('المصحف المعتمد — حفص عن عاصم'), findsOneWidget);
    expect(find.byTooltip('القراءة النصية المحلية — تنزيل'), findsOneWidget);
    expect(find.text('التجويد الملوّن'), findsOneWidget);
    expect(find.text('صفحة 1 من 604'), findsOneWidget);
    expect(adapter.requestedPages, contains(1));
  });
  test('Ar-Ra\'d opening letters remain inside canonical ayah 1', () {
    final verse = getVerse(13, 1);
    final firstWord = verse.trim().split(RegExp(r'\s+')).first;
    final normalizedFirstWord = firstWord.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670]'),
      '',
    );

    expect(normalizedFirstWord, 'المر');
    expect(verse, contains('تِلْكَ آيَاتُ الْكِتَابِ'));

    final pageNumber = getPageNumber(13, 1);
    final pageSegments = getPageData(pageNumber).cast<Map<String, dynamic>>();
    final surahSegment = pageSegments.singleWhere(
      (segment) => segment['surah'] == 13,
    );
    expect(surahSegment['start'], 1);
    expect(
      surahSegment['end'],
      greaterThanOrEqualTo(1),
      reason: 'Ar-Ra\'d 13:1 must remain a single canonical verse range.',
    );
  });

  test('surah-opening pages retain their canonical first ayah boundaries', () {
    for (final surah in [2, 3, 13, 18, 95, 97, 114, 9]) {
      final pageNumber = getPageNumber(surah, 1);
      final pageSegments = getPageData(pageNumber).cast<Map<String, dynamic>>();
      final segment = pageSegments.singleWhere(
        (entry) => entry['surah'] == surah,
      );

      expect(
        segment['start'],
        1,
        reason: 'Surah $surah must start at ayah 1 on its mapped page.',
      );
    }
  });

  test('Al-Fatihah keeps its basmala within canonical ayah 1', () {
    expect(getVerse(1, 1), startsWith('بِسْمِ'));
  });

}
