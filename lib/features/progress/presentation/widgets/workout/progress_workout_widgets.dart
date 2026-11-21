import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/features/progress/domain/models/day_activity.dart';

/// Compact workout performance widgets used by the Workout tab.

class WorkoutStatCard extends StatelessWidget {
  const WorkoutStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? colorScheme.outline : AppColors.neutral200,
          width: 0.8,
        ),
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 17,
            color: isDark ? colorScheme.primary : AppColors.greenDark,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyActivityCard extends StatelessWidget {
  const WeeklyActivityCard({
    super.key,
    required this.days,
    required this.maxMinutes,
  });

  final List<DayActivity> days;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final safeMaxMinutes = maxMinutes > 0 ? maxMinutes : 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? colorScheme.outline : AppColors.neutral200,
          width: 0.8,
        ),
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minutes per day',
                style: AppTypography.labelMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${days.fold<int>(0, (sum, day) => sum + day.minutes)} min total',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 112,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final minutes = day.minutes > 0 ? day.minutes : 0;
                final barHeight = minutes == 0
                    ? 4.0
                    : (minutes / safeMaxMinutes * 76).clamp(4.0, 76.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          minutes == 0 ? '-' : '$minutes',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: barHeight),
                          duration: Duration(
                            milliseconds: 520 + (days.indexOf(day) * 65),
                          ),
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedHeight, child) =>
                              Container(
                                height: animatedHeight,
                                decoration: BoxDecoration(
                                  color: minutes > 0
                                      ? (isDark
                                            ? colorScheme.primary
                                            : AppColors.limeAccent)
                                      : (isDark
                                            ? colorScheme
                                                  .surfaceContainerHighest
                                            : AppColors.neutral200),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          day.day,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class TrainingVolumeCard extends StatelessWidget {
  const TrainingVolumeCard({
    super.key,
    required this.totalSets,
    required this.totalReps,
    required this.activePatterns,
  });

  final int totalSets;
  final int totalReps;
  final int activePatterns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final dividerColor = isDark ? colorScheme.outline : AppColors.neutral200;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: dividerColor, width: 0.8),
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _VolumeMetric(
              value: '$totalSets',
              label: 'Total Sets',
              icon: Icons.repeat_rounded,
            ),
          ),
          Container(width: 1, height: 42, color: dividerColor),
          Expanded(
            child: _VolumeMetric(
              value: '$totalReps',
              label: 'Total Reps',
              icon: Icons.fitness_center_rounded,
            ),
          ),
          Container(width: 1, height: 42, color: dividerColor),
          Expanded(
            child: _VolumeMetric(
              value: '$activePatterns',
              label: 'Movement Types',
              icon: Icons.category_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeMetric extends StatelessWidget {
  const _VolumeMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: isDark ? colorScheme.primary : AppColors.greenDark,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.titleMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
