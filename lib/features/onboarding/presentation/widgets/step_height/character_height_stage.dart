import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/app_typography.dart';
import 'floor_glow_ring_painter.dart';
import 'vertical_height_ruler_painter.dart';

class CharacterHeightStage extends StatelessWidget {
  final double heightCm;
  final String unit;
  final double heightRatio;
  final String gender;

  const CharacterHeightStage({
    super.key,
    required this.heightCm,
    required this.unit,
    required this.heightRatio,
    this.gender = 'male',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
    final clampedRatio = heightRatio.clamp(0.0, 1.0);
    final charHeightFactor = 0.45 + (clampedRatio * 0.47);
    final alignY = (1.0 - (2.0 * charHeightFactor)).clamp(-1.0, 1.0);
    final imagePath = gender == 'female'
        ? 'assets/images/women_full_body.webp'
        : 'assets/images/about-you-men.webp';

    return Center(
      child: SizedBox(
        width: 240,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 20,
              right: 10,
              bottom: 0,
              height: 36,
              child: CustomPaint(painter: FloorGlowRingPainter(color: accent)),
            ),
            Positioned(
              left: 0,
              top: 12,
              bottom: 18,
              width: 60,
              child: CustomPaint(
                painter: VerticalHeightRulerPainter(
                  color: accent,
                  heightFactor: charHeightFactor,
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 0,
              top: 12,
              bottom: 18,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  heightFactor: charHeightFactor,
                  widthFactor: 1.0,
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.accessibility_new_rounded,
                      size: 72,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 0,
              top: 0,
              bottom: 18,
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                alignment: Alignment(-0.85, alignY),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '${heightCm.round()} $unit',
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
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
