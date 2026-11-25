import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef AsrModelDownloadProgress = void Function(
  int receivedBytes,
  int? totalBytes,
);

class QuranAsrModelFiles {
  const QuranAsrModelFiles({
    required this.directory,
    required this.modelFile,
    required this.tokensFile,
    required this.revision,
    required this.modelSha256,
  });

  final Directory directory;
  final File modelFile;
  final File tokensFile;
  final String revision;
  final String modelSha256;
}

class QuranAsrModelDownloadException implements Exception {
  const QuranAsrModelDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Optional, pinned, app-private download of Abdou/quran-asr-small.
///
/// Model weights are deliberately excluded from the app bundle. Download is
/// explicit, the quantized model's SHA-256 is pinned, and temporary files are
/// removed if validation fails.
class QuranAsrModelManager {
  QuranAsrModelManager({
    http.Client? client,
    Future<Directory> Function()? privateDirectoryProvider,
  }) : _client = client ?? http.Client(),
       _privateDirectoryProvider =
           privateDirectoryProvider ?? getApplicationSupportDirectory;

  static const modelRevision = '5d36fbd';
  static const modelUrl =
      'https://huggingface.co/Abdou/quran-asr-small/resolve/$modelRevision/model.int8.onnx';
  static const tokensUrl =
      'https://huggingface.co/Abdou/quran-asr-small/resolve/$modelRevision/tokens.txt';
  static const modelSha256 =
      '88f9df290d57b8890275d79187b77515aeeb12626a42bc76cbd0f8bfcaff00f0';
  static const expectedTokensBytes = 180;
  static const maxModelBytes = 64 * 1024 * 1024;

  final http.Client _client;
  final Future<Directory> Function() _privateDirectoryProvider;
  bool _downloading = false;

  void close() => _client.close();

  Future<Directory> _modelDirectory() async {
    final root = await _privateDirectoryProvider();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}quran_asr_small',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<QuranAsrModelFiles?> installedModel() async {
    final directory = await _modelDirectory();
    final model = File(
      '${directory.path}${Platform.pathSeparator}model.int8.onnx',
    );
    final tokens = File(
      '${directory.path}${Platform.pathSeparator}tokens.txt',
    );
    final manifest = File(
      '${directory.path}${Platform.pathSeparator}install.json',
    );
    if (!await model.exists() ||
        !await tokens.exists() ||
        !await manifest.exists()) {
      return null;
    }
    try {
      final metadata = jsonDecode(await manifest.readAsString());
      if (metadata is! Map ||
          metadata['revision'] != modelRevision ||
          metadata['modelSha256'] != modelSha256 ||
          metadata['modelBytes'] != await model.length() ||
          await tokens.length() != expectedTokensBytes) {
        return null;
      }
      return QuranAsrModelFiles(
        directory: directory,
        modelFile: model,
        tokensFile: tokens,
        revision: modelRevision,
        modelSha256: modelSha256,
      );
    } on Object {
      return null;
    }
  }

  Future<QuranAsrModelFiles> download({
    required bool userRequested,
    AsrModelDownloadProgress? onProgress,
  }) async {
    if (!userRequested) {
      throw StateError('The ASR model must be downloaded by explicit user request.');
    }
    if (_downloading) {
      throw StateError('The ASR model is already downloading.');
    }
    _downloading = true;
    File? modelPart;
    File? tokensPart;
    try {
      final installed = await installedModel();
      if (installed != null) return installed;

      final directory = await _modelDirectory();
      final model = File(
        '${directory.path}${Platform.pathSeparator}model.int8.onnx',
      );
      final tokens = File(
        '${directory.path}${Platform.pathSeparator}tokens.txt',
      );
      final manifest = File(
        '${directory.path}${Platform.pathSeparator}install.json',
      );
      modelPart = File('${model.path}.part');
      tokensPart = File('${tokens.path}.part');

      for (final file in [modelPart, tokensPart]) {
        if (await file.exists()) await file.delete();
      }

      final modelBytes = await _downloadFile(
        Uri.parse(modelUrl),
        modelPart,
        maxBytes: maxModelBytes,
        onProgress: onProgress,
      );
      final actualSha = sha256.convert(modelBytes).toString();
      if (actualSha != modelSha256) {
        throw const QuranAsrModelDownloadException(
          'The downloaded ASR model failed its pinned SHA-256 check.',
        );
      }

      final tokenBytes = await _downloadFile(
        Uri.parse(tokensUrl),
        tokensPart,
        maxBytes: 1024,
      );
      if (tokenBytes.length != expectedTokensBytes) {
        throw const QuranAsrModelDownloadException(
          'The model token vocabulary has an unexpected size.',
        );
      }
      final tokenText = utf8.decode(tokenBytes);
      final tokenLines = const LineSplitter().convert(tokenText);
      if (tokenLines.length != 31 ||
          !tokenLines.first.startsWith('<blk> ') ||
          tokenLines.last.trim() != '▁ 30') {
        throw const QuranAsrModelDownloadException(
          'The model token vocabulary is not the expected pinned release.',
        );
      }

      await modelPart.rename(model.path);
      await tokensPart.rename(tokens.path);
      await manifest.writeAsString(
        jsonEncode({
          'repository': 'Abdou/quran-asr-small',
          'revision': modelRevision,
          'modelSha256': modelSha256,
          'modelBytes': modelBytes.length,
          'tokensBytes': tokenBytes.length,
          'license': 'MIT',
          'installedAt': DateTime.now().toUtc().toIso8601String(),
        }),
        flush: true,
      );

      return QuranAsrModelFiles(
        directory: directory,
        modelFile: model,
        tokensFile: tokens,
        revision: modelRevision,
        modelSha256: modelSha256,
      );
    } catch (_) {
      if (modelPart != null && await modelPart.exists()) {
        await modelPart.delete();
      }
      if (tokensPart != null && await tokensPart.exists()) {
        await tokensPart.delete();
      }
      rethrow;
    } finally {
      _downloading = false;
    }
  }

  Future<Uint8List> _downloadFile(
    Uri uri,
    File destination, {
    required int maxBytes,
    AsrModelDownloadProgress? onProgress,
  }) async {
    if (uri.scheme != 'https' || uri.host != 'huggingface.co') {
      throw const QuranAsrModelDownloadException(
        'The model download URL is not an approved HTTPS source.',
      );
    }
    final response = await _client.send(http.Request('GET', uri));
    if (response.statusCode != HttpStatus.ok) {
      throw QuranAsrModelDownloadException(
        'The model source returned HTTP ${response.statusCode}.',
      );
    }
    final declaredSize = response.contentLength;
    if (declaredSize != null && declaredSize > maxBytes) {
      throw const QuranAsrModelDownloadException(
        'The model source exceeded the allowed download size.',
      );
    }

    final builder = BytesBuilder(copy: false);
    final sink = destination.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.stream) {
        received += chunk.length;
        if (received > maxBytes) {
          throw const QuranAsrModelDownloadException(
            'The model download exceeded its maximum allowed size.',
          );
        }
        builder.add(chunk);
        sink.add(chunk);
        onProgress?.call(received, declaredSize);
      }
      await sink.flush();
    } catch (_) {
      await sink.close();
      rethrow;
    }
    await sink.close();

    if (declaredSize != null && received != declaredSize) {
      throw const QuranAsrModelDownloadException(
        'The model download was incomplete.',
      );
    }
    return builder.takeBytes();
  }

  Future<void> deleteInstalledModel() async {
    final directory = await _modelDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
