import 'package:flutter/material.dart';

/// Diagram Otot Anatomi (Mockup Referensi 1:1)
/// Menampilkan siluet tubuh atas dengan highlight otot dada, bahu, dan lengan.
class AnatomyMuscleDiagram extends StatelessWidget {
  final double width;
  final double height;
  final bool highlightChest;
  final bool highlightShoulders;
  final bool highlightArms;

  const AnatomyMuscleDiagram({
    super.key,
    this.width = 110,
    this.height = 120,
    this.highlightChest = true,
    this.highlightShoulders = true,
    this.highlightArms = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _AnatomyPainter(
          highlightChest: highlightChest,
          highlightShoulders: highlightShoulders,
          highlightArms: highlightArms,
        ),
      ),
    );
  }
}

class _AnatomyPainter extends CustomPainter {
  final bool highlightChest;
  final bool highlightShoulders;
  final bool highlightArms;

  _AnatomyPainter({
    required this.highlightChest,
    required this.highlightShoulders,
    required this.highlightArms,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final highlightPaint = Paint()
      ..color = const Color(0xFFCCF13E)
      ..style = PaintingStyle.fill;

    final highlightBorderPaint = Paint()
      ..color = const Color(0xFFA5CF17)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final centerX = size.width / 2;

    // 1. Kepala
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, size.height * 0.16),
        width: size.width * 0.28,
        height: size.height * 0.26,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(headRect, basePaint);
    canvas.drawRRect(headRect, borderPaint);

    // 2. Leher & Trapezius
    final neckPath = Path()
      ..moveTo(centerX - size.width * 0.1, size.height * 0.28)
      ..lineTo(centerX + size.width * 0.1, size.height * 0.28)
      ..lineTo(centerX + size.width * 0.18, size.height * 0.38)
      ..lineTo(centerX - size.width * 0.18, size.height * 0.38)
      ..close();
    canvas.drawPath(neckPath, basePaint);
    canvas.drawPath(neckPath, borderPaint);

    // 3. Batang Tubuh / Perut Dasar (Abu-Abu)
    final torsoPath = Path()
      ..moveTo(centerX - size.width * 0.28, size.height * 0.58)
      ..lineTo(centerX + size.width * 0.28, size.height * 0.58)
      ..lineTo(centerX + size.width * 0.22, size.height * 0.95)
      ..lineTo(centerX - size.width * 0.22, size.height * 0.95)
      ..close();
    canvas.drawPath(torsoPath, basePaint);
    canvas.drawPath(torsoPath, borderPaint);

    // Garis Abs lembut
    final absPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(centerX, size.height * 0.60),
      Offset(centerX, size.height * 0.90),
      absPaint,
    );

    // 4. Bahu Kiri & Kanan (Deltoids)
    final shoulderPaint = highlightShoulders ? highlightPaint : basePaint;
    final shoulderBorder = highlightShoulders ? highlightBorderPaint : borderPaint;

    // Bahu Kiri
    final leftShoulder = Path()
      ..moveTo(centerX - size.width * 0.2, size.height * 0.36)
      ..quadraticBezierTo(
        centerX - size.width * 0.44,
        size.height * 0.37,
        centerX - size.width * 0.46,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        centerX - size.width * 0.35,
        size.height * 0.54,
        centerX - size.width * 0.26,
        size.height * 0.44,
      )
      ..close();
    canvas.drawPath(leftShoulder, shoulderPaint);
    canvas.drawPath(leftShoulder, shoulderBorder);

    // Bahu Kanan
    final rightShoulder = Path()
      ..moveTo(centerX + size.width * 0.2, size.height * 0.36)
      ..quadraticBezierTo(
        centerX + size.width * 0.44,
        size.height * 0.37,
        centerX + size.width * 0.46,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        centerX + size.width * 0.35,
        size.height * 0.54,
        centerX + size.width * 0.26,
        size.height * 0.44,
      )
      ..close();
    canvas.drawPath(rightShoulder, shoulderPaint);
    canvas.drawPath(rightShoulder, shoulderBorder);

    // 5. Dada (Pectoralis) - Highlighted
    final chestPaint = highlightChest ? highlightPaint : basePaint;
    final chestBorder = highlightChest ? highlightBorderPaint : borderPaint;

    // Dada Kiri
    final leftChest = Path()
      ..moveTo(centerX - size.width * 0.03, size.height * 0.40)
      ..lineTo(centerX - size.width * 0.26, size.height * 0.42)
      ..quadraticBezierTo(
        centerX - size.width * 0.28,
        size.height * 0.56,
        centerX - size.width * 0.03,
        size.height * 0.57,
      )
      ..close();
    canvas.drawPath(leftChest, chestPaint);
    canvas.drawPath(leftChest, chestBorder);

    // Dada Kanan
    final rightChest = Path()
      ..moveTo(centerX + size.width * 0.03, size.height * 0.40)
      ..lineTo(centerX + size.width * 0.26, size.height * 0.42)
      ..quadraticBezierTo(
        centerX + size.width * 0.28,
        size.height * 0.56,
        centerX + size.width * 0.03,
        size.height * 0.57,
      )
      ..close();
    canvas.drawPath(rightChest, chestPaint);
    canvas.drawPath(rightChest, chestBorder);

    // 6. Biceps / Lengan Atas
    final armPaint = highlightArms ? highlightPaint : basePaint;
    final armBorder = highlightArms ? highlightBorderPaint : borderPaint;

    // Lengan Kiri
    final leftArm = Path()
      ..moveTo(centerX - size.width * 0.45, size.height * 0.52)
      ..quadraticBezierTo(
        centerX - size.width * 0.48,
        size.height * 0.68,
        centerX - size.width * 0.38,
        size.height * 0.78,
      )
      ..lineTo(centerX - size.width * 0.30, size.height * 0.65)
      ..close();
    canvas.drawPath(leftArm, armPaint);
    canvas.drawPath(leftArm, armBorder);

    // Lengan Kanan
    final rightArm = Path()
      ..moveTo(centerX + size.width * 0.45, size.height * 0.52)
      ..quadraticBezierTo(
        centerX + size.width * 0.48,
        size.height * 0.68,
        centerX + size.width * 0.38,
        size.height * 0.78,
      )
      ..lineTo(centerX + size.width * 0.30, size.height * 0.65)
      ..close();
    canvas.drawPath(rightArm, armPaint);
    canvas.drawPath(rightArm, armBorder);
  }

  @override
  bool shouldRepaint(covariant _AnatomyPainter oldDelegate) {
    return oldDelegate.highlightChest != highlightChest ||
        oldDelegate.highlightShoulders != highlightShoulders ||
        oldDelegate.highlightArms != highlightArms;
  }
}

