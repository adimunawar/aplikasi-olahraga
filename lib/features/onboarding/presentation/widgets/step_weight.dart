import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Step 4 of 8: Current weight & target weight with dynamic CustomPainter scale.
class StepWeight extends StatelessWidget {
  final double currentWeightKg;
  final double targetWeightKg;
  final ValueChanged<double> onCurrentWeightChanged;
  final ValueChanged<double> onTargetWeightChanged;

  const StepWeight({
    super.key,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.onCurrentWeightChanged,
    required this.onTargetWeightChanged,
  });

  static const double _minWeightKg = 30.0;
  static const double _maxWeightKg = 250.0;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.bodyTarget;
    final colorScheme = Theme.of(context).colorScheme;

    final diff = targetWeightKg - currentWeightKg;
    final absDiff = diff.abs();
    final isGain = diff > 0.05;
    final isLoss = diff < -0.05;

    final insightTitle = isGain
        ? t.insight.gainTitle(diff: diff.toStringAsFixed(1))
        : (isLoss
              ? t.insight.lossTitle(diff: diff.toStringAsFixed(1))
              : t.insight.maintainTitle);

    final insightHint = isGain
        ? t.insight.gainHint(
            minWeeks: (absDiff / 0.5).round(),
            maxWeeks: (absDiff / 0.25).round(),
          )
        : (isLoss
              ? t.insight.lossHint(
                  minWeeks: (absDiff / 1.0).round(),
                  maxWeeks: (absDiff / 0.5).round(),
                )
              : t.insight.maintainHint);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.currentWeight,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 26,
              height: 1.15,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 250,
            width: double.infinity,
            child: _CharacterScaleStage(
              weightKg: currentWeightKg,
              unit: t.unit,
            ),
          ),
          const SizedBox(height: 16),
          _WeightStepperCard(
            label: t.currentWeight,
            unit: t.unit,
            value: currentWeightKg,
            minValue: _minWeightKg,
            maxValue: _maxWeightKg,
            highlightBorder: true,
            onChanged: (val) =>
                onCurrentWeightChanged(double.parse(val.toStringAsFixed(1))),
          ),
          const SizedBox(height: 12),
          _WeightStepperCard(
            label: t.targetWeight,
            unit: t.unit,
            value: targetWeightKg,
            minValue: _minWeightKg,
            maxValue: _maxWeightKg,
            onChanged: (val) =>
                onTargetWeightChanged(double.parse(val.toStringAsFixed(1))),
          ),
          const SizedBox(height: 12),
          _InsightBannerCard(title: insightTitle, hint: insightHint),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CharacterScaleStage extends StatelessWidget {
  final double weightKg;
  final String unit;

  const _CharacterScaleStage({required this.weightKg, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

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
                painter: _DigitalScalePainter(
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
                  'assets/images/about-you-men.webp',
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

class _WeightStepperCard extends StatelessWidget {
  final String label;
  final String unit;
  final double value;
  final double minValue;
  final double maxValue;
  final bool highlightBorder;
  final ValueChanged<double> onChanged;

  const _WeightStepperCard({
    required this.label,
    required this.unit,
    required this.value,
    required this.minValue,
    required this.maxValue,
    this.highlightBorder = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final formattedValue = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlightBorder
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: highlightBorder ? 1.5 : 1.2,
        ),
        boxShadow: isDark
            ? (highlightBorder
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.14),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null)
            : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_weight_outlined,
                size: 18,
                color: isDark ? colorScheme.primary : AppColors.greenBrand,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleStepButton(
                icon: Icons.remove_rounded,
                enabled: value > minValue,
                onTap: () => onChanged((value - 0.5).clamp(minValue, maxValue)),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$formattedValue ',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: unit,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _CircleStepButton(
                icon: Icons.add_rounded,
                enabled: value < maxValue,
                onTap: () => onChanged((value + 0.5).clamp(minValue, maxValue)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleStepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CircleStepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _InsightBannerCard extends StatelessWidget {
  final String title;
  final String hint;

  const _InsightBannerCard({required this.title, required this.hint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(
          alpha: isDark ? 0.45 : 0.7,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.track_changes_rounded,
              size: 18,
              color: isDark ? colorScheme.primary : AppColors.greenBrand,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hint,
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitalScalePainter extends CustomPainter {
  final String weightText;
  final Color accentColor;
  final Color platformColor;
  final Color lcdColor;
  final Color lcdTextColor;

  const _DigitalScalePainter({
    required this.weightText,
    required this.accentColor,
    required this.platformColor,
    required this.lcdColor,
    required this.lcdTextColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final glowRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height - 8),
      width: size.width * 0.96,
      height: 18,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..color = accentColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    final basePath = Path()
      ..moveTo(size.width * 0.14, 6)
      ..lineTo(size.width * 0.86, 6)
      ..quadraticBezierTo(size.width * 0.94, 6, size.width * 0.96, 16)
      ..lineTo(size.width * 0.98, size.height - 10)
      ..quadraticBezierTo(
        size.width * 0.98,
        size.height - 4,
        size.width * 0.90,
        size.height - 4,
      )
      ..lineTo(size.width * 0.10, size.height - 4)
      ..quadraticBezierTo(
        size.width * 0.02,
        size.height - 4,
        size.width * 0.02,
        size.height - 10,
      )
      ..lineTo(size.width * 0.04, 16)
      ..quadraticBezierTo(size.width * 0.06, 6, size.width * 0.14, 6)
      ..close();

    canvas.drawPath(basePath, Paint()..color = platformColor);
    canvas.drawPath(
      basePath,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    final lcdCenter = Offset(size.width / 2, size.height - 17);
    final lcdRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: lcdCenter, width: size.width * 0.42, height: 17),
      const Radius.circular(5),
    );
    canvas.drawRRect(lcdRect, Paint()..color = lcdColor);

    final textPainter = TextPainter(
      text: TextSpan(
        text: weightText,
        style: TextStyle(
          color: lcdTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(lcdCenter.dx, lcdCenter.dy);
    canvas.rotate(math.pi);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DigitalScalePainter oldDelegate) {
    return oldDelegate.weightText != weightText ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.platformColor != platformColor ||
        oldDelegate.lcdColor != lcdColor ||
        oldDelegate.lcdTextColor != lcdTextColor;
  }
}
