import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/i18n/strings.g.dart';

import 'progress_card_decoration.dart';
import 'progress_empty_state.dart';

/// Sorotan pencapaian mingguan: latihan selesai, perubahan berat, dan streak.
class HighlightsCard extends StatelessWidget {
  const HighlightsCard({
    super.key,
    required this.completed,
    required this.target,
    required this.weightChange,
    required this.streak,
    this.hasWeightData = false,
  });

  final int completed;
  final int target;
  final double weightChange;
  final int streak;
  final bool hasWeightData;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final labels = context.t.core.progress.highlights;
    final weightValue = weightChange.abs().toStringAsFixed(1);

    final rows = <(IconData, String)>[
      if (target > 0)
        (
          Icons.check_circle_outline_rounded,
          labels.completed(completed: completed, target: target),
        ),
      if (hasWeightData)
        (
          Icons.trending_up_rounded,
          weightChange >= 0
              ? labels.weightIncrease(value: weightValue)
              : labels.weightDecrease(value: weightValue),
        ),
      if (streak > 0)
        (
          Icons.emoji_events_outlined,
          streak == 1
              ? context.t.core.streak.activeDaySingular(count: streak)
              : context.t.core.streak.activeDayPlural(count: streak),
        ),
    ];
    if (rows.isEmpty) {
      return ProgressEmptyState(
        icon: Icons.insights_outlined,
        title: labels.emptyTitle,
        message: labels.emptyMessage,
        compact: true,
      );
    }
    return Container(
      decoration: progressCardDecoration(context),
      child: Column(
        children: List.generate(rows.length, (index) {
          final row = rows[index];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.primaryContainer
                            : AppColors.limeSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        row.$1,
                        size: 15,
                        color: isDark
                            ? colorScheme.primary
                            : AppColors.greenDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 19,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              if (index != rows.length - 1)
                Divider(
                  height: 1,
                  color: isDark ? colorScheme.outline : AppColors.neutral200,
                ),
            ],
          );
        }),
      ),
    );
  }
}
