import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all 604 QCF page boundaries match every Tanzil Uthmani v1.1 ayah', () async {
    final source = jsonDecode(
      await rootBundle.loadString('assets/content/quran/tanzil-uthmani-v1.1.json'),
    ) as Map<String, dynamic>;

    final surahs = (source['surahs'] as List).cast<Map<String, dynamic>>();
    final ayahs = (source['ayahs'] as List).cast<Map<String, dynamic>>();

    expect(surahs, hasLength(114));
    expect(ayahs, hasLength(6236));

    final expectedPageByAyah = <String, int>{};
    final canonicalTextByAyah = <String, String>{};
    for (final ayah in ayahs) {
      final surah = ayah['surahNumber'] as int;
      final number = ayah['ayahNumber'] as int;
      final key = '$surah:$number';
      expect(expectedPageByAyah.containsKey(key), isFalse, reason: 'Duplicate Tanzil reference ' + key);
      expectedPageByAyah[key] = ayah['pageNumber'] as int;
      canonicalTextByAyah[key] = ayah['textUthmani'] as String;
    }

    final seen = <String>{};
    var visited = 0;
    for (var page = 1; page <= 604; page++) {
      final sections = getPageData(page);
      expect(sections, isNotEmpty, reason: 'QCF page ' + page.toString() + ' is empty');

      for (final rawSection in sections) {
        final section = Map<String, dynamic>.from(rawSection as Map);
        final surah = int.parse(section['surah'].toString());
        final start = int.parse(section['start'].toString());
        final end = int.parse(section['end'].toString());

        expect(surah, inInclusiveRange(1, 114), reason: 'Page ' + page.toString() + ' has invalid surah');
        expect(start, greaterThanOrEqualTo(1), reason: 'Page ' + page.toString() + ' has invalid start');
        expect(end, greaterThanOrEqualTo(start), reason: 'Page ' + page.toString() + ' has reversed range');

        for (var number = start; number <= end; number++) {
          final key = '$surah:$number';
          expect(
            canonicalTextByAyah.containsKey(key),
            isTrue,
            reason: 'QCF page ' + page.toString() + ' references an ayah absent from Tanzil: ' + key,
          );
          expect(
            seen.add(key),
            isTrue,
            reason: 'Ayah ' + key + ' appears more than once in the 604-page QCF map',
          );
          expect(
            expectedPageByAyah[key],
            page,
            reason: 'Page mismatch for ' + key + ': QCF page ' + page.toString() +
                ' vs Tanzil page ' + expectedPageByAyah[key].toString(),
          );
          expect(canonicalTextByAyah[key]!.trim(), isNotEmpty, reason: 'Empty canonical ayah ' + key);
          visited++;
        }
      }
    }

    expect(visited, 6236);
    expect(seen, hasLength(6236));
    expect(seen.contains('1:1'), isTrue);
    expect(seen.contains('114:6'), isTrue);
    expect(expectedPageByAyah['1:1'], 1);
    expect(expectedPageByAyah['114:6'], 604);
  });
}
