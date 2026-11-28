import 'package:material_ui/material_ui.dart';

class EquipmentCardGlowPainter extends CustomPainter {
  final Color accentColor;
  final bool isSelected;

  const EquipmentCardGlowPainter({
    required this.accentColor,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final primaryAlpha = isSelected ? 0.36 : 0.12;
    final secondaryAlpha = isSelected ? 0.20 : 0.06;

    final primaryGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accentColor.withValues(alpha: primaryAlpha),
              accentColor.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.68, size.height * 0.66),
              radius: size.width * 0.65,
            ),
          );

    final secondaryGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accentColor.withValues(alpha: secondaryAlpha),
              accentColor.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.24, size.height * 0.78),
              radius: size.width * 0.48,
            ),
          );

    canvas.drawRect(Offset.zero & size, primaryGlow);
    canvas.drawRect(Offset.zero & size, secondaryGlow);
  }

  @override
  bool shouldRepaint(covariant EquipmentCardGlowPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.isSelected != isSelected;
  }
}
