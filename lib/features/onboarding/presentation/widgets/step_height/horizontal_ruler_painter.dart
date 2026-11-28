import 'package:material_ui/material_ui.dart';

class HorizontalRulerPainter extends CustomPainter {
  final double currentValue;
  final Color accentColor;
  final Color tickColor;
  final TextStyle labelStyle;

  const HorizontalRulerPainter({
    required this.currentValue,
    required this.accentColor,
    required this.tickColor,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const pixelsPerUnit = 8.0;
    final visibleHalfRange = (size.width / 2 / pixelsPerUnit).ceil() + 2;
    final startTick = currentValue.round() - visibleHalfRange;
    final endTick = currentValue.round() + visibleHalfRange;

    final tickPaint = Paint()..strokeWidth = 1.4;

    for (var value = startTick; value <= endTick; value++) {
      final dx = centerX + (value - currentValue) * pixelsPerUnit;
      if (dx < 0 || dx > size.width) continue;

      final isMajor = value % 5 == 0;
      final tickHeight = isMajor ? 18.0 : 10.0;
      final topY = isMajor ? 4.0 : 8.0;
      tickPaint.color = isMajor ? tickColor.withValues(alpha: 0.9) : tickColor;

      canvas.drawLine(
        Offset(dx, topY),
        Offset(dx, topY + tickHeight),
        tickPaint,
      );

      if (isMajor) {
        final painter = TextPainter(
          text: TextSpan(text: '$value', style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(canvas, Offset(dx - painter.width / 2, 26));
      }
    }

    final indicatorPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(centerX, 6), Offset(centerX, 24), indicatorPaint);
    canvas.drawCircle(
      Offset(centerX, 6),
      4.5,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  @override
  bool shouldRepaint(covariant HorizontalRulerPainter oldDelegate) {
    return oldDelegate.currentValue != currentValue ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.tickColor != tickColor;
  }
}
