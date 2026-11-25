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
    await database.customStatement(
      '''INSERT INTO quran_surahs(
           surah_number, name_arabic, name_transliteration, ayah_count
         ) VALUES(1, 'الفاتحة', 'Al-Fatihah', 7)''',
    );
    store = AthaarFeatureStore(database);
  });

  tearDown(() async => database.close());

  test('reading position stores its coordinate and explicit reading mode', () async {
    await store.saveReadingPosition(
      2,
      255,
      readingMode: 'hafs_mushaf',
    );

    final position = await store.getReadingPosition();

    expect(position?.surahNumber, 2);
    expect(position?.ayahNumber, 255);
    expect(position?.readingMode, 'hafs_mushaf');
  });

  test('unspecified reading mode retains the legacy surah default', () async {
    await store.saveReadingPosition(3, 8);

    final position = await store.getReadingPosition();

    expect(position?.surahNumber, 3);
    expect(position?.ayahNumber, 8);
    expect(position?.readingMode, 'surah');
  });

  test('offline tafsir is cached verbatim with its source attribution', () async {
    const tafsirText = 'نص التفسير كما ورد من المصدر، دون أي تعديل.';
    await store.saveOfflineStudyPack(
      contentType: 'tafsir',
      editionKey: 'ar-tafsir-al-jami-al-wajiz',
      surahNumber: 1,
      title: 'الجامع الوجيز',
      description: 'المؤلف',
      version: 'v1.2.3',
      sourceUrl: 'https://example.com/edition',
      licenseNotice: 'CC BY-ND 4.0',
      verses: [
        {
          'surahNumber': 1,
          'ayahNumber': 1,
          'text': tafsirText,
        },
      ],
    );

    final verse = await store.getOfflineStudyVerse(
      contentType: 'tafsir',
      editionKey: 'ar-tafsir-al-jami-al-wajiz',
      surahNumber: 1,
      ayahNumber: 1,
    );
    expect(verse?['text'], tafsirText);
    expect(verse?['license_notice'], 'CC BY-ND 4.0');
    expect(verse?['version'], 'v1.2.3');
  });

  test('a complete translation pack stores footnotes and metadata locally', () async {
    final verses = List.generate(
      7,
      (index) => <String, Object?>{
        'surahNumber': 1,
        'ayahNumber': index + 1,
        'translation': 'Meaning ${index + 1}',
        'footnotes': index == 0 ? 'A publisher footnote' : '',
      },
    );
    await store.saveOfflineStudyPack(
      contentType: 'translation',
      editionKey: 'test-translation',
      surahNumber: 1,
      title: 'Test translation',
      description: 'Verified test edition',
      languageCode: 'en',
      direction: 'ltr',
      version: '3',
      sourceUrl: 'https://quranenc.com/en/home/api',
      licenseNotice: 'QuranEnc attribution',
      sourceLastUpdated: 1700000000,
      requireCompleteTranslation: true,
      verses: verses,
    );

    final cached = await store.getOfflineStudyVerse(
      contentType: 'translation',
      editionKey: 'test-translation',
      surahNumber: 1,
      ayahNumber: 1,
    );
    expect(cached?['text'], 'Meaning 1');
    expect(cached?['footnotes'], 'A publisher footnote');
    expect(cached?['direction'], 'ltr');
    expect(cached?['source_last_updated'], 1700000000);
  });

  test('an incomplete replacement is rejected and preserves the old pack', () async {
    await store.saveOfflineStudyPack(
      contentType: 'translation',
      editionKey: 'test-translation',
      surahNumber: 1,
      title: 'Old translation',
      version: '1',
      sourceUrl: 'https://quranenc.com/en/home/api',
      licenseNotice: 'QuranEnc',
      requireCompleteTranslation: true,
      verses: List.generate(
        7,
        (index) => {
          'surahNumber': 1,
          'ayahNumber': index + 1,
          'translation': 'Old ${index + 1}',
        },
      ),
    );

    await expectLater(
      store.saveOfflineStudyPack(
        contentType: 'translation',
        editionKey: 'test-translation',
        surahNumber: 1,
        title: 'Broken replacement',
        version: '2',
        sourceUrl: 'https://quranenc.com/en/home/api',
        licenseNotice: 'QuranEnc',
        requireCompleteTranslation: true,
        verses: [
          {
            'surahNumber': 1,
            'ayahNumber': 1,
            'translation': 'New text',
          },
        ],
      ),
      throwsFormatException,
    );

    final retained = await store.getOfflineStudyVerse(
      contentType: 'translation',
      editionKey: 'test-translation',
      surahNumber: 1,
      ayahNumber: 1,
    );
    expect(retained?['text'], 'Old 1');
    expect(retained?['version'], '1');
  });

  test('deleting an offline pack cascades to its verse content', () async {
    await store.saveOfflineStudyPack(
      contentType: 'tafsir',
      editionKey: 'test-tafsir',
      surahNumber: 1,
      title: 'Test tafsir',
      version: '1',
      sourceUrl: 'https://example.com',
      licenseNotice: 'Test license',
      verses: [
        {'surahNumber': 1, 'ayahNumber': 1, 'text': 'Text'},
      ],
    );

    await store.deleteOfflineStudyPack(
      contentType: 'tafsir',
      editionKey: 'test-tafsir',
      surahNumber: 1,
    );
    final verse = await store.getOfflineStudyVerse(
      contentType: 'tafsir',
      editionKey: 'test-tafsir',
      surahNumber: 1,
      ayahNumber: 1,
    );
    expect(verse, isNull);
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
