import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/widgets/core_widgets.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../application/progress_history_grouping.dart';
import '../../../domain/models/weight_record.dart';
import '../../../domain/models/workout_history_item.dart';
import '../shared/progress_card_decoration.dart';

class HistoryEntry {
  const HistoryEntry._({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.isMeasurement,
  });

  factory HistoryEntry.workout(WorkoutHistoryItem item) {
    final date = const ProgressHistoryGrouping().parseWorkoutDate(
      item.dateText,
      now: DateTime.now(),
    );
    return HistoryEntry._(
      date: date,
      title: item.title,
      subtitle: 'Workout · ${item.durationText}',
      isMeasurement: false,
    );
  }

  factory HistoryEntry.measurement(WeightRecord item) => HistoryEntry._(
    date: item.recordedAt,
    title: 'Body Measurement',
    subtitle: '${item.weightKg.toStringAsFixed(1)} kg',
    isMeasurement: true,
  );

  final DateTime date;
  final String title;
  final String subtitle;
  final bool isMeasurement;
}

class HistoryFilterChip extends StatelessWidget {
  const HistoryFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final unselectedBg = isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.neutral100;
    final unselectedTextColor = isDark
        ? colorScheme.onSurfaceVariant
        : AppColors.neutral700;

    return Material(
      color: selected ? colorScheme.primary : unselectedBg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 12,
                  color: selected ? colorScheme.onPrimary : unselectedTextColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: selected ? colorScheme.onPrimary : unselectedTextColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryGroupCard extends StatelessWidget {
  const HistoryGroupCard({super.key, required this.entries});
  final List<HistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: progressCardDecoration(context),
      child: Column(
        children: List.generate(entries.length, (index) {
          final entry = entries[index];
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 2,
                ),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: entry.isMeasurement
                        ? (isDark
                              ? colorScheme.surfaceContainerHighest
                              : AppColors.neutral100)
                        : (isDark
                              ? colorScheme.primaryContainer
                              : AppColors.limeSurface),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    entry.isMeasurement
                        ? Icons.monitor_weight_outlined
                        : Icons.fitness_center_rounded,
                    size: 17,
                    color: entry.isMeasurement
                        ? (isDark
                              ? colorScheme.onSurfaceVariant
                              : AppColors.neutral700)
                        : (isDark ? colorScheme.primary : AppColors.greenDark),
                  ),
                ),
                title: Text(
                  entry.title,
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  entry.subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _historyDateLabel(entry.date),
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              if (index != entries.length - 1)
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

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key, required this.filter});
  final String filter;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.history_rounded,
      title: 'No ${filter == 'All' ? 'history' : filter.toLowerCase()} yet',
      message: 'Your activity will appear here when it is recorded.',
      neutralBadge: true,
      borderRadius: 15,
    );
  }
}

String _historyDateLabel(DateTime date) {
  final now = DateTime.now();
  final day = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  final difference = today.difference(day).inDays;
  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  return '${date.day}/${date.month}';
}
