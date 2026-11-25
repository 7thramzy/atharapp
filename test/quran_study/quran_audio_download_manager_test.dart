import 'dart:io';

import 'package:athaar/features/quran_study/data/quran_audio_download_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory temporaryDirectory;
  late QuranAudioDownloadManager manager;

  const audioBytes = <int>[1, 2, 3, 4, 5, 6];
  const audioUri = 'https://download.quranicaudio.com/qdc/test_reciter/1.mp3';

  QuranChapterAudioAsset asset({
    Uri? uri,
    int fileSizeBytes = audioBytes.length,
  }) =>
      QuranChapterAudioAsset(
        sourceId: 'chapter-recitation-1',
        reciterId: 'reciter-7',
        reciterName: 'Test reciter',
        surahNumber: 1,
        audioUri: uri ?? Uri.parse(audioUri),
        fileSizeBytes: fileSizeBytes,
        format: 'mp3',
      );

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'athaar-quran-audio-test-',
    );
  });

  tearDown(() async {
    manager.close();
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('requires an explicit user download request', () async {
    manager = QuranAudioDownloadManager(
      client: MockClient((_) async => http.Response.bytes(audioBytes, 200)),
      privateDirectoryProvider: () async => temporaryDirectory,
    );

    await expectLater(
      manager.download(asset(), userRequested: false),
      throwsStateError,
    );
  });

  test('downloads an approved recording to private storage and lists it', () async {
    manager = QuranAudioDownloadManager(
      client: MockClient((request) async {
        expect(request.url.host, 'download.quranicaudio.com');
        return http.Response.bytes(audioBytes, 200);
      }),
      privateDirectoryProvider: () async => temporaryDirectory,
    );

    final progress = <int>[];
    final downloaded = await manager.download(
      asset(),
      userRequested: true,
      onProgress: (received, expected) {
        expect(expected, audioBytes.length);
        progress.add(received);
      },
    );

    expect(await downloaded.file.readAsBytes(), audioBytes);
    expect(downloaded.publisher, 'Quran Foundation');
    expect(downloaded.surahNumber, 1);
    expect(progress, isNotEmpty);

    final records = await manager.listDownloads();
    expect(records, hasLength(1));
    expect(records.single.sourceId, 'chapter-recitation-1');
    expect(await manager.usedStorageBytes, audioBytes.length);
  });

  test('rejects audio URLs outside the approved HTTPS hosts', () async {
    manager = QuranAudioDownloadManager(
      client: MockClient((_) async => http.Response.bytes(audioBytes, 200)),
      privateDirectoryProvider: () async => temporaryDirectory,
    );

    expect(
      () => manager.download(
        asset(uri: Uri.parse('https://example.com/audio.mp3')),
        userRequested: true,
      ),
      throwsArgumentError,
    );
  });

  test('rejects non-HTTPS audio URLs', () async {
    manager = QuranAudioDownloadManager(
      client: MockClient((_) async => http.Response.bytes(audioBytes, 200)),
      privateDirectoryProvider: () async => temporaryDirectory,
    );

    expect(
      () => manager.download(
        asset(uri: Uri.parse('http://download.quranicaudio.com/audio.mp3')),
        userRequested: true,
      ),
      throwsArgumentError,
    );
  });

  test('enforces the storage limit before requesting the file', () async {
    var requested = false;
    manager = QuranAudioDownloadManager(
      client: MockClient((_) async {
        requested = true;
        return http.Response.bytes(audioBytes, 200);
      }),
      privateDirectoryProvider: () async => temporaryDirectory,
      maxStorageBytes: 4,
    );

    await expectLater(
      manager.download(asset(), userRequested: true),
      throwsA(isA<QuranAudioStorageLimitException>()),
    );
    expect(requested, isFalse);
  });

  test('discards an incomplete response and leaves no visible download', () async {
    manager = QuranAudioDownloadManager(
      client: MockClient((_) async => http.Response.bytes([1, 2], 200)),
      privateDirectoryProvider: () async => temporaryDirectory,
    );

    await expectLater(
      manager.download(asset(), userRequested: true),
      throwsA(isA<QuranAudioDownloadException>()),
    );

    expect(await manager.listDownloads(), isEmpty);
    expect(await manager.usedStorageBytes, 0);
    final directory = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}quran_audio',
    );
    if (await directory.exists()) {
      final files = await directory.list().toList();
      expect(files, isEmpty);
    }
  });

  test('deletes a download when its source is removed', () async {
    manager = QuranAudioDownloadManager(
      client: MockClient((_) async => http.Response.bytes(audioBytes, 200)),
      privateDirectoryProvider: () async => temporaryDirectory,
    );

    final downloaded = await manager.download(
      asset(),
      userRequested: true,
    );
    expect(await downloaded.file.exists(), isTrue);

    await manager.deleteRemovedSources({'chapter-recitation-1'});

    expect(await downloaded.file.exists(), isFalse);
    expect(await manager.listDownloads(), isEmpty);
    expect(await manager.usedStorageBytes, 0);
  });

  test('does not download the same source concurrently', () async {
    manager = QuranAudioDownloadManager(
      client: MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return http.Response.bytes(audioBytes, 200);
      }),
      privateDirectoryProvider: () async => temporaryDirectory,
    );

    final first = manager.download(asset(), userRequested: true);
    await expectLater(
      manager.download(asset(), userRequested: true),
      throwsStateError,
    );
    await first;
  });
}
