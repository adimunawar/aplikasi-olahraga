import 'package:material_ui/material_ui.dart';

import 'package:workout_app/i18n/strings.g.dart';

import '../../controllers/progress_state.dart';
import '../shared/progress_shared_widgets.dart';

/// Tab Ringkasan (Overview) pada Halaman Progress
class ProgressOverviewTab extends StatelessWidget {
  final ProgressState state;

  const ProgressOverviewTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final metrics = state.metrics;
    final completion = metrics.weeklyTarget > 0
        ? (metrics.completedThisWeek / metrics.weeklyTarget * 100)
              .clamp(0, 100)
              .round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressSectionHeading(
          title: context.t.core.progress.overviewTitle,
          subtitle: context.t.core.progress.overviewSubtitle,
        ),
        const SizedBox(height: 13),
        if (metrics.workoutCount == 0)
          ProgressEmptyState(
            icon: Icons.fitness_center_rounded,
            title: context.t.core.progress.noWorkoutData.title,
            message: context.t.core.progress.noWorkoutData.message,
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 76,
            children: [
              ProgressReveal(
                child: MetricCard(
                  icon: Icons.fitness_center_rounded,
                  value: '${metrics.workoutCount}',
                  label: context.t.core.progress.metrics.workouts,
                ),
              ),
              ProgressReveal(
                child: MetricCard(
                  icon: Icons.check_circle_outline_rounded,
                  value: '$completion%',
                  label: context.t.core.progress.metrics.completion,
                ),
              ),
              ProgressReveal(
                child: MetricCard(
                  icon: Icons.access_time_rounded,
                  value: formatProgressDuration(context, metrics.totalMinutes),
                  label: context.t.core.progress.metrics.trainingTime,
                ),
              ),
              ProgressReveal(
                child: MetricCard(
                  icon: Icons.local_fire_department_outlined,
                  value: metrics.streakDays == 1
                      ? context.t.core.streak.daySingular(
                          count: metrics.streakDays,
                        )
                      : context.t.core.streak.dayPlural(
                          count: metrics.streakDays,
                        ),
                  label: context.t.core.progress.metrics.currentStreak,
                ),
              ),
            ],
          ),
        const SizedBox(height: 22),
        ProgressSectionHeading(title: context.t.core.progress.programProgress),
        const SizedBox(height: 11),
        if (state.hasActiveProgram)
          ProgressReveal(
            child: ProgramCard(
              title: state.activeProgramTitle,
              week: state.activeProgramWeek,
              totalWeeks: state.activeProgramTotalWeeks,
              percent: state.activeProgramPercent,
            ),
          )
        else
          ProgressEmptyState(
            icon: Icons.flag_outlined,
            title: context.t.core.progress.noActiveProgram.title,
            message: context.t.core.progress.noActiveProgram.message,
            compact: true,
          ),
        const SizedBox(height: 22),
        ProgressSectionHeading(
          title: context.t.core.progress.recentHighlights,
          trailing: Icons.info_outline,
        ),
        const SizedBox(height: 11),
        ProgressReveal(
          child: HighlightsCard(
            completed: metrics.completedThisWeek,
            target: metrics.weeklyTarget,
            weightChange: state.weightChange,
            streak: metrics.streakDays,
            hasWeightData:
                state.weightHistory.length >= 2 &&
                state.weightChange.abs() >= 0.05,
          ),
        ),
        const SizedBox(height: 18),
        const ProgressReveal(child: KeepGoingCard()),
      ],
    );
  }
}
