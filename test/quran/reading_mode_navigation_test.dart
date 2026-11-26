import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/database_providers.dart';
import 'package:athaar/features/quran/data/qcf_hafs_renderer_adapter.dart';
import 'package:athaar/features/quran/presentation/downloaded_quran_reader_screen.dart';
import 'package:athaar/features/quran/presentation/hafs_mushaf_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class _NavigationHafsAdapter implements HafsRendererAdapter {
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
    return const HafsPageStart(surahNumber: 2, ayahNumber: 1);
  }

  @override
  HafsPageStart? pageEnd(int pageNumber) {
    return const HafsPageStart(surahNumber: 2, ayahNumber: 2);
  }

  @override
  int? pageForAyah(int surahNumber, int ayahNumber) {
    if (surahNumber != 2 || ayahNumber < 1 || ayahNumber > 2) return null;
    return 12;
  }
}

Future<AppDatabase> _createDatabase() async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  await database.initializeDefaults();
  await database.customStatement(
    'INSERT INTO quran_surahs(surah_number, name_arabic, name_transliteration, ayah_count) VALUES(?, ?, ?, ?)',
    [2, 'البقرة', 'Al-Baqarah', 2],
  );
  await database.customStatement(
    'INSERT INTO quran_ayahs(surah_number, ayah_number, text_uthmani, normalized_text, juz_number, page_number) VALUES(?, ?, ?, ?, ?, ?)',
    [2, 1, 'الم', 'الم', 1, 1],
  );
  await database.customStatement(
    'INSERT INTO quran_ayahs(surah_number, ayah_number, text_uthmani, normalized_text, juz_number, page_number) VALUES(?, ?, ?, ?, ?, ?)',
    [2, 2, 'ذَٰلِكَ الْكِتَابُ', 'ذلك الكتاب', 1, 1],
  );
  return database;
}

void main() {
  testWidgets(
    'downloaded text opens the real Hafs Mushaf at the same highlighted ayah',
    (tester) async {
      final database = await _createDatabase();
      addTearDown(database.close);
      final adapter = _NavigationHafsAdapter();

      final router = GoRouter(
        initialLocation: '/quran/text/2?ayah=2',
        routes: [
          GoRoute(
            path: '/quran/text/:surah',
            builder: (context, state) => DownloadedQuranReaderScreen(
              surahNumber: int.parse(state.pathParameters['surah'] ?? '2'),
              initialAyahNumber: int.parse(
                state.uri.queryParameters['ayah'] ?? '1',
              ),
            ),
          ),
          GoRoute(
            path: '/quran/mushaf',
            builder: (context, state) => HafsMushafScreen(
              initialSurahNumber: int.tryParse(
                state.uri.queryParameters['surah'] ?? '',
              ),
              initialAyahNumber: int.tryParse(
                state.uri.queryParameters['ayah'] ?? '',
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) => database),
            hafsRendererAdapterProvider.overrideWithValue(adapter),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('آية 2'), findsOneWidget);
      expect(find.text('موضع القراءة'), findsOneWidget);

      await tester.tap(find.byTooltip('المصحف المعتمد — حفص عن عاصم').first);
      await tester.pumpAndSettle();

      expect(find.text('المصحف المعتمد — حفص عن عاصم'), findsOneWidget);
      final pageView = tester.widget<QuranPageView>(find.byType(QuranPageView));
      expect(pageView.highlights, hasLength(1));
      expect(pageView.highlights.single.surah, 2);
      expect(pageView.highlights.single.verseNumber, 2);
      expect(pageView.highlights.single.page, 12);

      final saved = await database.getReadingPosition();
      expect(saved?.surahNumber, 2);
      expect(saved?.ayahNumber, 2);
      expect(saved?.readingMode, 'hafs_mushaf');
    },
  );

  testWidgets(
    'Hafs Mushaf returns to downloaded text at the same selected ayah',
    (tester) async {
      final database = await _createDatabase();
      await database.saveReadingPosition(
        surahNumber: 2,
        ayahNumber: 2,
        readingMode: 'downloaded_text',
      );
      addTearDown(database.close);

      final adapter = _NavigationHafsAdapter();
      final router = GoRouter(
        initialLocation: '/quran/mushaf',
        routes: [
          GoRoute(
            path: '/quran/mushaf',
            builder: (context, state) => const HafsMushafScreen(),
          ),
          GoRoute(
            path: '/quran/text/:surah',
            builder: (context, state) => DownloadedQuranReaderScreen(
              surahNumber: int.parse(state.pathParameters['surah'] ?? '2'),
              initialAyahNumber: int.parse(
                state.uri.queryParameters['ayah'] ?? '1',
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) => database),
            hafsRendererAdapterProvider.overrideWithValue(adapter),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final pageView = tester.widget<QuranPageView>(find.byType(QuranPageView));
      expect(pageView.highlights, hasLength(1));
      expect(pageView.highlights.single.surah, 2);
      expect(pageView.highlights.single.verseNumber, 2);

      await tester.tap(find.byTooltip('القراءة النصية المحلية — تنزيل'));
      await tester.pumpAndSettle();

      expect(find.text('آية 2'), findsOneWidget);
      expect(find.text('موضع القراءة'), findsOneWidget);
      expect(find.text('ذَٰلِكَ الْكِتَابُ'), findsOneWidget);

      final saved = await database.getReadingPosition();
      expect(saved?.surahNumber, 2);
      expect(saved?.ayahNumber, 2);
      expect(saved?.readingMode, 'downloaded_text');
    },
  );
}
