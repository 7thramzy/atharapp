import 'dart:io';

import 'package:athaar/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDatabase', () {
    late Directory temporaryDirectory;
    late File databaseFile;
    late AppDatabase database;
    var databaseClosed = false;

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'athaar_db_test_',
      );
      databaseFile = File('${temporaryDirectory.path}/athaar_test.sqlite');
      databaseClosed = false;

      database = AppDatabase.forTesting(NativeDatabase(databaseFile));
      await database.initializeDefaults();
    });

    tearDown(() async {
      if (!databaseClosed) {
        await database.close();
      }
      if (await temporaryDirectory.exists()) {
        await temporaryDirectory.delete(recursive: true);
      }
    });

    test(
      'creates default settings, reading position and schema metadata',
      () async {
        expect(database.schemaVersion, 3);

        final settings = await database.getLocalSettings();
        final position = await database.getReadingPosition();
        final metadata = await (database.select(
          database.appMetadata,
        )..where((row) => row.key.equals('schema_version'))).getSingle();

        expect(settings, isNotNull);
        expect(settings!.locale, 'ar');
        expect(settings.themeMode, 'system');

        expect(position, isNotNull);
        expect(position!.surahNumber, 1);
        expect(position.ayahNumber, 1);
        expect(position.readingMode, 'surah');

        expect(metadata.value, '3');
      },
    );

    test('updates user settings without replacing other values', () async {
      await database.updateLocalSettings(locale: 'en');

      var settings = await database.getLocalSettings();
      expect(settings!.locale, 'en');
      expect(settings.themeMode, 'system');

      await database.updateLocalSettings(themeMode: 'dark');

      settings = await database.getLocalSettings();
      expect(settings!.locale, 'en');
      expect(settings.themeMode, 'dark');
    });

    test('saves a validated reading position', () async {
      await database.saveReadingPosition(
        surahNumber: 2,
        ayahNumber: 255,
        readingMode: 'surah',
      );

      final position = await database.getReadingPosition();
      expect(position!.surahNumber, 2);
      expect(position.ayahNumber, 255);
    });

    test('rejects a surah number outside the Quran range', () async {
      await expectLater(
        database.saveReadingPosition(surahNumber: 115, ayahNumber: 1),
        throwsA(isA<RangeError>()),
      );
    });

    test(
      'persists settings and reading position after database reopen',
      () async {
        await database.updateLocalSettings(locale: 'en', themeMode: 'dark');
        await database.saveReadingPosition(surahNumber: 18, ayahNumber: 10);

        await database.close();
        databaseClosed = true;

        final reopened = AppDatabase.forTesting(NativeDatabase(databaseFile));
        try {
          final settings = await reopened.getLocalSettings();
          final position = await reopened.getReadingPosition();

          expect(settings!.locale, 'en');
          expect(settings.themeMode, 'dark');
          expect(position!.surahNumber, 18);
          expect(position.ayahNumber, 10);
        } finally {
          await reopened.close();
        }
      },
    );
  });
}
