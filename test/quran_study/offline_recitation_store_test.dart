import 'dart:io';

import 'package:athaar/features/quran_study/data/offline_recitation_store_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('OfflineRecitationStore', () {
    late Directory sandbox;

    setUp(() async {
      sandbox = await Directory.systemTemp.createTemp('athaar-audio-test-');
    });

    tearDown(() async {
      if (await sandbox.exists()) {
        await sandbox.delete(recursive: true);
      }
    });

    test(
      'downloads one surah privately and falls back to an available bitrate',
      () async {
        final requested = <Uri>[];
        final client = MockClient((request) async {
          requested.add(request.url);
          if (request.url.path.contains('/128/')) {
            return http.Response('not found', 404);
          }
          return http.Response.bytes(
            <int>[0x49, 0x44, 0x33, 0x04, 0x05],
            200,
            headers: const {'content-type': 'audio/mpeg'},
          );
        });
        final store = OfflineRecitationStore(
          client: client,
          supportDirectory: () async => sandbox,
        );
        addTearDown(store.close);

        final path = await store.downloadSurah(edition: 'ar.husary', surah: 1);
        final file = File(path);

        expect(await file.exists(), isTrue);
        expect(await file.length(), 5);
        expect(requested.map((uri) => uri.path), [
          '/quran/audio-surah/128/ar.husary/1.mp3',
          '/quran/audio-surah/64/ar.husary/1.mp3',
        ]);
        expect(
          await store.isSurahDownloaded(edition: 'ar.husary', surah: 1),
          isTrue,
        );
        expect(await store.downloadedSurahs('ar.husary'), {1});
      },
    );

    test('does not replace a downloaded file with an empty response', () async {
      final client = MockClient((request) async {
        return http.Response.bytes(const <int>[], 200);
      });
      final store = OfflineRecitationStore(
        client: client,
        supportDirectory: () async => sandbox,
      );
      addTearDown(store.close);

      await expectLater(
        store.downloadSurah(edition: 'ar.husary', surah: 1),
        throwsFormatException,
      );
      expect(
        await store.isSurahDownloaded(edition: 'ar.husary', surah: 1),
        isFalse,
      );
    });

    test('validates edition identifiers and surah numbers', () async {
      final store = OfflineRecitationStore(
        client: MockClient((request) async => http.Response('unused', 200)),
        supportDirectory: () async => sandbox,
      );
      addTearDown(store.close);

      await expectLater(
        store.downloadSurah(edition: '../outside', surah: 1),
        throwsArgumentError,
      );
      await expectLater(
        store.downloadSurah(edition: 'ar.husary', surah: 115),
        throwsRangeError,
      );
    });

    test('deletes one surah and all files for an edition', () async {
      final client = MockClient(
        (request) async => http.Response.bytes([1, 2, 3], 200),
      );
      final store = OfflineRecitationStore(
        client: client,
        supportDirectory: () async => sandbox,
      );
      addTearDown(store.close);

      await store.downloadSurah(edition: 'ar.husary', surah: 1);
      await store.downloadSurah(edition: 'ar.husary', surah: 2);
      await store.deleteSurah(edition: 'ar.husary', surah: 1);
      expect(await store.downloadedSurahs('ar.husary'), {2});

      await store.deleteAllForEdition('ar.husary');
      expect(await store.downloadedSurahs('ar.husary'), isEmpty);
    });
  });
}
