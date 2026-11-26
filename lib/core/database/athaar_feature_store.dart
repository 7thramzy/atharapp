import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/database_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

/// Computes the deterministic checksum for the ordered Quran import payload.
/// The manifest is intentionally excluded so it can contain this checksum.
String calculateQuranPayloadSha256(Map<String, dynamic> decoded) {
  final payload = <String, dynamic>{
    'surahs': decoded['surahs'],
    'ayahs': decoded['ayahs'],
  };
  return sha256.convert(utf8.encode(jsonEncode(payload))).toString();
}

final athaarFeatureStoreProvider = Provider<AthaarFeatureStore>(
  (ref) => AthaarFeatureStore(ref.watch(appDatabaseProvider)),
);

class AthaarFeatureStore {
  AthaarFeatureStore(this.db);
  final AppDatabase db;

  String _id() {
    final random = Random.secure();
    final chars = List<int>.generate(16, (_) => random.nextInt(256));
    chars[6] = (chars[6] & 0x0f) | 0x40;
    chars[8] = (chars[8] & 0x3f) | 0x80;
    final hex = chars.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  String get _now => DateTime.now().toUtc().toIso8601String();
  String get _today =>
      DateTime.now().toLocal().toIso8601String().substring(0, 10);

  Future<bool> get hasQuranDataset async =>
      (await db
              .customSelect(
                'SELECT id FROM quran_content_manifest WHERE id = 1',
              )
              .get())
          .isNotEmpty;

  Future<Map<String, Object?>?> get quranManifest async {
    final rows = await db
        .customSelect('SELECT * FROM quran_content_manifest WHERE id = 1')
        .get();
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.first;
    return {
      'source': row.read<String>('source'),
      'source_url': row.read<String>('source_url'),
      'edition': row.read<String>('edition'),
      'version': row.read<String>('version'),
      'sha256': row.read<String>('sha256'),
      'license_notice': row.read<String>('license_notice'),
      'ayah_count': row.read<int>('ayah_count'),
    };
  }

  Future<int> get ayahCount async =>
      (await db.customSelect('SELECT COUNT(*) AS c FROM quran_ayahs').get())
          .first
          .read<int>('c');

  Future<int> get surahCount async =>
      (await db.customSelect('SELECT COUNT(*) AS c FROM quran_surahs').get())
          .first
          .read<int>('c');

  Future<List<Map<String, Object?>>> listSurahs() async {
    final rows = await db
        .customSelect('SELECT * FROM quran_surahs ORDER BY surah_number')
        .get();
    return rows
        .map(
          (r) => <String, Object?>{
            'number': r.read<int>('surah_number'),
            'name': r.read<String>('name_arabic'),
            'transliteration': r.read<String>('name_transliteration'),
            'ayah_count': r.read<int>('ayah_count'),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> searchAyahs(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }
    final rows = await db
        .customSelect(
          '''SELECT a.surah_number, a.ayah_number, a.text_uthmani, s.name_arabic
         FROM quran_ayahs a JOIN quran_surahs s USING(surah_number)
         WHERE a.normalized_text LIKE ? ORDER BY a.surah_number, a.ayah_number LIMIT 100''',
          variables: [Variable.withString('%$trimmed%')],
        )
        .get();
    return rows
        .map(
          (r) => <String, Object?>{
            'surah_number': r.read<int>('surah_number'),
            'ayah_number': r.read<int>('ayah_number'),
            'text': r.read<String>('text_uthmani'),
            'surah_name': r.read<String>('name_arabic'),
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> getSurahAyahs(int surah) async {
    final rows = await db
        .customSelect(
          'SELECT ayah_number, text_uthmani FROM quran_ayahs WHERE surah_number = ? ORDER BY ayah_number',
          variables: [Variable.withInt(surah)],
        )
        .get();
    return rows
        .map(
          (r) => <String, Object?>{
            'number': r.read<int>('ayah_number'),
            'text': r.read<String>('text_uthmani'),
          },
        )
        .toList();
  }

  Future<ReadingPosition?> getReadingPosition() => db.getReadingPosition();

  Future<void> saveReadingPosition(int surah, int ayah) =>
      db.saveReadingPosition(surahNumber: surah, ayahNumber: ayah);

  Future<void> addBookmark(int surah, int ayah) => db.customStatement(
    'INSERT OR IGNORE INTO quran_bookmarks(id, surah_number, ayah_number, created_at) VALUES(?, ?, ?, ?)',
    [_id(), surah, ayah, _now],
  );

  Future<List<Map<String, Object?>>> listBookmarks() async {
    final rows = await db
        .customSelect(
          'SELECT b.surah_number, b.ayah_number, s.name_arabic FROM quran_bookmarks b LEFT JOIN quran_surahs s USING(surah_number) ORDER BY b.created_at DESC',
        )
        .get();
    return rows
        .map(
          (r) => <String, Object?>{
            'surah': r.read<int>('surah_number'),
            'ayah': r.read<int>('ayah_number'),
            'name': r.readNullable<String>('name_arabic') ?? 'سورة',
          },
        )
        .toList();
  }

  Future<void> saveNote(int surah, int ayah, String note) async {
    final existing = await db
        .customSelect(
          'SELECT id FROM quran_notes WHERE surah_number = ? AND ayah_number = ?',
          variables: [Variable.withInt(surah), Variable.withInt(ayah)],
        )
        .get();
    if (existing.isEmpty) {
      await db.customStatement(
        'INSERT INTO quran_notes(id, surah_number, ayah_number, note, created_at, updated_at) VALUES(?, ?, ?, ?, ?, ?)',
        [_id(), surah, ayah, note, _now, _now],
      );
    } else {
      await db.customStatement(
        'UPDATE quran_notes SET note = ?, updated_at = ? WHERE id = ?',
        [note, _now, existing.first.read<String>('id')],
      );
    }
  }

  Future<void> createAdhkarItem({
    required String textArabic,
    required int targetCount,
    required String sourceReference,
  }) async {
    if (textArabic.trim().isEmpty || sourceReference.trim().isEmpty) {
      throw ArgumentError('Text and source reference are required.');
    }
    if (targetCount < 1 || targetCount > 10000) {
      throw RangeError.range(targetCount, 1, 10000, 'targetCount');
    }
    const categoryId = 'personal';
    await db.customStatement(
      'INSERT OR IGNORE INTO adhkar_categories(id, name_ar, name_en) VALUES(?, ?, ?)',
      [categoryId, 'أذكاري', 'My adhkar'],
    );
    await db.customStatement(
      'INSERT INTO adhkar_items(id, category_id, text_ar, target_count, source_reference, source_verified, created_at) VALUES(?, ?, ?, ?, ?, 0, ?)',
      [
        _id(),
        categoryId,
        textArabic.trim(),
        targetCount,
        sourceReference.trim(),
        _now,
      ],
    );
  }

  Future<List<Map<String, Object?>>> listAdhkar() async {
    final rows = await db
        .customSelect(
          '''SELECT i.id, i.text_ar, i.target_count, i.source_reference, i.source_verified,
         COALESCE(p.count, 0) AS today_count
         FROM adhkar_items i LEFT JOIN adhkar_progress p
         ON p.item_id = i.id AND p.local_date = ? ORDER BY i.created_at''',
          variables: [Variable.withString(_today)],
        )
        .get();
    return rows
        .map(
          (r) => <String, Object?>{
            'id': r.read<String>('id'),
            'text': r.read<String>('text_ar'),
            'target': r.read<int>('target_count'),
            'source': r.read<String>('source_reference'),
            'verified': r.read<int>('source_verified') == 1,
            'count': r.read<int>('today_count'),
          },
        )
        .toList();
  }

  Future<void> incrementAdhkar(String id) async {
    await db.transaction(() async {
      final rows = await db
          .customSelect(
            'SELECT count FROM adhkar_progress WHERE item_id = ? AND local_date = ?',
            variables: [Variable.withString(id), Variable.withString(_today)],
          )
          .get();
      final count = rows.isEmpty ? 0 : rows.first.read<int>('count');
      await db.customStatement(
        '''INSERT INTO adhkar_progress(item_id, local_date, count, updated_at) VALUES(?, ?, ?, ?)
           ON CONFLICT(item_id, local_date) DO UPDATE SET count = excluded.count, updated_at = excluded.updated_at''',
        [id, _today, count + 1, _now],
      );
    });
  }

  Future<void> setMemorizationStatus(int surah, int ayah, String status) async {
    const allowed = ['not_started', 'learning', 'needs_revision', 'stable'];
    if (!allowed.contains(status)) {
      throw ArgumentError.value(status, 'status');
    }
    await db.customStatement(
      '''INSERT INTO memorization_progress(surah_number, ayah_number, status, updated_at) VALUES(?, ?, ?, ?)
         ON CONFLICT(surah_number, ayah_number) DO UPDATE SET status = excluded.status, updated_at = excluded.updated_at''',
      [surah, ayah, status, _now],
    );
  }

  Future<void> recordMemorizationSession({
    required int surah,
    required int startAyah,
    required int endAyah,
    required String outcome,
    String notes = '',
  }) async {
    if (startAyah < 1 || endAyah < startAyah) {
      throw ArgumentError('Invalid ayah range.');
    }
    if (!['learning', 'needs_revision', 'stable'].contains(outcome)) {
      throw ArgumentError.value(outcome, 'outcome');
    }
    await db.transaction(() async {
      for (var ayah = startAyah; ayah <= endAyah; ayah++) {
        await setMemorizationStatus(surah, ayah, outcome);
      }
      await db.customStatement(
        'INSERT INTO memorization_sessions(id, surah_number, start_ayah, end_ayah, outcome, notes, started_at, completed_at) VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
        [_id(), surah, startAyah, endAyah, outcome, notes, _now, _now],
      );
    });
  }

  Future<Map<String, int>> memorizationSummary() async {
    final rows = await db
        .customSelect(
          'SELECT status, COUNT(*) AS c FROM memorization_progress GROUP BY status',
        )
        .get();
    final result = <String, int>{
      'learning': 0,
      'needs_revision': 0,
      'stable': 0,
      'not_started': 0,
    };
    for (final row in rows) {
      result[row.read<String>('status')] = row.read<int>('c');
    }
    return result;
  }

  Future<Map<String, int>> personalImpactSummary() async {
    final bookmarks =
        (await db
                .customSelect('SELECT COUNT(*) AS c FROM quran_bookmarks')
                .get())
            .first
            .read<int>('c');
    final notes =
        (await db.customSelect('SELECT COUNT(*) AS c FROM quran_notes').get())
            .first
            .read<int>('c');
    final sessions =
        (await db
                .customSelect('SELECT COUNT(*) AS c FROM memorization_sessions')
                .get())
            .first
            .read<int>('c');
    final adhkar =
        (await db
                .customSelect(
                  'SELECT COALESCE(SUM(count), 0) AS c FROM adhkar_progress',
                )
                .get())
            .first
            .read<int>('c');
    final progress = await memorizationSummary();
    return {
      'bookmarks': bookmarks,
      'notes': notes,
      'sessions': sessions,
      'adhkar_counts': adhkar,
      'stable_ayahs': progress['stable'] ?? 0,
      'learning_ayahs': progress['learning'] ?? 0,
    };
  }

  Future<void> importQuranJson(String sourceJson) async {
    final decoded = jsonDecode(sourceJson) as Map<String, dynamic>;
    final manifest = decoded['manifest'] as Map<String, dynamic>;
    final surahs = (decoded['surahs'] as List).cast<Map<String, dynamic>>();
    final ayahs = (decoded['ayahs'] as List).cast<Map<String, dynamic>>();
    final sha = (manifest['sha256'] as String?) ?? '';
    if (surahs.length != 114 || !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(sha)) {
      throw FormatException(
        'The source manifest or 114-surah structure is invalid.',
      );
    }
    for (final key in [
      'source',
      'sourceUrl',
      'edition',
      'version',
      'licenseNotice',
    ]) {
      if ((manifest[key] as String?)?.trim().isNotEmpty != true) {
        throw FormatException('Missing required source manifest field: $key');
      }
    }
    final actualSha = calculateQuranPayloadSha256(decoded);
    if (actualSha.toLowerCase() != sha.toLowerCase()) {
      throw FormatException(
        'The Quran JSON SHA-256 does not match its manifest.',
      );
    }
    const canonicalAyahCounts = [
      7,
      286,
      200,
      176,
      120,
      165,
      206,
      75,
      129,
      109,
      123,
      111,
      43,
      52,
      99,
      128,
      111,
      110,
      98,
      135,
      112,
      78,
      118,
      64,
      77,
      227,
      93,
      88,
      69,
      60,
      34,
      30,
      73,
      54,
      45,
      83,
      182,
      88,
      75,
      85,
      54,
      53,
      89,
      59,
      37,
      35,
      38,
      29,
      18,
      45,
      60,
      49,
      62,
      55,
      78,
      96,
      29,
      22,
      24,
      13,
      14,
      11,
      11,
      18,
      12,
      12,
      30,
      52,
      52,
      44,
      28,
      28,
      20,
      56,
      40,
      31,
      50,
      40,
      46,
      42,
      29,
      19,
      36,
      25,
      22,
      17,
      19,
      26,
      30,
      20,
      15,
      21,
      11,
      8,
      8,
      19,
      5,
      8,
      8,
      11,
      11,
      8,
      3,
      9,
      5,
      4,
      7,
      3,
      6,
      3,
      5,
      4,
      5,
      6,
    ];
    for (var index = 0; index < 114; index++) {
      final surah = surahs[index];
      if (surah['surahNumber'] != index + 1 ||
          surah['ayahCount'] != canonicalAyahCounts[index]) {
        throw FormatException(
          'Unexpected surah order or ayah count at ${index + 1}.',
        );
      }
    }
    final expectedAyahs = canonicalAyahCounts.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    if (ayahs.length != expectedAyahs) {
      throw FormatException(
        'The imported Quran must contain exactly $expectedAyahs ayahs.',
      );
    }
    final seen = <String>{};
    final nextAyahBySurah = <int, int>{};
    for (final ayah in ayahs) {
      final surahNumber = ayah['surahNumber'] as int;
      final ayahNumber = ayah['ayahNumber'] as int;
      final key = '$surahNumber:$ayahNumber';
      final expectedNext = (nextAyahBySurah[surahNumber] ?? 0) + 1;
      if (surahNumber < 1 ||
          surahNumber > 114 ||
          ayahNumber != expectedNext ||
          !seen.add(key) ||
          (ayah['textUthmani'] as String? ?? '').isEmpty) {
        throw FormatException(
          'Duplicate, missing, unordered, or empty ayah: $key',
        );
      }
      nextAyahBySurah[surahNumber] = ayahNumber;
    }
    for (var surahNumber = 1; surahNumber <= 114; surahNumber++) {
      if (nextAyahBySurah[surahNumber] !=
          canonicalAyahCounts[surahNumber - 1]) {
        throw FormatException(
          'Incomplete ayah sequence for surah $surahNumber',
        );
      }
    }
    await db.transaction(() async {
      await db.customStatement('DELETE FROM quran_ayahs');
      await db.customStatement('DELETE FROM quran_surahs');
      for (final surah in surahs) {
        await db.customStatement(
          'INSERT INTO quran_surahs(surah_number, name_arabic, name_transliteration, ayah_count) VALUES(?, ?, ?, ?)',
          [
            surah['surahNumber'] as int,
            surah['nameArabic'] as String,
            surah['nameTransliteration'] as String,
            surah['ayahCount'] as int,
          ],
        );
      }
      for (final ayah in ayahs) {
        await db.customStatement(
          'INSERT INTO quran_ayahs(surah_number, ayah_number, text_uthmani, normalized_text, juz_number, page_number) VALUES(?, ?, ?, ?, ?, ?)',
          [
            ayah['surahNumber'] as int,
            ayah['ayahNumber'] as int,
            ayah['textUthmani'] as String,
            (ayah['normalizedText'] as String?) ??
                ayah['textUthmani'] as String,
            ayah['juzNumber'] as int? ?? 1,
            ayah['pageNumber'] as int? ?? 1,
          ],
        );
      }
      await db.customStatement(
        '''INSERT OR REPLACE INTO quran_content_manifest(id, source, source_url, edition, version, sha256, license_notice, imported_at, surah_count, ayah_count)
           VALUES(1, ?, ?, ?, ?, ?, ?, ?, 114, ?)''',
        [
          manifest['source'] as String,
          manifest['sourceUrl'] as String,
          manifest['edition'] as String,
          manifest['version'] as String,
          sha.toLowerCase(),
          manifest['licenseNotice'] as String,
          _now,
          ayahs.length,
        ],
      );
    });
  }
}
