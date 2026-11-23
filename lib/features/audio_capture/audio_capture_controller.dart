import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_capture_gateway.dart';

enum AudioCaptureStatus {
  preparing,
  idle,
  requestingPermission,
  recording,
  stopping,
  recorded,
  playing,
  deleting,
}

enum AudioCaptureError {
  preparationFailed,
  permissionDenied,
  recordingFailed,
  playbackFailed,
  deletionFailed,
}

class AudioCaptureState {
  const AudioCaptureState({
    required this.status,
    this.filePath,
    this.error,
  });

  final AudioCaptureStatus status;
  final String? filePath;
  final AudioCaptureError? error;

  bool get isBusy =>
      status == AudioCaptureStatus.preparing ||
      status == AudioCaptureStatus.requestingPermission ||
      status == AudioCaptureStatus.stopping ||
      status == AudioCaptureStatus.deleting;
}

final audioCaptureControllerProvider = NotifierProvider.autoDispose<
  AudioCaptureController,
  AudioCaptureState
>(AudioCaptureController.new);

class AudioCaptureController extends Notifier<AudioCaptureState> {
  late AudioCaptureGateway _gateway;
  Future<void>? _prepareFuture;
  bool _disposed = false;
  bool _isForeground = true;
  int _foregroundGeneration = 0;

  @override
  AudioCaptureState build() {
    _disposed = false;
    _gateway = ref.watch(audioCaptureGatewayProvider);
    ref.onDispose(() => _disposed = true);
    return const AudioCaptureState(status: AudioCaptureStatus.preparing);
  }

  Future<void> prepare() => _prepareFuture ??= _prepare();

  Future<void> _prepare() async {
    try {
      await _gateway.prepare();
      if (_disposed) {
        return;
      }
      state = const AudioCaptureState(status: AudioCaptureStatus.idle);
    } catch (_) {
      if (!_disposed) {
        state = const AudioCaptureState(
          status: AudioCaptureStatus.idle,
          error: AudioCaptureError.preparationFailed,
        );
      }
    }
  }

  void setForeground(bool isForeground) {
    _isForeground = isForeground;
    if (!isForeground) {
      _foregroundGeneration++;
      if (state.status == AudioCaptureStatus.recording) {
        unawaited(stop());
      } else if (state.status == AudioCaptureStatus.playing) {
        unawaited(stopPlayback());
      }
    }
  }

  Future<void> start() async {
    if (_disposed ||
        !_isForeground ||
        state.status != AudioCaptureStatus.idle) {
      return;
    }

    final requestGeneration = _foregroundGeneration;
    state = const AudioCaptureState(
      status: AudioCaptureStatus.requestingPermission,
    );

    try {
      final hasPermission = await _gateway.requestMicrophonePermission();
      if (_disposed) {
        return;
      }
      if (requestGeneration != _foregroundGeneration || !_isForeground) {
        state = const AudioCaptureState(status: AudioCaptureStatus.idle);
        return;
      }
      if (!hasPermission) {
        state = const AudioCaptureState(
          status: AudioCaptureStatus.idle,
          error: AudioCaptureError.permissionDenied,
        );
        return;
      }

      final filePath = await _gateway.startRecording();
      if (_disposed ||
          requestGeneration != _foregroundGeneration ||
          !_isForeground) {
        await _cancelQuietly();
        if (!_disposed) {
          state = const AudioCaptureState(status: AudioCaptureStatus.idle);
        }
        return;
      }
      state = AudioCaptureState(
        status: AudioCaptureStatus.recording,
        filePath: filePath,
      );
    } catch (_) {
      await _cancelQuietly();
      if (!_disposed) {
        state = const AudioCaptureState(
          status: AudioCaptureStatus.idle,
          error: AudioCaptureError.recordingFailed,
        );
      }
    }
  }

  Future<void> stop() async {
    if (_disposed || state.status != AudioCaptureStatus.recording) {
      return;
    }

    final currentPath = state.filePath;
    state = AudioCaptureState(
      status: AudioCaptureStatus.stopping,
      filePath: currentPath,
    );

    try {
      final stoppedPath = await _gateway.stopRecording();
      if (_disposed) {
        return;
      }
      final filePath = stoppedPath ?? currentPath;
      if (filePath == null) {
        await _cancelQuietly();
        state = const AudioCaptureState(
          status: AudioCaptureStatus.idle,
          error: AudioCaptureError.recordingFailed,
        );
        return;
      }
      state = AudioCaptureState(
        status: AudioCaptureStatus.recorded,
        filePath: filePath,
      );
    } catch (_) {
      await _cancelQuietly();
      if (!_disposed) {
        state = const AudioCaptureState(
          status: AudioCaptureStatus.idle,
          error: AudioCaptureError.recordingFailed,
        );
      }
    }
  }

  Future<void> play() async {
    final filePath = state.filePath;
    if (_disposed ||
        state.status != AudioCaptureStatus.recorded ||
        filePath == null) {
      return;
    }

    state = AudioCaptureState(
      status: AudioCaptureStatus.playing,
      filePath: filePath,
    );
    try {
      await _gateway.play(filePath);
      if (!_disposed && state.status == AudioCaptureStatus.playing) {
        state = AudioCaptureState(
          status: AudioCaptureStatus.recorded,
          filePath: filePath,
        );
      }
    } catch (_) {
      if (!_disposed) {
        state = AudioCaptureState(
          status: AudioCaptureStatus.recorded,
          filePath: filePath,
          error: AudioCaptureError.playbackFailed,
        );
      }
    }
  }

  Future<void> stopPlayback() async {
    if (_disposed || state.status != AudioCaptureStatus.playing) {
      return;
    }

    final filePath = state.filePath;
    try {
      await _gateway.stopPlayback();
      if (!_disposed) {
        state = AudioCaptureState(
          status: AudioCaptureStatus.recorded,
          filePath: filePath,
        );
      }
    } catch (_) {
      if (!_disposed) {
        state = AudioCaptureState(
          status: AudioCaptureStatus.recorded,
          filePath: filePath,
          error: AudioCaptureError.playbackFailed,
        );
      }
    }
  }

  Future<void> deleteRecording() async {
    if (_disposed || state.filePath == null) {
      return;
    }

    final filePath = state.filePath!;
    state = AudioCaptureState(
      status: AudioCaptureStatus.deleting,
      filePath: filePath,
    );
    try {
      await _gateway.deleteRecording(filePath);
      if (!_disposed) {
        state = const AudioCaptureState(status: AudioCaptureStatus.idle);
      }
    } catch (_) {
      if (!_disposed) {
        state = AudioCaptureState(
          status: AudioCaptureStatus.recorded,
          filePath: filePath,
          error: AudioCaptureError.deletionFailed,
        );
      }
    }
  }

  Future<void> _cancelQuietly() async {
    try {
      await _gateway.cancelRecording();
    } catch (_) {
      // The gateway also retries best-effort cleanup when it is disposed.
    }
  }
}
