import 'dart:async' show unawaited;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

/// Browser-safe QCF font loader.
///
/// qcf_quran_plus 0.1.1 defaults to permanent disk storage. That code path
/// calls path_provider, which is not supported on Flutter Web. This loader
/// instead extracts only the requested page fonts from the package assets
/// and registers them in memory. It deliberately avoids the package startup
/// helper because that helper eagerly visits all 604 pages.
class QcfWebFontLoader {
  QcfWebFontLoader._();

  static const _assetDirectory =
      'packages/qcf_quran_plus/assets/fonts/qcf_tajweed';

  static final Set<int> _loadedPages = <int>{};
  static final Map<int, Future<void>> _loadingTasks =
      <int, Future<void>>{};

  static Future<void> ensureFontLoaded(int pageNumber) {
    if (pageNumber < 1 || pageNumber > totalPagesCount) {
      return Future<void>.error(
        RangeError.range(pageNumber, 1, totalPagesCount, 'pageNumber'),
      );
    }

    if (_loadedPages.contains(pageNumber)) {
      return Future<void>.value();
    }

    return _loadingTasks.putIfAbsent(pageNumber, () async {
      try {
        await _loadPageFont(pageNumber);
        _loadedPages.add(pageNumber);
      } finally {
        unawaited(_loadingTasks.remove(pageNumber));
      }
    });
  }

  static Future<void> _loadPageFont(int pageNumber) async {
    final baseFamily = QcfFontLoader.getBaseFontFamily(pageNumber);
    final asset = await rootBundle.load(
      '$_assetDirectory/$baseFamily.ttf.gz',
    );
    final compressedBytes = asset.buffer.asUint8List(
      asset.offsetInBytes,
      asset.lengthInBytes,
    );
    final fontBytes = Uint8List.fromList(
      const GZipDecoder().decodeBytes(compressedBytes),
    );

    await _registerFont(
      fontBytes,
      QcfFontLoader.getTajweedLightFamily(pageNumber),
    );
    await _registerFont(
      _recolorCpal(
        fontBytes,
        red: 255,
        green: 255,
        blue: 255,
        recolorNearBlackOnly: true,
      ),
      QcfFontLoader.getTajweedDarkFamily(pageNumber),
    );
    await _registerFont(
      _recolorCpal(fontBytes, red: 0, green: 0, blue: 0),
      QcfFontLoader.getNoTajweedLightFamily(pageNumber),
    );
    await _registerFont(
      _recolorCpal(fontBytes, red: 255, green: 255, blue: 255),
      QcfFontLoader.getNoTajweedDarkFamily(pageNumber),
    );
    await _registerFont(
      _recolorCpal(fontBytes, red: 255, green: 0, blue: 0),
      QcfFontLoader.getRedFamily(pageNumber),
    );
  }

  static Future<void> _registerFont(
    Uint8List fontBytes,
    String family,
  ) async {
    final loader = FontLoader(family);
    loader.addFont(
      Future<ByteData>.value(ByteData.sublistView(fontBytes)),
    );
    await loader.load();
  }

  /// Makes a private copy of an OpenType font and updates its CPAL palette.
  ///
  /// CPAL stores each color as BGRA. The Tajweed-dark variant changes only
  /// opaque near-black entries; the non-Tajweed and red variants flatten the
  /// complete palette to one color.
  static Uint8List _recolorCpal(
    Uint8List source, {
    required int red,
    required int green,
    required int blue,
    bool recolorNearBlackOnly = false,
  }) {
    final bytes = Uint8List.fromList(source);
    if (bytes.length < 12) return bytes;

    final data = ByteData.sublistView(bytes);
    final tableCount = data.getUint16(4, Endian.big);
    const cpalTag = 0x4350414C; // CPAL
    var tableOffset = -1;
    var tableLength = -1;

    for (var index = 0; index < tableCount; index++) {
      final recordOffset = 12 + index * 16;
      if (recordOffset + 16 > bytes.length) break;
      if (data.getUint32(recordOffset, Endian.big) == cpalTag) {
        tableOffset = data.getUint32(recordOffset + 8, Endian.big);
        tableLength = data.getUint32(recordOffset + 12, Endian.big);
        break;
      }
    }

    if (tableOffset < 0 ||
        tableLength < 12 ||
        tableOffset + tableLength > bytes.length) {
      return bytes;
    }

    final colorRecordCount = data.getUint16(tableOffset + 6, Endian.big);
    final firstColorRecordOffset =
        data.getUint32(tableOffset + 8, Endian.big);
    final colorDataStart = tableOffset + firstColorRecordOffset;
    final colorDataEnd = colorDataStart + colorRecordCount * 4;
    if (colorDataStart < tableOffset ||
        colorDataEnd > tableOffset + tableLength ||
        colorDataEnd > bytes.length) {
      return bytes;
    }

    for (var index = 0; index < colorRecordCount; index++) {
      final offset = colorDataStart + index * 4;
      final currentBlue = bytes[offset];
      final currentGreen = bytes[offset + 1];
      final currentRed = bytes[offset + 2];
      final currentAlpha = bytes[offset + 3];

      if (recolorNearBlackOnly &&
          (currentRed > 30 ||
              currentGreen > 30 ||
              currentBlue > 30 ||
              currentAlpha < 200)) {
        continue;
      }

      bytes[offset] = blue;
      bytes[offset + 1] = green;
      bytes[offset + 2] = red;
      bytes[offset + 3] = 255;
    }

    return bytes;
  }
}
