import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late AthaarFeatureStore store;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.initializeDefaults();
    store = AthaarFeatureStore(database);
  });

  tearDown(() async => database.close());

  test(
    'reading position stores its coordinate and explicit reading mode',
    () async {
      await store.saveReadingPosition(2, 255, readingMode: 'hafs_mushaf');

      final position = await store.getReadingPosition();

      expect(position?.surahNumber, 2);
      expect(position?.ayahNumber, 255);
      expect(position?.readingMode, 'hafs_mushaf');
    },
  );

  test('unspecified reading mode retains the legacy surah default', () async {
    await store.saveReadingPosition(3, 8);

    final position = await store.getReadingPosition();

    expect(position?.surahNumber, 3);
    expect(position?.ayahNumber, 8);
    expect(position?.readingMode, 'surah');
  });

  test('adhkar counters persist and increment per local day', () async {
    await store.createAdhkarItem(
      textArabic: 'ذكر اختباري',
      targetCount: 3,
      sourceReference: 'اختبار فقط',
    );
    var items = await store.listAdhkar();
    expect(items, hasLength(1));
    await store.incrementAdhkar(items.single['id']! as String);
    items = await store.listAdhkar();
    expect(items.single['count'], 1);
  });

  test('bundled Quranic adhkar seed is offline and idempotent', () async {
    final quran = await rootBundle.loadString(
      'assets/content/quran/tanzil-uthmani-v1.1.json',
    );
    await store.importQuranJson(quran);
    final seed = await rootBundle.loadString(
      'assets/content/adhkar/seed-v1.json',
    );

    await store.importBundledAdhkar(seed);
    await store.importBundledAdhkar(seed);

    final items = await store.listAdhkar();
    expect(items, hasLength(8));
    expect(items.where((item) => item['category_id'] == 'morning'), hasLength(4));
    expect(items.where((item) => item['category_id'] == 'evening'), hasLength(4));
    expect(items.every((item) => item['verified'] == true), isTrue);
    expect(items.every((item) => item['review_status'] == 'reviewed'), isTrue);
  });

  test('reading completion awards points once per ayah per local day', () async {
    await store.recordReadingCompletion('2:255');
    await store.recordReadingCompletion('2:255');
    final summary = await store.activityPointsSummary();
    expect(summary['points'], 1);
    expect(summary['events'], 1);
  });

  test('favorite toggle is persisted in the adhkar library', () async {
    await store.createAdhkarItem(
      textArabic: 'ذكر اختباري',
      targetCount: 1,
      sourceReference: 'اختبار',
    );
    final item = (await store.listAdhkar()).single;
    final id = item['id']! as String;
    await store.toggleAdhkarFavorite(id);
    expect((await store.listAdhkar()).single['favorite'], isTrue);
    await store.toggleAdhkarFavorite(id);
    expect((await store.listAdhkar()).single['favorite'], isFalse);
  });

  test('memorization session updates every ayah atomically', () async {
    final source = await rootBundle.loadString(
      'assets/content/quran/tanzil-uthmani-v1.1.json',
    );
    await store.importQuranJson(source);

    await store.recordMemorizationSession(
      surah: 1,
      startAyah: 1,
      endAyah: 3,
      outcome: 'stable',
    );
    final summary = await store.memorizationSummary();
    expect(summary['stable'], 3);
  });

  test(
    'rejects memorization references outside canonical surah bounds',
    () async {
      final source = await rootBundle.loadString(
        'assets/content/quran/tanzil-uthmani-v1.1.json',
      );
      await store.importQuranJson(source);

      await expectLater(
        store.setMemorizationStatus(1, 8, 'stable'),
        throwsRangeError,
      );
      await expectLater(
        store.recordMemorizationSession(
          surah: 13,
          startAyah: 1,
          endAyah: 44,
          outcome: 'learning',
        ),
        throwsRangeError,
      );
      expect((await store.memorizationSummary())['stable'], 0);
      expect((await store.personalImpactSummary())['sessions'], 0);
    },
  );

  test('personal impact is derived from saved local activity', () async {
    final source = await rootBundle.loadString(
      'assets/content/quran/tanzil-uthmani-v1.1.json',
    );
    await store.importQuranJson(source);

    await store.recordMemorizationSession(
      surah: 2,
      startAyah: 1,
      endAyah: 2,
      outcome: 'learning',
    );
    final impact = await store.personalImpactSummary();
    expect(impact['sessions'], 1);
    expect(impact['learning_ayahs'], 2);
  });
}
