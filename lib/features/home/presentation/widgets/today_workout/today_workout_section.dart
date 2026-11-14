import 'package:flutter/material.dart';

import 'today_workout_active_card.dart';
import 'today_workout_no_program_view.dart';
import 'today_workout_rest_day_view.dart';
export 'today_workout_active_card.dart';
export 'today_workout_no_program_view.dart';
export 'today_workout_rest_day_view.dart';

enum WorkoutCardState { active, restDay, noProgram }

/// Dispatcher Section untuk Latihan Hari Ini (Menampilkan Active, Rest Day, atau No Program)
class TodayWorkoutSection extends StatelessWidget {
  final WorkoutCardState state;
  final String sessionTitle;
  final String targetMuscles;
  final int durationMinutes;
  final int estimatedCalories;
  final VoidCallback onStartWorkout;
  final VoidCallback onViewPlan;
  final VoidCallback? onCreateProgram;

  const TodayWorkoutSection({
    super.key,
    required this.state,
    required this.sessionTitle,
    required this.targetMuscles,
    required this.durationMinutes,
    this.estimatedCalories = 280,
    required this.onStartWorkout,
    required this.onViewPlan,
    this.onCreateProgram,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case WorkoutCardState.restDay:
        return const TodayWorkoutRestDayView();
      case WorkoutCardState.noProgram:
        return TodayWorkoutNoProgramView(
          onCreateProgram: onCreateProgram ?? onViewPlan,
        );
      case WorkoutCardState.active:
        return TodayWorkoutActiveCard(
          sessionTitle: sessionTitle,
          targetMuscles: targetMuscles,
          durationMinutes: durationMinutes,
          estimatedCalories: estimatedCalories,
          onStartWorkout: onStartWorkout,
          onViewPlan: onViewPlan,
        );
    }
  }
}
