import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/features/progress/domain/models/workout_history_item.dart';
import 'package:workout_app/i18n/strings.g.dart';

import 'progress_card_decoration.dart';
import 'progress_empty_state.dart';

/// Daftar latihan terakhir. Menampilkan maksimal tiga item kecuali [expanded].
class RecentWorkoutsCard extends StatelessWidget {
  const RecentWorkoutsCard({
    super.key,
    required this.workouts,
    this.expanded = false,
  });

  final List<WorkoutHistoryItem> workouts;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return ProgressEmptyState(
        icon: Icons.fitness_center_rounded,
        title: context.t.core.progress.workout.noRecentWorkouts.title,
        message: context.t.core.progress.workout.noRecentWorkouts.message,
        compact: true,
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final items = expanded ? workouts : workouts.take(3).toList();

    return Container(
      decoration: progressCardDecoration(context),
      child: Column(
        children: List.generate(items.length, (index) {
          final workout = items[index];
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
                    color: isDark
                        ? colorScheme.primaryContainer
                        : AppColors.limeSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 17,
                    color: isDark ? colorScheme.primary : AppColors.greenDark,
                  ),
                ),
                title: Text(
                  workout.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  '${workout.dateText} · ${workout.durationText} · ${workout.caloriesText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 9,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: 19,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (index != items.length - 1)
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
