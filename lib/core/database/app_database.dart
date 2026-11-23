import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class LocalSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  TextColumn get locale => text().withDefault(const Constant('ar'))();

  TextColumn get themeMode => text().withDefault(const Constant('system'))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ReadingPositions extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  IntColumn get surahNumber => integer().withDefault(const Constant(1))();

  IntColumn get ayahNumber => integer().withDefault(const Constant(1))();

  TextColumn get readingMode => text().withDefault(const Constant('surah'))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class AppMetadata extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [LocalSettings, ReadingPositions, AppMetadata])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'athaar'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> initializeDefaults() async {
    await transaction(() async {
      await into(localSettings).insertOnConflictUpdate(
        const LocalSettingsCompanion(
          id: Value(1),
          locale: Value('ar'),
          themeMode: Value('system'),
        ),
      );

      final existingPosition = await getReadingPosition();
      if (existingPosition == null) {
        await into(readingPositions).insert(
          const ReadingPositionsCompanion(
            id: Value(1),
            surahNumber: Value(1),
            ayahNumber: Value(1),
            readingMode: Value('surah'),
          ),
        );
      }

      await into(appMetadata).insertOnConflictUpdate(
        AppMetadataCompanion.insert(key: 'schema_version', value: '1'),
      );
    });
  }

  Future<LocalSetting?> getLocalSettings() {
    return (select(
      localSettings,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
  }

  Future<void> updateLocalSettings({String? locale, String? themeMode}) async {
    final current = await getLocalSettings();

    await into(localSettings).insertOnConflictUpdate(
      LocalSettingsCompanion(
        id: const Value(1),
        locale: Value(locale ?? current?.locale ?? 'ar'),
        themeMode: Value(themeMode ?? current?.themeMode ?? 'system'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<ReadingPosition?> getReadingPosition() {
    return (select(
      readingPositions,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
  }

  Future<void> saveReadingPosition({
    required int surahNumber,
    required int ayahNumber,
    String readingMode = 'surah',
  }) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw RangeError.range(surahNumber, 1, 114, 'surahNumber');
    }
    if (ayahNumber < 1) {
      throw RangeError.value(ayahNumber, 'ayahNumber', 'must be positive');
    }

    await into(readingPositions).insertOnConflictUpdate(
      ReadingPositionsCompanion(
        id: const Value(1),
        surahNumber: Value(surahNumber),
        ayahNumber: Value(ayahNumber),
        readingMode: Value(readingMode),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> saveMetadata({required String key, required String value}) {
    return into(appMetadata).insertOnConflictUpdate(
      AppMetadataCompanion.insert(
        key: key,
        value: value,
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}
