import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quran payload checksum excludes manifest metadata', () {
    final payload = <String, dynamic>{
      'surahs': [
        {'surahNumber': 1, 'ayahCount': 7},
      ],
      'ayahs': [
        {'surahNumber': 1, 'ayahNumber': 1, 'textUthmani': 'نص محفوظ'},
      ],
    };
    final first = calculateQuranPayloadSha256(payload);
    payload['manifest'] = {'sha256': first, 'importedAt': '2026-11-24'};
    expect(calculateQuranPayloadSha256(payload), first);
  });

  test('Quran payload checksum changes when canonical text changes', () {
    final payload = <String, dynamic>{
      'surahs': [
        {'surahNumber': 1, 'ayahCount': 1},
      ],
      'ayahs': [
        {'surahNumber': 1, 'ayahNumber': 1, 'textUthmani': 'النص'},
      ],
    };
    final first = calculateQuranPayloadSha256(payload);
    payload['ayahs'][0]['textUthmani'] = 'النص المعدل';
    expect(calculateQuranPayloadSha256(payload), isNot(first));
  });
}
