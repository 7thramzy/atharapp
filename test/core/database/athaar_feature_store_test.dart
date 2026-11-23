import 'dart:convert';

import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _canonicalAyahCounts = <int>[
  7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111,
  43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64,
  77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83,
  182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29,
  18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
  14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28,
  20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25,
  22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19,
  5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3,
  6, 3, 5, 4, 5, 6,
];

String _syntheticQuranImportJson() {
  final surahs = List.generate(
    114,
    (index) => <String, Object?>{
      'surahNumber': index + 1,
      'nameArabic': 'سورة اختبار ${index + 1}',
      'nameTransliteration': 'Test Surah ${index + 1}',
      'ayahCount': _canonicalAyahCounts[index],
    },
  );

  final ayahs = <Map<String, Object?>>[];
  for (var surah = 1; surah <= 114; surah++) {
    for (var ayah = 1; ayah <= _canonicalAyahCounts[surah - 1]; ayah++) {
      ayahs.add({
        'surahNumber': surah,
        'ayahNumber': ayah,
        // Synthetic fixture text only. This is not Quran content.
        'textUthmani': 'نص اختباري $surah:$ayah',
        'normalizedText': 'نص اختباري $surah:$ayah',
      });
    }
  }

  final payload = {'surahs': surahs, 'ayahs': ayahs};
  final payloadJson = jsonEncode(payload);
  final checksum = sha256.convert(utf8.encode(payloadJson)).toString();

  return jsonEncode({
    'manifest': {
      'source': 'Tanzil Project (test fixture)',
      'sourceUrl': 'https://tanzil.net/download/',
      'edition': 'Uthmani',
      'version': '1.1',
      'licenseNotice': 'Synthetic test fixture; not Quran text.',
      'sha256': checksum,
    },
    ...payload,
  });
}

void main() {
  late AppDatabase database;
  late AthaarFeatureStore store;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.initializeDefaults();
    store = AthaarFeatureStore(database);
  });

  tearDown(() async => database.close());

  test('Quran import verifies a non-circular payload checksum', () async {
    final sourceJson = _syntheticQuranImportJson();

    await store.importQuranJson(sourceJson);

    expect(await store.hasQuranDataset, isTrue);
    expect(await store.surahCount, 114);
    expect(await store.getSurahAyahs(1), hasLength(7));
  });

  test('Quran import rejects payload changed after checksum generation', () async {
    final sourceJson = _syntheticQuranImportJson().replaceFirst(
      'نص اختباري 1:1',
      'نص معدل 1:1',
    );

    expect(
      () => store.importQuranJson(sourceJson),
      throwsFormatException,
    );
    expect(await store.hasQuranDataset, isFalse);
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
