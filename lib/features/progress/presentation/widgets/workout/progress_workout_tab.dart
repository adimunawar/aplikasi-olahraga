import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/i18n/strings.g.dart';

import '../../controllers/progress_state.dart';
import '../shared/progress_shared_widgets.dart';
import 'progress_workout_widgets.dart';

/// Tab Latihan (Workout) pada Halaman Progress
class ProgressWorkoutTab extends StatelessWidget {
  final ProgressState state;

  const ProgressWorkoutTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final weeklyMinutes = state.weeklyActivity.fold<int>(
      0,
      (sum, day) => sum + day.minutes,
    );
    final maxMinutes = state.weeklyActivity.fold<int>(
      0,
      (max, day) => day.minutes > max ? day.minutes : max,
    );
    final totalSets = state.movementVolume.fold<int>(
      0,
      (sum, item) => sum + item.totalSets,
    );
    final totalReps = state.movementVolume.fold<int>(
      0,
      (sum, item) => sum + item.totalReps,
    );
    final completion = state.metrics.weeklyTarget > 0
        ? (state.metrics.completedThisWeek / state.metrics.weeklyTarget * 100)
              .clamp(0, 100)
              .round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressSectionHeading(
          title: context.t.core.progress.workout.title,
          subtitle: context.t.core.progress.workout.subtitle,
        ),
        const SizedBox(height: 10),
        if (state.metrics.workoutCount == 0)
          ProgressEmptyState(
            icon: Icons.fitness_center_rounded,
            title: context.t.core.progress.workout.noPerformance.title,
            message: context.t.core.progress.workout.noPerformance.message,
          )
        else ...[
          if (state.hasActiveProgram)
            ProgramCard(
              title: state.activeProgramTitle,
              week: state.activeProgramWeek,
              totalWeeks: state.activeProgramTotalWeeks,
              percent: state.activeProgramPercent,
            )
          else
            ProgressEmptyState(
              icon: Icons.flag_outlined,
              title: context.t.core.progress.noActiveProgram.title,
              message: context.t.core.progress.noActiveProgram.message,
              compact: true,
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: WorkoutStatCard(
                  icon: Icons.fitness_center_rounded,
                  value: '${state.metrics.workoutCount}',
                  label: context.t.core.progress.metrics.workouts,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: WorkoutStatCard(
                  icon: Icons.check_circle_outline_rounded,
                  value: '$completion%',
                  label: context.t.core.progress.metrics.completion,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: WorkoutStatCard(
                  icon: Icons.access_time_rounded,
                  value: formatProgressDuration(
                    context,
                    state.metrics.totalMinutes,
                  ),
                  label: context.t.core.progress.workout.totalTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ProgressSectionHeading(
            title: context.t.core.progress.workout.weeklyActivity,
            trailing: Icons.info_outline,
          ),
          const SizedBox(height: 10),
          if (weeklyMinutes > 0)
            ProgressReveal(
              child: WeeklyActivityCard(
                days: state.weeklyActivity,
                maxMinutes: maxMinutes,
              ),
            )
          else
            ProgressEmptyState(
              icon: Icons.calendar_today_outlined,
              title: context.t.core.progress.workout.noActivity.title,
              message: context.t.core.progress.workout.noActivity.message,
              compact: true,
            ),
          const SizedBox(height: 20),
          ProgressSectionHeading(
            title: context.t.core.progress.workout.trainingVolume,
            trailing: Icons.info_outline,
          ),
          const SizedBox(height: 10),
          if (totalSets > 0)
            ProgressReveal(
              child: TrainingVolumeCard(
                totalSets: totalSets,
                totalReps: totalReps,
                activePatterns: state.movementVolume.length,
              ),
            )
          else
            ProgressEmptyState(
              icon: Icons.bar_chart_rounded,
              title: context.t.core.progress.workout.noVolume.title,
              message: context.t.core.progress.workout.noVolume.message,
              compact: true,
            ),
          const SizedBox(height: 20),
          ProgressSectionHeading(
            title: context.t.core.progress.workout.recentWorkouts,
          ),
          const SizedBox(height: 10),
          ProgressReveal(
            child: RecentWorkoutsCard(workouts: state.recentWorkouts),
          ),
          const SizedBox(height: 4),
          Text(
            context.t.core.progress.workout.trainingMinutesThisWeek(
              minutes: weeklyMinutes,
            ),
            style: AppTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
