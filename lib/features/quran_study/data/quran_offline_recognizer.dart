import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart';

import 'quran_asr_model_manager.dart';

class QuranAsrRecognitionResult {
  const QuranAsrRecognitionResult({
    required this.text,
    required this.tokens,
    required this.tokenTimestampsSeconds,
  });

  final String text;
  final List<String> tokens;
  final List<double> tokenTimestampsSeconds;
}

/// Offline Sherpa-ONNX decoder for Abdou/quran-asr-small.
///
/// It accepts short PCM16 microphone windows and returns only text/tokens in
/// memory. This class does not persist or upload the supplied microphone data.
class QuranOfflineRecognizer {
  QuranOfflineRecognizer._(this._recognizer);

  final OfflineRecognizer _recognizer;
  bool _disposed = false;

  factory QuranOfflineRecognizer.fromInstalledModel(
    QuranAsrModelFiles files, {
    int numThreads = 2,
  }) {
    final model = OfflineModelConfig(
      zipformerCtc: OfflineZipformerCtcModelConfig(
        model: files.modelFile.path,
      ),
      tokens: files.tokensFile.path,
      numThreads: numThreads.clamp(1, 4),
      debug: false,
      provider: 'cpu',
    );
    final recognizer = OfflineRecognizer(
      OfflineRecognizerConfig(
        model: model,
        feat: const FeatureConfig(sampleRate: 16000, featureDim: 80),
        decodingMethod: 'greedy_search',
      ),
    );
    return QuranOfflineRecognizer._(recognizer);
  }

  QuranAsrRecognitionResult recognizePcm16(
    Uint8List pcm16Bytes, {
    int sampleRate = 16000,
  }) {
    if (_disposed) {
      throw StateError('The offline Quran recognizer has been disposed.');
    }
    if (sampleRate != 16000) {
      throw ArgumentError.value(
        sampleRate,
        'sampleRate',
        'The pinned Quran ASR model expects 16000 Hz audio.',
      );
    }

    final usableBytes = pcm16Bytes.length - (pcm16Bytes.length % 2);
    if (usableBytes < 2) {
      return const QuranAsrRecognitionResult(
        text: '',
        tokens: [],
        tokenTimestampsSeconds: [],
      );
    }

    final samples = pcm16ToFloat32(pcm16Bytes, byteLength: usableBytes);
    final stream = _recognizer.createStream();
    try {
      stream.acceptWaveform(samples: samples, sampleRate: sampleRate);
      _recognizer.decode(stream);
      final result = _recognizer.getResult(stream);
      return QuranAsrRecognitionResult(
        text: result.text,
        tokens: List.unmodifiable(result.tokens),
        tokenTimestampsSeconds: List.unmodifiable(result.timestamps),
      );
    } finally {
      stream.free();
      samples.fillRange(0, samples.length, 0);
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _recognizer.free();
  }

  static Float32List pcm16ToFloat32(
    Uint8List bytes, {
    int? byteLength,
  }) {
    final length = byteLength ?? bytes.length;
    if (length < 0 || length > bytes.length || length.isOdd) {
      throw ArgumentError.value(length, 'byteLength');
    }
    final sampleCount = length ~/ 2;
    final samples = Float32List(sampleCount);
    final data = ByteData.sublistView(bytes, 0, length);
    for (var i = 0; i < sampleCount; i++) {
      samples[i] = data.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return samples;
  }
}
