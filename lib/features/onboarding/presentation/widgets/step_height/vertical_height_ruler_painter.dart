import 'package:material_ui/material_ui.dart';

class VerticalHeightRulerPainter extends CustomPainter {
  final Color color;
  final double heightFactor;

  const VerticalHeightRulerPainter({
    required this.color,
    required this.heightFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 1.2;

    canvas.drawLine(const Offset(4, 0), Offset(4, size.height), linePaint);

    const totalTicks = 28;
    for (var i = 0; i <= totalTicks; i++) {
      final y = (size.height / totalTicks) * i;
      final isMajor = i % 5 == 0;
      final tickLen = isMajor ? 10.0 : 5.0;
      canvas.drawLine(Offset(4, y), Offset(4 + tickLen, y), tickPaint);
    }

    final clampedY = (size.height * (1.0 - heightFactor)).clamp(
      0.0,
      size.height,
    );
    final guidePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(4, clampedY),
      Offset(size.width, clampedY),
      guidePaint,
    );
    canvas.drawCircle(Offset(4, clampedY), 4.0, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant VerticalHeightRulerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.heightFactor != heightFactor;
  }
}
