import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/core/database/models/workout_session_entity.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/features/program/domain/models/program_lifecycle.dart';
import 'package:workout_app/features/program/domain/services/program_lifecycle_calculator.dart';
import 'package:workout_app/features/program/domain/services/program_week_schedule.dart';
import 'package:workout_app/features/workouts/domain/services/week_progress_calculator.dart';

import '../workouts_empty_states.dart';
import 'active_program_card.dart';
import 'weekly_schedule_section.dart';

/// Tab tampilan "Program Saya" pada layar Workouts.
class WorkoutsMyProgramTab extends StatelessWidget {
  final TrainingProgramEntity? activeProgram;
  final UserProfileEntity? profile;
  final List<ProgramSessionEntity> programSessions;
  final List<WorkoutSessionEntity> programWorkoutHistory;
  final WorkoutSessionEntity? activeSession;
  final int? selectedWeek;
  final ValueChanged<int> onWeekSelected;

  const WorkoutsMyProgramTab({
    super.key,
    required this.activeProgram,
    required this.profile,
    required this.programSessions,
    required this.programWorkoutHistory,
    required this.activeSession,
    required this.selectedWeek,
    required this.onWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    final program = activeProgram;
    if (program == null) {
      return const ProgramEmptyState();
    }

    final configuredWeeks = profile?.targetTimeframeWeeks ?? 0;
    final totalWeeks = configuredWeeks > 0
        ? configuredWeeks
        : (program.endDate != null ? program.durationWeeks : 8);
    final today = ProgramWeekSchedule.dateOnly(DateTime.now());

    final progressWithActiveLifecycle = WeekProgressCalculator.calculate(
      programStartDate: program.startDate,
      totalWeeks: totalWeeks,
      currentWeek: ProgramWeekSchedule.currentWeek(
        programStartDate: program.startDate,
        today: today,
        totalWeeks: totalWeeks,
      ),
      availableDays: profile?.availableDays ?? const [],
      sessions: programSessions,
      history: programWorkoutHistory,
    );

    final totalProgramSessions = progressWithActiveLifecycle.fold<int>(
      0,
      (sum, item) => sum + item.totalSessions,
    );
    final completedProgramSessions = progressWithActiveLifecycle.fold<int>(
      0,
      (sum, item) => sum + item.completedSessions,
    );

    final lifecycle = ProgramLifecycleCalculator.resolve(
      programStartDate: program.startDate,
      totalWeeks: totalWeeks,
      today: today,
      storedStatus: program.status,
      completedSessions: completedProgramSessions,
      totalSessions: totalProgramSessions,
    );
    final currentWeek = lifecycle.currentWeek;

    final weekProgress = lifecycle.state == ProgramLifecycle.active
        ? progressWithActiveLifecycle
        : WeekProgressCalculator.calculate(
            programStartDate: program.startDate,
            totalWeeks: totalWeeks,
            currentWeek: currentWeek,
            availableDays: profile?.availableDays ?? const [],
            sessions: programSessions,
            history: programWorkoutHistory,
            lifecycle: lifecycle.state,
          );

    final effectiveSelectedWeek = (selectedWeek ?? currentWeek)
        .clamp(1, totalWeeks)
        .toInt();

    final weeklySessions = ProgramWeekSchedule.build(
      programStartDate: program.startDate,
      weekNumber: effectiveSelectedWeek,
      availableDays: profile?.availableDays ?? const [],
      sessions: programSessions,
    );

    final progressByWeek = {
      for (final item in weekProgress) item.weekNumber: item,
    };
    final selectedProgress = progressByWeek[effectiveSelectedWeek];
    final completedThisWeek = selectedProgress?.completedSessions ?? 0;

    final progressPercent = lifecycle.completionRate;
    final percentInt = (progressPercent * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActiveProgramCard(
            program: program,
            totalWeeks: totalWeeks,
            lifecycle: lifecycle,
            progressPercent: progressPercent,
            percentInt: percentInt,
            onTap: () =>
                context.push(AppRoutes.programDetail, extra: program.id),
          ),
          const SizedBox(height: 24),
          WeeklyScheduleSection(
            weeklySessions: weeklySessions,
            selectedWeek: effectiveSelectedWeek,
            currentWeek: currentWeek,
            totalWeeks: totalWeeks,
            progressByWeek: progressByWeek,
            completedThisWeek: completedThisWeek,
            lifecycle: lifecycle,
            activeSession: activeSession,
            program: program,
            profile: profile,
            programWorkoutHistory: programWorkoutHistory,
            onWeekSelected: onWeekSelected,
          ),
        ],
      ),
    );
  }
}
