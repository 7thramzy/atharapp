import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  test('memorization session updates every ayah atomically', () async {
    await store.recordMemorizationSession(
      surah: 1,
      startAyah: 1,
      endAyah: 3,
      outcome: 'stable',
    );
    final summary = await store.memorizationSummary();
    expect(summary['stable'], 3);
  });

  test('personal impact is derived from saved local activity', () async {
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
