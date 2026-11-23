import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('bundled Tanzil dataset imports all canonical surahs and ayahs', () async {
    final source = await rootBundle.loadString('assets/content/quran/tanzil-uthmani-v1.1.json');
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.initializeDefaults();
    final store = AthaarFeatureStore(database);
    await store.importQuranJson(source);
    expect(await store.surahCount, 114);
    expect(await store.ayahCount, 6236);
    final manifest = await store.quranManifest;
    expect(manifest?['source'], 'Tanzil Quran Text');
    expect(manifest?['version'], '1.1');
    expect(manifest?['license_notice'], isNotEmpty);
    expect(await store.getSurahAyahs(1), hasLength(7));
  });
}
