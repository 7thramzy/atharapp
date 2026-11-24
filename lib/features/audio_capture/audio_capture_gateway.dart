import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

abstract interface class AudioCaptureGateway {
  Future<void> prepare();
  Future<bool> requestMicrophonePermission();
  Future<String> startRecording();
  Future<String?> stopRecording();
  Future<void> cancelRecording();
  Future<void> play(String filePath);
  Future<void> stopPlayback();
  Future<void> deleteRecording(String filePath);
  Future<void> dispose();
}

class TemporaryAudioFiles {
  TemporaryAudioFiles({
    Future<Directory> Function()? temporaryDirectoryProvider,
  }) : _temporaryDirectoryProvider =
           temporaryDirectoryProvider ?? getTemporaryDirectory;

  static const directoryName = 'athaar_audio_capture';
  static const filePrefix = 'athaar_capture_';
  static const fileExtension = '.wav';

  final Future<Directory> Function() _temporaryDirectoryProvider;

  Future<Directory> _directory() async {
    final temporaryDirectory = await _temporaryDirectoryProvider();
    final directory = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}$directoryName',
    );
    await directory.create(recursive: true);
    return directory;
  }

  Future<String> createRecordingPath() async {
    final directory = await _directory();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    var suffix = 0;
    late File file;

    do {
      final suffixPart = suffix == 0 ? '' : '_$suffix';
      file = File(
        '${directory.path}${Platform.pathSeparator}'
        '$filePrefix$timestamp$suffixPart$fileExtension',
      );
      suffix++;
    } while (await file.exists());

    return file.path;
  }

  Future<void> deleteStaleRecordings() async {
    final directory = await _directory();
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File && _isCaptureFile(entity.path)) {
        await entity.delete();
      }
    }
  }

  Future<void> deleteRecording(String filePath) async {
    final directory = await _directory();
    final file = File(filePath);
    if (file.parent.absolute.path != directory.absolute.path ||
        !_isCaptureFile(file.path)) {
      throw ArgumentError.value(filePath, 'filePath', 'Not an Athaar capture.');
    }
    if (await file.exists()) {
      await file.delete();
    }
  }

  bool _isCaptureFile(String filePath) {
    final name = filePath.split(Platform.pathSeparator).last;
    return name.startsWith(filePrefix) && name.endsWith(fileExtension);
  }
}

class PluginAudioCaptureGateway implements AudioCaptureGateway {
  PluginAudioCaptureGateway({
    AudioRecorder? recorder,
    AudioPlayer? player,
    TemporaryAudioFiles? files,
  }) : _recorder = recorder ?? AudioRecorder(),
       _player = player ?? AudioPlayer(),
       _files = files ?? TemporaryAudioFiles();

  final AudioRecorder _recorder;
  final AudioPlayer _player;
  final TemporaryAudioFiles _files;
  String? _activeFilePath;
  bool _isRecording = false;
  bool _isDisposed = false;

  @override
  Future<void> prepare() => _files.deleteStaleRecordings();

  @override
  Future<bool> requestMicrophonePermission() => _recorder.hasPermission();

  @override
  Future<String> startRecording() async {
    _ensureNotDisposed();
    final filePath = await _files.createRecordingPath();

    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: filePath,
      );
      _activeFilePath = filePath;
      _isRecording = true;
      return filePath;
    } catch (_) {
      await _deleteQuietly(filePath);
      rethrow;
    }
  }

  @override
  Future<String?> stopRecording() async {
    _ensureNotDisposed();
    if (!_isRecording) {
      return _activeFilePath;
    }

    final stoppedPath = await _recorder.stop();
    _isRecording = false;
    _activeFilePath = stoppedPath ?? _activeFilePath;
    return _activeFilePath;
  }

  @override
  Future<void> cancelRecording() async {
    if (!_isRecording) {
      return;
    }

    final filePath = _activeFilePath;
    try {
      await _recorder.cancel();
    } finally {
      _isRecording = false;
      if (filePath != null) {
        await _deleteQuietly(filePath);
      }
      _activeFilePath = null;
    }
  }

  @override
  Future<void> play(String filePath) async {
    _ensureNotDisposed();
    await _player.setFilePath(filePath);
    await _player.play();
  }

  @override
  Future<void> stopPlayback() => _player.stop();

  @override
  Future<void> deleteRecording(String filePath) async {
    await _player.stop();
    await _files.deleteRecording(filePath);
    if (_activeFilePath == filePath) {
      _activeFilePath = null;
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    if (_isRecording) {
      try {
        await _recorder.cancel();
      } catch (_) {
        // Continue with best-effort deletion and native resource cleanup.
      }
      _isRecording = false;
    }

    try {
      await _player.stop();
    } catch (_) {
      // Player may already be released by the platform.
    }

    final filePath = _activeFilePath;
    _activeFilePath = null;
    if (filePath != null) {
      await _deleteQuietly(filePath);
    }

    try {
      await _player.dispose();
    } catch (_) {
      // A disposed player must not prevent recorder disposal.
    }
    try {
      await _recorder.dispose();
    } catch (_) {
      // Disposal is best-effort; stale cache cleanup runs on the next entry.
    }
  }

  Future<void> _deleteQuietly(String filePath) async {
    try {
      await _files.deleteRecording(filePath);
    } catch (_) {
      // Cache cleanup on the next feature entry is the final safety net.
    }
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('Audio capture gateway is disposed.');
    }
  }
}

final audioCaptureGatewayProvider = Provider.autoDispose<AudioCaptureGateway>((
  ref,
) {
  final gateway = PluginAudioCaptureGateway();
  ref.onDispose(() => unawaited(gateway.dispose()));
  return gateway;
});
