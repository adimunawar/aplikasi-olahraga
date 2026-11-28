import 'package:material_ui/material_ui.dart';

import 'digital_scale_painter.dart';

class CharacterScaleStage extends StatelessWidget {
  final double weightKg;
  final String unit;
  final String gender;

  const CharacterScaleStage({
    super.key,
    required this.weightKg,
    required this.unit,
    this.gender = 'male',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final imagePath = gender == 'female'
        ? 'assets/images/women_full_body.webp'
        : 'assets/images/about-you-men.webp';

    // Subtle horizontal body-width scaling (0.93 at 45kg -> 1.11 at 120kg)
    // so heavier weights look slightly fuller without distorting facial proportions.
    final normalized = ((weightKg - 45.0) / (120.0 - 45.0)).clamp(0.0, 1.0);
    final widthScale = 0.93 + (normalized * 0.18);

    final formattedWeight = weightKg % 1 == 0
        ? weightKg.toStringAsFixed(0)
        : weightKg.toStringAsFixed(1);

    return Center(
      child: SizedBox(
        width: 220,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 20,
              right: 20,
              bottom: 0,
              height: 56,
              child: CustomPaint(
                painter: DigitalScalePainter(
                  weightText: '$formattedWeight $unit',
                  accentColor: colorScheme.primary,
                  platformColor: isDark
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.surfaceContainerHigh,
                  lcdColor: isDark
                      ? colorScheme.surface
                      : colorScheme.onSurface,
                  lcdTextColor: isDark
                      ? colorScheme.onSurface
                      : colorScheme.surface,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 0,
              bottom: 32,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                transform: Matrix4.diagonal3Values(widthScale, 1.0, 1.0),
                transformAlignment: Alignment.bottomCenter,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.accessibility_new_rounded,
                    size: 72,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
