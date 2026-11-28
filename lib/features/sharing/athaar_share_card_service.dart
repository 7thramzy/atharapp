import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AthaarShareCardService {
  const AthaarShareCardService();

  Future<XFile> render({
    required String title,
    required String body,
    String? subtitle,
    String footer = 'أثَر · رفقةٌ تعين على الخير',
  }) async {
    const width = 1080.0;
    const bodyFontSize = 52.0;

    // Measure the complete Arabic content first. The card height grows with
    // the content so long Quranic verses are never silently cut off.
    final bodyPainter = TextPainter(
      text: const TextSpan(),
      textDirection: TextDirection.rtl,
    );
    bodyPainter.text = TextSpan(
      text: body,
      style: const TextStyle(
        fontFamily: 'serif',
        fontSize: bodyFontSize,
        height: 1.85,
        color: Color(0xFFFFFDF6),
        fontWeight: FontWeight.w500,
      ),
    );
    bodyPainter.textDirection = TextDirection.rtl;
    bodyPainter.textAlign = TextAlign.center;
    bodyPainter.layout(maxWidth: 820);
    final height = math.max(1350.0, 420 + bodyPainter.height + 310);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF0D2928), Color(0xFF17483F), Color(0xFF0A2223)],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), background);

    final ornament = Paint()
      ..color = const Color(0x33D7BD83)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(const Offset(920, 160), 150, ornament);
    canvas.drawCircle(const Offset(920, 160), 180, ornament);
    canvas.drawCircle(Offset(160, height - 170), 190, ornament);
    canvas.drawCircle(Offset(160, height - 170), 220, ornament);

    final frame = Paint()
      ..color = const Color(0x99D7BD83)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(42, 42, width - 84, height - 84),
        const Radius.circular(34),
      ),
      frame,
    );

    _drawText(
      canvas,
      title,
      const Rect.fromLTWH(110, 150, 860, 100),
      fontSize: 48,
      color: const Color(0xFFE5D2A2),
      weight: FontWeight.w700,
    );
    if (subtitle != null && subtitle.trim().isNotEmpty) {
      _drawText(
        canvas,
        subtitle,
        const Rect.fromLTWH(130, 270, 820, 90),
        fontSize: 31,
        color: const Color(0xFFC8D9D0),
      );
    }

    bodyPainter.paint(
      canvas,
      Offset((width - bodyPainter.width) / 2, 400),
    );

    final footerY = height - 160;
    final dividerPaint = Paint()
      ..color = const Color(0x99D7BD83)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(330, footerY),
      Offset(750, footerY),
      dividerPaint,
    );
    _drawText(
      canvas,
      footer,
      Rect.fromLTWH(110, height - 135, 860, 80),
      fontSize: 27,
      color: const Color(0xFFD7BD83),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.ceil());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) {
      throw StateError('Could not encode share card image.');
    }

    return XFile.fromData(
      bytes.buffer.asUint8List(),
      mimeType: 'image/png',
      name: 'athaar-share-${DateTime.now().microsecondsSinceEpoch}.png',
    );
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
      Offset(
        rect.left + (rect.width - painter.width) / 2,
        rect.top + (rect.height - painter.height) / 2,
      ),
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
        files: [file],
        fileNameOverrides: [await file.name],
      ),
    );
  }
}
