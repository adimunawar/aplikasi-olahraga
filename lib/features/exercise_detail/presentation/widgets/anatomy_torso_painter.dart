import 'package:flutter/material.dart';

/// CustomPainter untuk menggambar anatomi tubuh (dada, bahu, dan punggung)
class AnatomyTorsoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final primaryPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;

    final secondaryPaint = Paint()
      ..color = const Color(0xFFFCA5A5)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Draw front torso silhouette
    final frontPath = Path()
      ..moveTo(w * 0.35, h * 0.15)
      ..lineTo(w * 0.25, h * 0.35)
      ..lineTo(w * 0.30, h * 0.85)
      ..lineTo(w * 0.40, h * 0.85)
      ..lineTo(w * 0.45, h * 0.35)
      ..close();
    canvas.drawPath(frontPath, bodyPaint);

    // Primary Highlight: Chest
    final chestRect = Rect.fromCenter(
      center: Offset(w * 0.35, h * 0.42),
      width: w * 0.14,
      height: h * 0.22,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(chestRect, const Radius.circular(4)), primaryPaint);

    // Draw back torso silhouette
    final backPath = Path()
      ..moveTo(w * 0.70, h * 0.15)
      ..lineTo(w * 0.60, h * 0.35)
      ..lineTo(w * 0.65, h * 0.85)
      ..lineTo(w * 0.75, h * 0.85)
      ..lineTo(w * 0.80, h * 0.35)
      ..close();
    canvas.drawPath(backPath, bodyPaint);

    // Secondary Highlight: Shoulders & Upper Back
    final shoulderLeft = Rect.fromCenter(
      center: Offset(w * 0.62, h * 0.35),
      width: w * 0.08,
      height: h * 0.15,
    );
    final shoulderRight = Rect.fromCenter(
      center: Offset(w * 0.78, h * 0.35),
      width: w * 0.08,
      height: h * 0.15,
    );
    canvas.drawOval(shoulderLeft, secondaryPaint);
    canvas.drawOval(shoulderRight, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

