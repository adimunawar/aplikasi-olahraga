import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/core/database/models/workout_session_entity.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/features/program/domain/models/program_lifecycle.dart';
import 'package:workout_app/features/program/domain/services/program_week_schedule.dart';
import 'package:workout_app/features/workouts/domain/models/week_progress.dart';
import 'package:workout_app/i18n/strings.g.dart';

import '../workouts_empty_states.dart';
import 'week_preview_notice.dart';
import 'weekly_schedule_selector.dart';
import 'workout_session_card.dart';

/// Seksi Jadwal Mingguan yang menampilkan selector minggu dan list sesi latihan.
class WeeklyScheduleSection extends StatelessWidget {
  final List<ProgramWeekSession> weeklySessions;
  final int selectedWeek;
  final int currentWeek;
  final int totalWeeks;
  final Map<int, WeekProgress> progressByWeek;
  final int completedThisWeek;
  final ProgramLifecycleInfo lifecycle;
  final WorkoutSessionEntity? activeSession;
  final TrainingProgramEntity program;
  final UserProfileEntity? profile;
  final List<WorkoutSessionEntity> programWorkoutHistory;
  final ValueChanged<int> onWeekSelected;

  const WeeklyScheduleSection({
    super.key,
    required this.weeklySessions,
    required this.selectedWeek,
    required this.currentWeek,
    required this.totalWeeks,
    required this.progressByWeek,
    required this.completedThisWeek,
    required this.lifecycle,
    required this.activeSession,
    required this.program,
    required this.profile,
    required this.programWorkoutHistory,
    required this.onWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final titleColor = theme.colorScheme.onSurface;
    final subtextColor = theme.colorScheme.onSurfaceVariant;
    final today = ProgramWeekSchedule.dateOnly(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.workouts.weeklySchedule.title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16.5,
                color: titleColor,
              ),
            ),
            Text(
              t.workouts.weeklySchedule.workoutCount(
                completed: completedThisWeek,
                total: weeklySessions.length,
              ),
              style: AppTypography.bodySmall.copyWith(
                color: subtextColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        WeeklyScheduleSelector(
          selectedWeek: selectedWeek,
          currentWeek: currentWeek,
          totalWeeks: totalWeeks,
          weekProgress: progressByWeek,
          onWeekSelected: onWeekSelected,
        ),
        if (selectedWeek > currentWeek ||
            lifecycle.state == ProgramLifecycle.notStarted) ...[
          const SizedBox(height: 14),
          const WeekPreviewNotice(),
        ],
        const SizedBox(height: 16),
        if (weeklySessions.isEmpty)
          const NoScheduledWorkoutsState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weeklySessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final scheduled = weeklySessions[index];
              final session = scheduled.session;
              final record = _findWorkoutRecord(scheduled);
              final isCompleted =
                  record?.status == WorkoutSessionStatus.completed;
              final isToday = _isSameDate(scheduled.scheduledDate, today);
              final isCurrentSelectedWeek = selectedWeek == currentWeek;
              final isInProgress =
                  activeSession != null &&
                  activeSession!.programId == program.id &&
                  activeSession!.programDayId == session.dayNumber &&
                  _isSameDate(
                    activeSession!.scheduledDate,
                    scheduled.scheduledDate,
                  );

              final isActiveToday =
                  lifecycle.canStartWorkout &&
                  isCurrentSelectedWeek &&
                  isToday &&
                  !isCompleted &&
                  !isInProgress;
              final isMissed =
                  !isCompleted &&
                  !isInProgress &&
                  scheduled.scheduledDate.isBefore(today);
              final isReadOnly = !(isActiveToday || isInProgress);

              final workoutTitle = session.name.isNotEmpty
                  ? session.name
                  : (session.focusLabel.isNotEmpty
                        ? session.focusLabel
                        : t.workouts.title);
              final focusLabel =
                  session.focusLabel.isNotEmpty &&
                      session.focusLabel != session.name
                  ? session.focusLabel
                  : null;
              final duration = session.targetDurationMinutes > 0
                  ? session.targetDurationMinutes
                  : 30;
              final dateText = MaterialLocalizations.of(context)
                  .formatMediumDate(scheduled.scheduledDate);

              final weekNumberText = t.workouts.weeklySchedule.weekNumber(
                n: selectedWeek,
              );
              final weekDayText =
                  '$weekNumberText • ${t.workouts.session.day(n: session.dayNumber)}';
              final durationText = t.workouts.session.min(min: duration);
              final levelText = _formatLevel(t, profile?.experienceLevel);

              return WorkoutSessionCard(
                dayNumber: session.dayNumber,
                dateText: dateText,
                title: workoutTitle,
                focusLabel: focusLabel,
                durationMinutes: duration,
                isCompleted: isCompleted,
                isInProgress: isInProgress,
                isActiveToday: isActiveToday,
                isMissed: isMissed,
                onTap: () {
                  context.push(
                    AppRoutes.workoutDetail,
                    extra: WorkoutDetailArgs(
                      dayNumber: session.dayNumber,
                      weekNumber: selectedWeek,
                      programId: program.id,
                      weekDayText: weekDayText,
                      workoutTitle: workoutTitle,
                      targetMusclesText: session.focusLabel,
                      durationText: durationText,
                      levelText: levelText,
                      scheduledDate: scheduled.scheduledDate,
                      readOnly: isReadOnly,
                      activeSessionId: isInProgress ? activeSession!.id : null,
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  WorkoutSessionEntity? _findWorkoutRecord(ProgramWeekSession scheduled) {
    final targetDate = ProgramWeekSchedule.dateOnly(scheduled.scheduledDate);
    final matchingRecords = programWorkoutHistory.where((record) {
      return record.programDayId == scheduled.session.dayNumber &&
          _isSameDate(record.scheduledDate, targetDate);
    }).toList();

    for (final record in matchingRecords.reversed) {
      if (record.status == WorkoutSessionStatus.completed) return record;
    }
    return matchingRecords.isNotEmpty ? matchingRecords.last : null;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _formatLevel(Translations t, String? level) {
    if (level == null || level.isEmpty) {
      return t.onboarding.experience.options.first.title;
    }
    for (final option in t.onboarding.experience.options) {
      if (option.id.toLowerCase() == level.toLowerCase()) {
        return option.title;
      }
    }
    return level[0].toUpperCase() + level.substring(1).toLowerCase();
  }
}
