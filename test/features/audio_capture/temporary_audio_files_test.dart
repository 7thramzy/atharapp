import 'dart:io';

import 'package:athaar/features/audio_capture/audio_capture_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemporaryAudioFiles', () {
    late Directory temporaryRoot;
    late TemporaryAudioFiles files;

    setUp(() async {
      temporaryRoot = await Directory.systemTemp.createTemp(
        'athaar_audio_test_',
      );
      files = TemporaryAudioFiles(
        temporaryDirectoryProvider: () async => temporaryRoot,
      );
    });

    tearDown(() async {
      if (await temporaryRoot.exists()) {
        await temporaryRoot.delete(recursive: true);
      }
    });

    test('creates captures in a dedicated temporary directory', () async {
      final capturePath = await files.createRecordingPath();
      final expectedDirectory =
          '${temporaryRoot.path}${Platform.pathSeparator}'
          '${TemporaryAudioFiles.directoryName}';

      expect(File(capturePath).parent.path, expectedDirectory);
      expect(
        File(capturePath).uri.pathSegments.last,
        startsWith(TemporaryAudioFiles.filePrefix),
      );
      expect(capturePath, endsWith(TemporaryAudioFiles.fileExtension));
    });

    test('clears only feature-owned stale audio files', () async {
      final capturePath = await files.createRecordingPath();
      final staleCapture = File(capturePath)..writeAsStringSync('private');
      final featureDirectory = staleCapture.parent;
      final unrelatedFile = File(
        '${featureDirectory.path}${Platform.pathSeparator}keep.txt',
      )..writeAsStringSync('unrelated');
      final parentFile = File(
        '${temporaryRoot.path}${Platform.pathSeparator}keep.txt',
      )..writeAsStringSync('outside feature directory');

      await files.deleteStaleRecordings();

      expect(await staleCapture.exists(), isFalse);
      expect(await unrelatedFile.exists(), isTrue);
      expect(await parentFile.exists(), isTrue);
    });

    test('rejects deletion outside the feature cache namespace', () async {
      final outsidePath =
          '${temporaryRoot.path}${Platform.pathSeparator}private.wav';

      await expectLater(
        files.deleteRecording(outsidePath),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
