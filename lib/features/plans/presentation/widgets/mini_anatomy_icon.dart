import 'package:flutter/material.dart';

/// Mini ilustrasi anatomi tubuh yang menampilkan highlight merah pada otot target
/// (Dada, Punggung, Bahu, Lengan, atau Kaki) sesuai mockup Exercises.
class MiniAnatomyIcon extends StatelessWidget {
  final String muscleGroup; // 'Chest', 'Back', 'Shoulder', 'Arms', 'Legs', dll

  const MiniAnatomyIcon({
    super.key,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 42,
      child: CustomPaint(
        painter: _MiniTorsoPainter(muscleGroup.toLowerCase()),
      ),
    );
  }
}

class _MiniTorsoPainter extends CustomPainter {
  final String muscle;

  _MiniTorsoPainter(this.muscle);

  @override
  void paint(Canvas canvas, Size size) {
    final bodyStroke = Paint()
      ..color = const Color(0xFFD1D5DB) // Light grey outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final redHighlight = Paint()
      ..color = const Color(0xFFEF4444) // Bright red highlight
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Siluet Kepala
    canvas.drawCircle(Offset(w * 0.5, h * 0.14), w * 0.12, bodyStroke);

    // 2. Siluet Tubuh Atas & Lengan
    final torsoPath = Path()
      ..moveTo(w * 0.35, h * 0.24)
      ..lineTo(w * 0.16, h * 0.32) // Bahu kiri
      ..lineTo(w * 0.10, h * 0.60) // Lengan kiri
      ..lineTo(w * 0.18, h * 0.60)
      ..lineTo(w * 0.24, h * 0.40)
      ..lineTo(w * 0.28, h * 0.70) // Pinggang kiri
      ..lineTo(w * 0.36, h * 0.78) // Selangkangan
      ..lineTo(w * 0.32, h * 0.98) // Kaki kiri
      ..lineTo(w * 0.42, h * 0.98)
      ..lineTo(w * 0.50, h * 0.80) // Tengah
      ..lineTo(w * 0.58, h * 0.98) // Kaki kanan
      ..lineTo(w * 0.68, h * 0.98)
      ..lineTo(w * 0.64, h * 0.78)
      ..lineTo(w * 0.72, h * 0.70) // Pinggang kanan
      ..lineTo(w * 0.76, h * 0.40)
      ..lineTo(w * 0.82, h * 0.60)
      ..lineTo(w * 0.90, h * 0.60) // Lengan kanan
      ..lineTo(w * 0.84, h * 0.32) // Bahu kanan
      ..lineTo(w * 0.65, h * 0.24)
      ..close();

    canvas.drawPath(torsoPath, bodyStroke);

    // 3. Highlight Otot Sesuai Target
    if (muscle.contains('chest') || muscle.contains('dada')) {
      // Highlight Dada (Kiri & Kanan)
      final leftChest = Rect.fromLTWH(w * 0.30, h * 0.32, w * 0.18, h * 0.14);
      final rightChest = Rect.fromLTWH(w * 0.52, h * 0.32, w * 0.18, h * 0.14);
      canvas.drawRRect(RRect.fromRectAndRadius(leftChest, const Radius.circular(3)), redHighlight);
      canvas.drawRRect(RRect.fromRectAndRadius(rightChest, const Radius.circular(3)), redHighlight);
    } else if (muscle.contains('back') || muscle.contains('punggung')) {
      // Highlight Punggung / Lats
      final latLeft = Rect.fromLTWH(w * 0.26, h * 0.34, w * 0.14, h * 0.24);
      final latRight = Rect.fromLTWH(w * 0.60, h * 0.34, w * 0.14, h * 0.24);
      canvas.drawRRect(RRect.fromRectAndRadius(latLeft, const Radius.circular(3)), redHighlight);
      canvas.drawRRect(RRect.fromRectAndRadius(latRight, const Radius.circular(3)), redHighlight);
    } else if (muscle.contains('shoulder') || muscle.contains('bahu')) {
      // Highlight Bahu (Deltoids)
      final deltLeft = Rect.fromLTWH(w * 0.14, h * 0.28, w * 0.14, h * 0.12);
      final deltRight = Rect.fromLTWH(w * 0.72, h * 0.28, w * 0.14, h * 0.12);
      canvas.drawRRect(RRect.fromRectAndRadius(deltLeft, const Radius.circular(3)), redHighlight);
      canvas.drawRRect(RRect.fromRectAndRadius(deltRight, const Radius.circular(3)), redHighlight);
    } else if (muscle.contains('arm') || muscle.contains('lengan') || muscle.contains('bicep') || muscle.contains('tricep')) {
      // Highlight Lengan
      final armLeft = Rect.fromLTWH(w * 0.10, h * 0.38, w * 0.12, h * 0.18);
      final armRight = Rect.fromLTWH(w * 0.78, h * 0.38, w * 0.12, h * 0.18);
      canvas.drawRRect(RRect.fromRectAndRadius(armLeft, const Radius.circular(2)), redHighlight);
      canvas.drawRRect(RRect.fromRectAndRadius(armRight, const Radius.circular(2)), redHighlight);
    } else if (muscle.contains('leg') || muscle.contains('kaki') || muscle.contains('glute')) {
      // Highlight Kaki / Paha
      final thighLeft = Rect.fromLTWH(w * 0.32, h * 0.72, w * 0.14, h * 0.22);
      final thighRight = Rect.fromLTWH(w * 0.54, h * 0.72, w * 0.14, h * 0.22);
      canvas.drawRRect(RRect.fromRectAndRadius(thighLeft, const Radius.circular(3)), redHighlight);
      canvas.drawRRect(RRect.fromRectAndRadius(thighRight, const Radius.circular(3)), redHighlight);
    } else {
      // Default: Core / Abs
      final absRect = Rect.fromLTWH(w * 0.38, h * 0.44, w * 0.24, h * 0.22);
      canvas.drawRRect(RRect.fromRectAndRadius(absRect, const Radius.circular(3)), redHighlight);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniTorsoPainter oldDelegate) =>
      oldDelegate.muscle != muscle;
}

