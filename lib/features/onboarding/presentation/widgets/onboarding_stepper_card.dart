import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable stepper card shared across onboarding steps (e.g. Age, Weight).
class OnboardingStepperCard extends StatelessWidget {
  final String label;
  final String unit;
  final double value;
  final double step;
  final double minValue;
  final double maxValue;
  final IconData icon;
  final bool highlightBorder;
  final ValueChanged<double> onChanged;

  const OnboardingStepperCard({
    super.key,
    required this.label,
    required this.unit,
    required this.value,
    this.step = 1.0,
    required this.minValue,
    required this.maxValue,
    this.icon = Icons.tune_rounded,
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
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.92)
            : colorScheme.surface.withValues(alpha: 0.94),
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
                icon,
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
                onTap: () =>
                    onChanged((value - step).clamp(minValue, maxValue)),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formattedValue,
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _CircleStepButton(
                icon: Icons.add_rounded,
                enabled: value < maxValue,
                onTap: () =>
                    onChanged((value + step).clamp(minValue, maxValue)),
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
