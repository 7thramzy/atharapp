import 'dart:convert';

import 'package:athaar/features/quran_study/data/quran_study_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('QuranStudyRepository', () {
    test('parses the publisher translation catalogue and version metadata', () async {
      final repository = QuranStudyRepository(
        client: MockClient((request) async {
          expect(request.url.host, 'quranenc.com');
          expect(request.url.path, '/api/v1/translations/list/');
          expect(request.url.queryParameters['localization'], 'ar');
          return http.Response(
            jsonEncode({
              'translations': [
                {
                  'key': 'english_rwwad',
                  'title': 'English Translation - Rowwad',
                  'language_iso_code': 'en',
                  'version': '1.0.21',
                  'description': 'Translated by Rowwad Translation Center',
                  'direction': 'ltr',
                  'last_update': 1772061267,
                }
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(repository.close);

      final editions = await repository.getTranslations();

      expect(editions, hasLength(1));
      expect(editions.single.key, 'english_rwwad');
      expect(editions.single.version, '1.0.21');
      expect(editions.single.languageCode, 'en');
      expect(editions.single.direction, 'ltr');
      expect(editions.single.description, contains('Rowwad'));
    });

    test('parses translation text and footnotes without rewriting either', () async {
      const translation = 'In the name of Allah.[1]';
      const footnotes = '[1] Publisher footnote.';
      final repository = QuranStudyRepository(
        client: MockClient((request) async {
          expect(
            request.url.path,
            '/api/v1/translation/aya/english_rwwad/1/1',
          );
          return http.Response(
            jsonEncode({
              'result': {
                'id': '1',
                'sura': '1',
                'aya': '1',
                'translation': translation,
                'footnotes': footnotes,
              },
            }),
            200,
          );
        }),
      );
      addTearDown(repository.close);

      final result = await repository.getTranslation(
        key: 'english_rwwad',
        surah: 1,
        ayah: 1,
      );

      expect(result.text, translation);
      expect(result.footnotes, footnotes);
      expect(result.surahNumber, 1);
      expect(result.ayahNumber, 1);
    });

    test('loads the Arabic Al-Jami Al-Wajiz tafsir verbatim from the pinned edition', () async {
      const tafsirText = 'نص التفسير كما ورد من المؤلف دون تعديل.';
      final repository = QuranStudyRepository(
        client: MockClient((request) async {
          expect(request.url.host, 'cdn.jsdelivr.net');
          expect(
            request.url.path,
            '/gh/spa5k/tafsir_api@v1.2.3/tafsir/ar-tafsir-al-jami-al-wajiz/1/1.json',
          );
          return http.Response(
            jsonEncode({
              'text': tafsirText,
              'surah': 1,
              'ayah': 1,
            }),
            200,
          );
        }),
      );
      addTearDown(repository.close);

      final result = await repository.getTafsir(surah: 1, ayah: 1);

      expect(result.text, tafsirText);
      expect(result.surahNumber, 1);
      expect(result.ayahNumber, 1);
    });

    test('parses verse-by-verse Arabic reciter editions', () async {
      final repository = QuranStudyRepository(
        client: MockClient((request) async {
          expect(request.url.host, 'api.alquran.cloud');
          expect(request.url.path, '/v1/edition');
          expect(request.url.queryParameters['format'], 'audio');
          expect(request.url.queryParameters['language'], 'ar');
          expect(request.url.queryParameters['type'], 'versebyverse');
          return http.Response(
            jsonEncode({
              'code': 200,
              'status': 'OK',
              'data': [
                {
                  'identifier': 'ar.husary',
                  'name': 'محمود خليل الحصري',
                  'englishName': 'Husary',
                  'format': 'audio',
                  'type': 'versebyverse',
                }
              ],
            }),
            200,
          );
        }),
      );
      addTearDown(repository.close);

      final editions = await repository.getAudioEditions();

      expect(editions, hasLength(1));
      expect(editions.single.identifier, 'ar.husary');
      expect(editions.single.displayName, 'محمود خليل الحصري');
    });

    test('accepts only HTTPS audio URLs returned by the provider', () async {
      final repository = QuranStudyRepository(
        client: MockClient((request) async {
          expect(request.url.path, '/v1/ayah/1:1/ar.husary');
          return http.Response(
            jsonEncode({
              'code': 200,
              'status': 'OK',
              'data': {
                'audio': 'https://cdn.islamic.network/quran/audio/128/ar.husary/1.mp3'
              },
            }),
            200,
          );
        }),
      );
      addTearDown(repository.close);

      final uri = await repository.getAyahAudioUri(
        surah: 1,
        ayah: 1,
        edition: 'ar.husary',
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'cdn.islamic.network');
    });

    test('returns every validated audio track for an offline surah download', () async {
      final repository = QuranStudyRepository(
        client: MockClient((request) async {
          expect(request.url.host, 'api.alquran.cloud');
          expect(request.url.path, '/v1/surah/1/ar.husary');
          return http.Response(
            jsonEncode({
              'code': 200,
              'status': 'OK',
              'data': {
                'ayahs': [
                  {
                    'numberInSurah': 1,
                    'audio': 'https://cdn.islamic.network/quran/audio/128/ar.husary/1.mp3',
                  },
                  {
                    'numberInSurah': 2,
                    'audio': 'https://cdn.islamic.network/quran/audio/128/ar.husary/2.mp3',
                  },
                ],
              },
            }),
            200,
          );
        }),
      );
      addTearDown(repository.close);

      final tracks = await repository.getSurahAudioTracks(
        surah: 1,
        edition: 'ar.husary',
      );

      expect(tracks, hasLength(2));
      expect(tracks.map((track) => track.numberInSurah), [1, 2]);
      expect(tracks.every((track) => track.uri.scheme == 'https'), isTrue);
    });

    test('rejects incomplete or untrusted surah audio track maps', () async {
      final repository = QuranStudyRepository(
        client: MockClient((request) async => http.Response(
          jsonEncode({
            'data': {
              'ayahs': [
                {
                  'numberInSurah': 1,
                  'audio': 'https://example.com/not-the-provider.mp3',
                },
              ],
            },
          }),
          200,
        )),
      );
      addTearDown(repository.close);

      expect(
        () => repository.getSurahAudioTracks(
          surah: 1,
          edition: 'ar.husary',
        ),
        throwsFormatException,
      );
    });

    test('rejects invalid Quran references before sending a request', () async {
      final repository = QuranStudyRepository(
        client: MockClient((request) async {
          fail('No request should be sent for an invalid reference.');
        }),
      );
      addTearDown(repository.close);

      expect(
        () => repository.getTranslation(key: 'english_rwwad', surah: 0, ayah: 1),
        throwsRangeError,
      );
    });

    test('rejects a non-HTTPS audio source', () async {
      final repository = QuranStudyRepository(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {'audio': 'http://example.com/audio.mp3'}
            }),
            200,
          );
        }),
      );
      addTearDown(repository.close);

      expect(
        () => repository.getAyahAudioUri(
          surah: 1,
          ayah: 1,
          edition: 'ar.husary',
        ),
        throwsFormatException,
      );
    });
  });
}
