import 'package:material_ui/material_ui.dart';

class GenderCardGlowPainter extends CustomPainter {
  final Color accentColor;
  final bool isSelected;

  const GenderCardGlowPainter({
    required this.accentColor,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final orbAlpha = isSelected ? 0.42 : 0.14;
    final secondaryAlpha = isSelected ? 0.28 : 0.08;

    final orbPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accentColor.withValues(alpha: orbAlpha),
              accentColor.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.65, size.height * 0.56),
              radius: size.width * 0.62,
            ),
          );

    final lowerGlowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accentColor.withValues(alpha: secondaryAlpha),
              accentColor.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.25, size.height * 0.72),
              radius: size.width * 0.5,
            ),
          );

    canvas.drawRect(Offset.zero & size, orbPaint);
    canvas.drawRect(Offset.zero & size, lowerGlowPaint);
  }

  @override
  bool shouldRepaint(covariant GenderCardGlowPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.isSelected != isSelected;
  }
}

class DiagonalAccentStripesPainter extends CustomPainter {
  final Color color;

  const DiagonalAccentStripesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const stripeCount = 3;
    final spacing = size.width / (stripeCount + 1);
    for (var i = 0; i < stripeCount; i++) {
      final startX = spacing * (i + 0.5);
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX + 4, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DiagonalAccentStripesPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
