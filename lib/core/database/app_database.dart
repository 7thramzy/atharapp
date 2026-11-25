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
  AppDatabase()
    : super(
        driftDatabase(
          name: 'athaar',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createFeatureTables();
      await _createOfflineStudyTables();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await _createFeatureTables();
      }
      if (from < 3) {
        await _createOfflineStudyTables();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createFeatureTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS quran_content_manifest (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        source TEXT NOT NULL,
        source_url TEXT NOT NULL,
        edition TEXT NOT NULL,
        version TEXT NOT NULL,
        sha256 TEXT NOT NULL,
        license_notice TEXT NOT NULL,
        imported_at TEXT NOT NULL,
        surah_count INTEGER NOT NULL,
        ayah_count INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS quran_surahs (
        surah_number INTEGER PRIMARY KEY CHECK (surah_number BETWEEN 1 AND 114),
        name_arabic TEXT NOT NULL,
        name_transliteration TEXT NOT NULL,
        ayah_count INTEGER NOT NULL CHECK (ayah_count > 0)
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS quran_ayahs (
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL CHECK (ayah_number > 0),
        text_uthmani TEXT NOT NULL,
        normalized_text TEXT NOT NULL,
        juz_number INTEGER,
        page_number INTEGER,
        PRIMARY KEY (surah_number, ayah_number),
        FOREIGN KEY (surah_number) REFERENCES quran_surahs(surah_number) ON DELETE CASCADE
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS quran_bookmarks (
        id TEXT PRIMARY KEY,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE (surah_number, ayah_number)
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS quran_notes (
        id TEXT PRIMARY KEY,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        note TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS adhkar_categories (
        id TEXT PRIMARY KEY,
        name_ar TEXT NOT NULL,
        name_en TEXT NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS adhkar_items (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        text_ar TEXT NOT NULL,
        target_count INTEGER NOT NULL CHECK (target_count > 0),
        source_reference TEXT NOT NULL,
        source_verified INTEGER NOT NULL DEFAULT 0 CHECK (source_verified IN (0, 1)),
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES adhkar_categories(id) ON DELETE CASCADE
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS adhkar_progress (
        item_id TEXT NOT NULL,
        local_date TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 0 CHECK (count >= 0),
        updated_at TEXT NOT NULL,
        PRIMARY KEY (item_id, local_date),
        FOREIGN KEY (item_id) REFERENCES adhkar_items(id) ON DELETE CASCADE
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS memorization_progress (
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        status TEXT NOT NULL CHECK (status IN ('not_started', 'learning', 'needs_revision', 'stable')),
        updated_at TEXT NOT NULL,
        PRIMARY KEY (surah_number, ayah_number)
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS memorization_sessions (
        id TEXT PRIMARY KEY,
        surah_number INTEGER NOT NULL,
        start_ayah INTEGER NOT NULL,
        end_ayah INTEGER NOT NULL,
        outcome TEXT NOT NULL CHECK (outcome IN ('learning', 'needs_revision', 'stable')),
        notes TEXT NOT NULL DEFAULT '',
        started_at TEXT NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createOfflineStudyTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS quran_offline_study_packs (
        content_type TEXT NOT NULL CHECK (content_type IN ('tafsir', 'translation')),
        edition_key TEXT NOT NULL,
        surah_number INTEGER NOT NULL CHECK (surah_number BETWEEN 1 AND 114),
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        language_code TEXT NOT NULL DEFAULT 'ar',
        direction TEXT NOT NULL DEFAULT 'rtl',
        version TEXT NOT NULL,
        source_url TEXT NOT NULL,
        license_notice TEXT NOT NULL,
        source_last_updated INTEGER,
        verse_count INTEGER NOT NULL DEFAULT 0,
        downloaded_at TEXT NOT NULL,
        PRIMARY KEY (content_type, edition_key, surah_number)
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS quran_offline_study_verses (
        content_type TEXT NOT NULL,
        edition_key TEXT NOT NULL,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL CHECK (ayah_number > 0),
        text TEXT NOT NULL,
        footnotes TEXT NOT NULL DEFAULT '',
        PRIMARY KEY (content_type, edition_key, surah_number, ayah_number),
        FOREIGN KEY (content_type, edition_key, surah_number)
          REFERENCES quran_offline_study_packs(content_type, edition_key, surah_number)
          ON DELETE CASCADE
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_quran_offline_study_lookup ON quran_offline_study_verses(content_type, edition_key, surah_number, ayah_number)',
    );
  }

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
        AppMetadataCompanion.insert(key: 'schema_version', value: '3'),
      );
    });
  }

  Future<LocalSetting?> getLocalSettings() => (select(
    localSettings,
  )..where((row) => row.id.equals(1))).getSingleOrNull();

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

  Future<ReadingPosition?> getReadingPosition() => (select(
    readingPositions,
  )..where((row) => row.id.equals(1))).getSingleOrNull();

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

  Future<void> saveMetadata({required String key, required String value}) =>
      into(appMetadata).insertOnConflictUpdate(
        AppMetadataCompanion.insert(
          key: key,
          value: value,
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
}
