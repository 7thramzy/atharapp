import 'dart:async';

import 'package:athaar/features/audio_capture/audio_capture_controller.dart';
import 'package:athaar/features/audio_capture/audio_capture_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioCaptureController', () {
    late FakeAudioCaptureGateway gateway;
    late ProviderContainer container;
    late ProviderSubscription<AudioCaptureState> subscription;
    late AudioCaptureController controller;
    late bool containerDisposed;

    setUp(() {
      containerDisposed = false;
      gateway = FakeAudioCaptureGateway();
      container = ProviderContainer(
        overrides: [
          audioCaptureGatewayProvider.overrideWith((ref) {
            ref.onDispose(() => unawaited(gateway.dispose()));
            return gateway;
          }),
        ],
      );
      subscription = container.listen(
        audioCaptureControllerProvider,
        (previous, next) {},
        fireImmediately: true,
      );
      controller = container.read(audioCaptureControllerProvider.notifier);
    });

    tearDown(() async {
      if (!containerDisposed) {
        subscription.close();
        container.dispose();
      }
      await Future<void>.delayed(Duration.zero);
    });

    test('denied microphone permission never starts capture', () async {
      gateway.permissionGranted = false;
      await controller.prepare();
      await controller.start();

      expect(
        container.read(audioCaptureControllerProvider).error,
        AudioCaptureError.permissionDenied,
      );
      expect(gateway.startCalls, 0);
    });

    test('starts, stops, plays, and deletes an in-memory path', () async {
      await controller.prepare();
      await controller.start();
      expect(
        container.read(audioCaptureControllerProvider).status,
        AudioCaptureStatus.recording,
      );

      await controller.stop();
      expect(
        container.read(audioCaptureControllerProvider).status,
        AudioCaptureStatus.recorded,
      );
      expect(
        container.read(audioCaptureControllerProvider).filePath,
        FakeAudioCaptureGateway.recordingPath,
      );

      await controller.play();
      expect(gateway.playedPaths, [FakeAudioCaptureGateway.recordingPath]);
      expect(
        container.read(audioCaptureControllerProvider).status,
        AudioCaptureStatus.recorded,
      );

      await controller.deleteRecording();
      expect(gateway.deletedPaths, [FakeAudioCaptureGateway.recordingPath]);
      expect(
        container.read(audioCaptureControllerProvider).status,
        AudioCaptureStatus.idle,
      );
      expect(container.read(audioCaptureControllerProvider).filePath, isNull);
    });

    test(
      'reports playback failure without losing the temporary recording',
      () async {
        gateway.playFailure = true;
        await controller.prepare();
        await controller.start();
        await controller.stop();
        await controller.play();

        final state = container.read(audioCaptureControllerProvider);
        expect(state.status, AudioCaptureStatus.recorded);
        expect(state.error, AudioCaptureError.playbackFailed);
        expect(state.filePath, FakeAudioCaptureGateway.recordingPath);
      },
    );

    test(
      'does not start if the app leaves foreground during permission',
      () async {
        final permission = Completer<bool>();
        gateway.permissionCompleter = permission;
        await controller.prepare();

        final starting = controller.start();
        await Future<void>.delayed(Duration.zero);
        controller.setForeground(false);
        controller.setForeground(true);
        permission.complete(true);
        await starting;

        expect(gateway.startCalls, 0);
        expect(
          container.read(audioCaptureControllerProvider).status,
          AudioCaptureStatus.idle,
        );
      },
    );

    test(
      'disposing the provider cancels and deletes an active recording',
      () async {
        await controller.prepare();
        await controller.start();

        container.dispose();
        containerDisposed = true;
        await Future<void>.delayed(Duration.zero);

        expect(gateway.disposeCalls, 1);
        expect(gateway.cancelCalls, 1);
        expect(gateway.deletedPaths, [FakeAudioCaptureGateway.recordingPath]);
      },
    );
  });
}

class FakeAudioCaptureGateway implements AudioCaptureGateway {
  static const recordingPath = '/tmp/athaar_capture_test.wav';

  bool permissionGranted = true;
  bool playFailure = false;
  Completer<bool>? permissionCompleter;
  int startCalls = 0;
  int cancelCalls = 0;
  int disposeCalls = 0;
  final List<String> playedPaths = [];
  final List<String> deletedPaths = [];

  @override
  Future<void> prepare() async {}

  @override
  Future<bool> requestMicrophonePermission() =>
      permissionCompleter?.future ?? Future<bool>.value(permissionGranted);

  @override
  Future<String> startRecording() async {
    startCalls++;
    return recordingPath;
  }

  @override
  Future<String?> stopRecording() async => recordingPath;

  @override
  Future<void> cancelRecording() async {
    cancelCalls++;
    deletedPaths.add(recordingPath);
  }

  @override
  Future<void> play(String filePath) async {
    if (playFailure) {
      throw StateError('Synthetic playback failure.');
    }
    playedPaths.add(filePath);
  }

  @override
  Future<void> stopPlayback() async {}

  @override
  Future<void> deleteRecording(String filePath) async {
    deletedPaths.add(filePath);
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
    await cancelRecording();
  }
}
