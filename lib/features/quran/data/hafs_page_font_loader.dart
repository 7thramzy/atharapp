import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart' show QcfFontLoader;

/// Loads requested Hafs page fonts from the package assets into browser memory.
///
/// The upstream QCF loader writes extracted fonts through path_provider. That
/// is not available on Web, so this page-scoped loader uses the same packaged
/// fonts and family names without any filesystem access.
class HafsPageFontLoader {
  HafsPageFontLoader._();

  static final Set<int> _loadedPages = <int>{};
  static final Map<int, Future<void>> _loadingPages = <int, Future<void>>{};

  static bool isPageLoaded(int pageNumber) =>
      _loadedPages.contains(pageNumber);

  static Future<void> ensurePageLoaded(int pageNumber) {
    if (pageNumber < 1 || pageNumber > 604) {
      return Future<void>.error(
        RangeError.range(pageNumber, 1, 604, 'pageNumber'),
      );
    }

    if (_loadedPages.contains(pageNumber)) {
      return Future<void>.value();
    }

    final existing = _loadingPages[pageNumber];
    if (existing != null) return existing;

    late final Future<void> task;
    task = _loadPage(pageNumber)
        .then((_) => _loadedPages.add(pageNumber))
        .whenComplete(() => _loadingPages.remove(pageNumber));
    _loadingPages[pageNumber] = task;
    return task;
  }

  static Future<void> _loadPage(int pageNumber) async {
    final baseFamily = QcfFontLoader.getBaseFontFamily(pageNumber);
    final assetPath =
        'packages/qcf_quran_plus/assets/fonts/qcf_tajweed/$baseFamily.ttf.gz';
    final compressedData = await rootBundle.load(assetPath);
    final compressedBytes = compressedData.buffer.asUint8List(
      compressedData.offsetInBytes,
      compressedData.lengthInBytes,
    );
    final fontBytes = Uint8List.fromList(
      const GZipDecoder().decodeBytes(compressedBytes),
    );

    await _registerFont(
      fontBytes,
      QcfFontLoader.getTajweedLightFamily(pageNumber),
    );
    await _registerFont(
      _modifyCpalBaseColor(
        Uint8List.fromList(fontBytes),
        const Color(0xFFFFFFFF),
      ),
      QcfFontLoader.getTajweedDarkFamily(pageNumber),
    );
    await _registerFont(
      _modifyCpalAllColors(
        Uint8List.fromList(fontBytes),
        const Color(0xFF000000),
      ),
      QcfFontLoader.getNoTajweedLightFamily(pageNumber),
    );
    await _registerFont(
      _modifyCpalAllColors(
        Uint8List.fromList(fontBytes),
        const Color(0xFFFFFFFF),
      ),
      QcfFontLoader.getNoTajweedDarkFamily(pageNumber),
    );
    await _registerFont(
      _modifyCpalAllColors(
        Uint8List.fromList(fontBytes),
        const Color(0xFFFF0000),
      ),
      QcfFontLoader.getRedFamily(pageNumber),
    );
  }

  static Future<void> _registerFont(Uint8List fontBytes, String family) async {
    final loader = FontLoader(family);
    final byteData = ByteData.view(
      fontBytes.buffer,
      fontBytes.offsetInBytes,
      fontBytes.lengthInBytes,
    );
    loader.addFont(Future<ByteData>.value(byteData));
    await loader.load();
  }

  /// Recolors near-black opaque CPAL records and preserves Tajweed colors.
  static Uint8List _modifyCpalBaseColor(
    Uint8List fontBytes,
    Color newBaseColor,
  ) {
    final table = _cpalTable(fontBytes);
    if (table == null) return fontBytes;

    final newR = (newBaseColor.r * 255).round();
    final newG = (newBaseColor.g * 255).round();
    final newB = (newBaseColor.b * 255).round();
    final newA = (newBaseColor.a * 255).round();

    for (var i = 0; i < table.numColorRecords; i++) {
      final offset = table.recordsOffset + i * 4;
      if (offset + 4 > fontBytes.length) break;

      final blue = fontBytes[offset];
      final green = fontBytes[offset + 1];
      final red = fontBytes[offset + 2];
      final alpha = fontBytes[offset + 3];

      if (red <= 30 && green <= 30 && blue <= 30 && alpha >= 200) {
        fontBytes[offset] = newB;
        fontBytes[offset + 1] = newG;
        fontBytes[offset + 2] = newR;
        fontBytes[offset + 3] = newA;
      }
    }

    return fontBytes;
  }

  /// Recolors every CPAL record for monochrome reader variants.
  static Uint8List _modifyCpalAllColors(Uint8List fontBytes, Color color) {
    final table = _cpalTable(fontBytes);
    if (table == null) return fontBytes;

    final newR = (color.r * 255).round();
    final newG = (color.g * 255).round();
    final newB = (color.b * 255).round();
    final newA = (color.a * 255).round();

    for (var i = 0; i < table.numColorRecords; i++) {
      final offset = table.recordsOffset + i * 4;
      if (offset + 4 > fontBytes.length) break;

      // CPAL records are stored in BGRA byte order.
      fontBytes[offset] = newB;
      fontBytes[offset + 1] = newG;
      fontBytes[offset + 2] = newR;
      fontBytes[offset + 3] = newA;
    }

    return fontBytes;
  }

  static _CpalTable? _cpalTable(Uint8List fontBytes) {
    if (fontBytes.length < 12) return null;

    final data = ByteData.view(
      fontBytes.buffer,
      fontBytes.offsetInBytes,
      fontBytes.lengthInBytes,
    );
    final tableCount = data.getUint16(4);
    const cpalTag = 0x4350414C; // CPAL

    for (var i = 0; i < tableCount; i++) {
      final recordOffset = 12 + i * 16;
      if (recordOffset + 16 > fontBytes.length) break;
      if (data.getUint32(recordOffset) != cpalTag) continue;

      final tableOffset = data.getUint32(recordOffset + 8);
      final tableLength = data.getUint32(recordOffset + 12);
      if (tableOffset + tableLength > fontBytes.length ||
          tableOffset + 12 > fontBytes.length) {
        return null;
      }

      final count = data.getUint16(tableOffset + 6);
      final arrayOffset = data.getUint32(tableOffset + 8);
      final recordsOffset = tableOffset + arrayOffset;
      if (recordsOffset + count * 4 > fontBytes.length) return null;

      return _CpalTable(count, recordsOffset);
    }

    return null;
  }
}

class _CpalTable {
  const _CpalTable(this.numColorRecords, this.recordsOffset);

  final int numColorRecords;
  final int recordsOffset;
}
