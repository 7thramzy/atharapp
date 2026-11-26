import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all 604 QCF pages cover the complete Hafs ayah sequence exactly once',
      () async {
    final source = jsonDecode(
      await rootBundle.loadString('assets/content/quran/tanzil-uthmani-v1.1.json'),
    ) as Map<String, dynamic>;
    final surahs = (source['surahs'] as List).cast<Map<String, dynamic>>();
    final ayahs = (source['ayahs'] as List).cast<Map<String, dynamic>>();

    expect(surahs, hasLength(114));
    expect(ayahs, hasLength(6236));

    // QCF and Tanzil can describe different printed Madinah editions. Page
    // breaks therefore must not be equated across providers; the QCF renderer
    // owns its own page map. Validate canonical ayah order and full coverage.
    final seen = <String>{};
    var visited = 0;
    String? firstReference;
    String? lastReference;

    for (var page = 1; page <= 604; page++) {
      final sections = getPageData(page);
      expect(sections, isNotEmpty, reason: 'QCF page $page is empty');

      for (final rawSection in sections) {
        final section = Map<String, dynamic>.from(rawSection as Map);
        final surah = int.parse(section['surah'].toString());
        final start = int.parse(section['start'].toString());
        final end = int.parse(section['end'].toString());

        expect(surah, inInclusiveRange(1, 114),
            reason: 'Page $page has invalid surah');
        expect(start, greaterThanOrEqualTo(1),
            reason: 'Page $page has invalid start');
        expect(end, greaterThanOrEqualTo(start),
            reason: 'Page $page has reversed range');

        for (var number = start; number <= end; number++) {
          expect(visited, lessThan(ayahs.length),
              reason: 'QCF page $page has more ayahs than the canonical text');
          final canonical = ayahs[visited];
          final expectedSurah = canonical['surahNumber'] as int;
          final expectedAyah = canonical['ayahNumber'] as int;
          final key = '$surah:$number';

          expect(
            surah,
            expectedSurah,
            reason: 'QCF ayah order diverges at index $visited: $key',
          );
          expect(
            number,
            expectedAyah,
            reason: 'QCF ayah order diverges at index $visited: expected $expectedSurah:$expectedAyah, found $key',
          );
          expect(
            seen.add(key),
            isTrue,
            reason: 'Ayah $key appears more than once in the 604-page QCF map',
          );
          expect(
            (canonical['textUthmani'] as String).trim(),
            isNotEmpty,
            reason: 'Canonical Arabic text is empty for $key',
          );

          firstReference ??= key;
          lastReference = key;
          visited++;
        }
      }
    }

    expect(visited, 6236);
    expect(seen, hasLength(6236));
    expect(firstReference, '1:1');
    expect(lastReference, '114:6');
  });
}
