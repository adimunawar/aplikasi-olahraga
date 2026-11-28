import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class DigitalScalePainter extends CustomPainter {
  final String weightText;
  final Color accentColor;
  final Color platformColor;
  final Color lcdColor;
  final Color lcdTextColor;

  const DigitalScalePainter({
    required this.weightText,
    required this.accentColor,
    required this.platformColor,
    required this.lcdColor,
    required this.lcdTextColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final glowRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height - 8),
      width: size.width * 0.96,
      height: 18,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..color = accentColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    final basePath = Path()
      ..moveTo(size.width * 0.14, 6)
      ..lineTo(size.width * 0.86, 6)
      ..quadraticBezierTo(size.width * 0.94, 6, size.width * 0.96, 16)
      ..lineTo(size.width * 0.98, size.height - 10)
      ..quadraticBezierTo(
        size.width * 0.98,
        size.height - 4,
        size.width * 0.90,
        size.height - 4,
      )
      ..lineTo(size.width * 0.10, size.height - 4)
      ..quadraticBezierTo(
        size.width * 0.02,
        size.height - 4,
        size.width * 0.02,
        size.height - 10,
      )
      ..lineTo(size.width * 0.04, 16)
      ..quadraticBezierTo(size.width * 0.06, 6, size.width * 0.14, 6)
      ..close();

    canvas.drawPath(basePath, Paint()..color = platformColor);
    canvas.drawPath(
      basePath,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    final lcdCenter = Offset(size.width / 2, size.height - 17);
    final lcdRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: lcdCenter, width: size.width * 0.42, height: 17),
      const Radius.circular(5),
    );
    canvas.drawRRect(lcdRect, Paint()..color = lcdColor);

    final textPainter = TextPainter(
      text: TextSpan(
        text: weightText,
        style: TextStyle(
          color: lcdTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(lcdCenter.dx, lcdCenter.dy);
    canvas.rotate(math.pi);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DigitalScalePainter oldDelegate) {
    return oldDelegate.weightText != weightText ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.platformColor != platformColor ||
        oldDelegate.lcdColor != lcdColor ||
        oldDelegate.lcdTextColor != lcdTextColor;
  }
}
