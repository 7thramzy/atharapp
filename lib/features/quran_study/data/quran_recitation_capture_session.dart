import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

import '../domain/quran_recitation_aligner.dart';
import 'quran_offline_recognizer.dart';

typedef QuranRecitationProgressCallback = void Function(
  QuranAsrRecognitionResult recognition,
  QuranRecitationAlignment alignment,
);

typedef QuranRecitationErrorCallback = void Function(Object error);

/// Short-window PCM microphone capture with on-device-only recognition.
///
/// The service keeps a bounded four-second PCM window in memory, reuses a
/// two-second overlap to stabilize word matching, and never writes an audio
/// file or sends microphone data over the network.
class QuranRecitationCaptureSession {
  QuranRecitationCaptureSession({
    required QuranOfflineRecognizer recognizer,
    required List<QuranExpectedWord> expectedWords,
    QuranRecitationAligner aligner = const QuranRecitationAligner(),
    this.sampleRate = 16000,
    this.windowDuration = const Duration(seconds: 4),
    this.windowHop = const Duration(seconds: 2),
  }) : _recognizer = recognizer,
       _expectedWords = List.unmodifiable(expectedWords),
       _aligner = aligner;

  final QuranOfflineRecognizer _recognizer;
  final List<QuranExpectedWord> _expectedWords;
  final QuranRecitationAligner _aligner;
  final AudioRecorder _recorder = AudioRecorder();

  final int sampleRate;
  final Duration windowDuration;
  final Duration windowHop;

  StreamSubscription<Uint8List>? _subscription;
  final List<int> _pcmWindow = [];
  int _bytesSinceInference = 0;
  int _confirmedThroughExclusive = 0;
  bool _processing = false;
  bool _started = false;
  bool _stopped = false;

  int get confirmedThroughExclusive => _confirmedThroughExclusive;
  bool get isRecording => _started && !_stopped;

  int get _bytesPerWindow => sampleRate * 2 * windowDuration.inSeconds;
  int get _bytesPerHop => sampleRate * 2 * windowHop.inSeconds;

  Future<void> start({
    required QuranRecitationProgressCallback onProgress,
    QuranRecitationErrorCallback? onError,
  }) async {
    if (_started) throw StateError('This recitation session has already started.');
    if (_expectedWords.isEmpty) {
      throw ArgumentError('Select at least one Quran word before starting.');
    }
    if (sampleRate != 16000) {
      throw ArgumentError.value(sampleRate, 'sampleRate');
    }
    if (!await _recorder.hasPermission()) {
      throw StateError('Microphone permission was not granted.');
    }

    _progressCallback = onProgress;
    _errorCallback = onError;
    try {
      final stream = await _recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
      ),
    );
      _subscription = stream.listen(
        _onAudioData,
        onError: (Object error, StackTrace stack) {
          _errorCallback?.call(error);
        },
        onDone: () {
          if (!_stopped) {
            _errorCallback?.call(StateError('Microphone stream ended.'));
          }
        },
        cancelOnError: false,
      );
      _started = true;
    } catch (_) {
      _progressCallback = null;
      _errorCallback = null;
      _started = false;
      _recorder.dispose();
      rethrow;
    }
  }

  QuranRecitationProgressCallback? _progressCallback;
  QuranRecitationErrorCallback? _errorCallback;

  void _onAudioData(Uint8List chunk) {
    if (_stopped || chunk.isEmpty) return;
    _pcmWindow.addAll(chunk);
    _bytesSinceInference += chunk.length;

    if (_pcmWindow.length > _bytesPerWindow) {
      final overflow = _pcmWindow.length - _bytesPerWindow;
      _pcmWindow.removeRange(0, overflow);
    }
    _scheduleInference();
  }

  void _scheduleInference() {
    if (_stopped || _processing || _bytesSinceInference < _bytesPerHop) {
      return;
    }
    _processing = true;
    _bytesSinceInference = 0;
    final snapshot = Uint8List.fromList(_pcmWindow);
    unawaited(_runInference(snapshot));
  }

  Future<void> _runInference(Uint8List pcm) async {
    try {
      final recognition = _recognizer.recognizePcm16(
        pcm,
        sampleRate: sampleRate,
      );
      if (recognition.text.trim().isEmpty || _stopped) return;
      final alignment = _aligner.align(
        transcript: recognition.text,
        expectedWords: _expectedWords,
        previousConfirmedThrough: _confirmedThroughExclusive,
      );
      if (alignment.confirmedThroughExclusive > _confirmedThroughExclusive) {
        _confirmedThroughExclusive = alignment.confirmedThroughExclusive;
      }
      _progressCallback?.call(
        recognition,
        alignment.confirmedThroughExclusive == _confirmedThroughExclusive
            ? alignment
            : QuranRecitationAlignment(
                state: alignment.state,
                confirmedThroughExclusive: _confirmedThroughExclusive,
                activeExpectedWord: alignment.activeExpectedWord,
                heardWords: alignment.heardWords,
                matchedNewWords: alignment.matchedNewWords,
                exactMatchRatio: alignment.exactMatchRatio,
              ),
      );
    } catch (error) {
      _errorCallback?.call(error);
    } finally {
      pcm.fillRange(0, pcm.length, 0);
      _processing = false;
      if (!_stopped && _bytesSinceInference >= _bytesPerHop) {
        _scheduleInference();
      }
    }
  }

  /// Stops the microphone and clears the in-memory rolling audio window.
  Future<void> stop() async {
    if (_stopped) return;
    _stopped = true;
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _recorder.stop();
    } finally {
      _recorder.dispose();
      _pcmWindow.fillRange(0, _pcmWindow.length, 0);
      _pcmWindow.clear();
      _bytesSinceInference = 0;
      _progressCallback = null;
      _errorCallback = null;
    }
  }
}
