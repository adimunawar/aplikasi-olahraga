import 'package:material_ui/material_ui.dart';

class FloorGlowRingPainter extends CustomPainter {
  final Color color;

  const FloorGlowRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.88,
      height: size.height * 0.56,
    );

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawOval(rect, glowPaint);
    canvas.drawOval(rect, ringPaint);
  }

  @override
  bool shouldRepaint(covariant FloorGlowRingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
