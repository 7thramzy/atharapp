import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quran payload checksum excludes manifest metadata', () {
    final surahs = <Map<String, dynamic>>[
      {'surahNumber': 1, 'ayahCount': 7},
    ];
    final ayahs = <Map<String, dynamic>>[
      {'surahNumber': 1, 'ayahNumber': 1, 'textUthmani': 'نص محفوظ'},
    ];
    final payload = <String, dynamic>{'surahs': surahs, 'ayahs': ayahs};

    final first = calculateQuranPayloadSha256(payload);
    payload['manifest'] = {'sha256': first, 'importedAt': '2026-11-24'};
    expect(calculateQuranPayloadSha256(payload), first);
  });

  test('Quran payload checksum changes when canonical text changes', () {
    final surahs = <Map<String, dynamic>>[
      {'surahNumber': 1, 'ayahCount': 1},
    ];
    final ayahs = <Map<String, dynamic>>[
      {'surahNumber': 1, 'ayahNumber': 1, 'textUthmani': 'النص'},
    ];
    final payload = <String, dynamic>{'surahs': surahs, 'ayahs': ayahs};

    final first = calculateQuranPayloadSha256(payload);
    ayahs[0]['textUthmani'] = 'النص المعدل';
    expect(calculateQuranPayloadSha256(payload), isNot(first));
  });
}
