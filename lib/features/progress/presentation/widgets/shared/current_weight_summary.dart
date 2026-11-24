import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/i18n/strings.g.dart';

import 'progress_card_decoration.dart';

/// Ringkasan berat badan saat ini beserta selisihnya terhadap awal rentang.
class CurrentWeightSummary extends StatelessWidget {
  const CurrentWeightSummary({
    super.key,
    required this.currentWeight,
    required this.change,
    required this.rangeWeeks,
  });

  final double currentWeight;
  final double change;
  final int rangeWeeks;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final labels = context.t.core.progress.weightTrend;
    final formattedChange = change.abs().toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: progressCardDecoration(context),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.primaryContainer
                  : AppColors.limeSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.monitor_weight_outlined,
              size: 19,
              color: isDark ? colorScheme.primary : AppColors.greenDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currentWeight.toStringAsFixed(1)} kg',
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  labels.vsWeeksAgo(weeks: rangeWeeks),
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.primaryContainer
                  : AppColors.limeSurface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              change >= 0
                  ? labels.increase(value: formattedChange)
                  : labels.decrease(value: formattedChange),
              style: AppTypography.labelSmall.copyWith(
                color: isDark ? colorScheme.primary : AppColors.greenDark,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
