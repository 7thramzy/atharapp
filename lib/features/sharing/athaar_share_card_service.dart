import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AthaarShareCardService {
  const AthaarShareCardService();

  Future<File> render({
    required String title,
    required String body,
    String? subtitle,
    String footer = 'أثَر · رفقةٌ تعين على الخير',
  }) async {
    const width = 1080.0;
    const height = 1350.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF0D2928), Color(0xFF17483F), Color(0xFF0A2223)],
      ).createShader(const Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), background);

    final ornament = Paint()
      ..color = const Color(0x33D7BD83)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(const Offset(920, 160), 150, ornament);
    canvas.drawCircle(const Offset(920, 160), 180, ornament);
    canvas.drawCircle(const Offset(160, 1180), 190, ornament);
    canvas.drawCircle(const Offset(160, 1180), 220, ornament);

    final frame = Paint()
      ..color = const Color(0x99D7BD83)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(42, 42, width - 84, height - 84),
        const Radius.circular(34),
      ),
      frame,
    );

    _drawText(canvas, title, const Rect.fromLTWH(110, 170, 860, 100),
        fontSize: 48, color: const Color(0xFFE5D2A2), weight: FontWeight.w700);
    if (subtitle != null && subtitle.trim().isNotEmpty) {
      _drawText(canvas, subtitle, const Rect.fromLTWH(130, 285, 820, 90),
          fontSize: 31, color: const Color(0xFFC8D9D0));
    }

    var bodySize = 58.0;
    TextPainter bodyPainter;
    do {
      bodyPainter = TextPainter(
        text: TextSpan(
          text: body,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: bodySize,
            height: 1.85,
            color: const Color(0xFFFFFDF6),
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 820);
      if (bodyPainter.height <= 650 || bodySize <= 34) break;
      bodySize -= 3;
    } while (bodySize > 30);
    bodyPainter.paint(
      canvas,
      Offset((width - bodyPainter.width) / 2, 420 + (650 - bodyPainter.height) / 2),
    );

    final dividerPaint = Paint()
      ..color = const Color(0x99D7BD83)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(330, 1160), const Offset(750, 1160), dividerPaint);
    _drawText(canvas, footer, const Rect.fromLTWH(110, 1180, 860, 80),
        fontSize: 27, color: const Color(0xFFD7BD83));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) throw StateError('Could not encode share card image.');

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/athaar-share-${DateTime.now().microsecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    return file;
  }

  void _drawText(
    Canvas canvas,
    String text,
    Rect rect, {
    required double fontSize,
    required Color color,
    FontWeight weight = FontWeight.w500,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: weight,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: rect.width);
    painter.paint(
      canvas,
      Offset(rect.left + (rect.width - painter.width) / 2,
          rect.top + (rect.height - painter.height) / 2),
    );
  }

  Future<void> share({
    required String title,
    required String body,
    String? subtitle,
    String footer = 'أثَر · رفقةٌ تعين على الخير',
  }) async {
    final file = await render(
      title: title,
      body: body,
      subtitle: subtitle,
      footer: footer,
    );
    await SharePlus.instance.share(
      ShareParams(
        title: title,
        files: [XFile(file.path, mimeType: 'image/png')],
      ),
    );
  }
}
