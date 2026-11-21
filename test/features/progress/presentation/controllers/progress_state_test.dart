import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/domain/models/day_activity.dart';
import 'package:workout_app/features/progress/domain/models/movement_volume_data.dart';
import 'package:workout_app/features/progress/domain/models/progress_metrics.dart';
import 'package:workout_app/features/progress/domain/models/weight_record.dart';
import 'package:workout_app/features/progress/domain/models/workout_history_item.dart';
import 'package:workout_app/features/progress/presentation/controllers/progress_state.dart';

void main() {
  group('ProgressState', () {
    test('default constructor initializes with safe zero/empty values', () {
      const state = ProgressState();

      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.currentWeight, 0);
      expect(state.heightCm, 0);
      expect(state.weightChange, 0);
      expect(state.startLabel, isEmpty);
      expect(state.endLabel, isEmpty);
      expect(state.bmiValue, 0);
      expect(state.bmiStatus, isEmpty);
      expect(state.hasActiveProgram, false);
      expect(state.activeProgramTitle, isEmpty);
      expect(state.activeProgramWeek, 0);
      expect(state.activeProgramTotalWeeks, 0);
      expect(state.activeProgramPercent, 0);
      expect(state.recentWorkouts, isEmpty);
      expect(state.weightHistory, isEmpty);
      expect(state.weeklyActivity, isEmpty);
      expect(state.movementVolume, isEmpty);
      expect(state.milestones, isEmpty);
    });

    test('copyWith updates specified fields and preserves other fields', () {
      const original = ProgressState(
        currentWeight: 70.0,
        heightCm: 175.0,
        bmiValue: 22.9,
        bmiStatus: 'Healthy',
        hasActiveProgram: true,
        activeProgramTitle: 'Hypertrophy 101',
      );

      final updated = original.copyWith(
        currentWeight: 71.5,
        weightChange: 1.5,
        isLoading: true,
        errorMessage: 'Temporary issue',
      );

      // Updated fields
      expect(updated.currentWeight, 71.5);
      expect(updated.weightChange, 1.5);
      expect(updated.isLoading, true);
      expect(updated.errorMessage, 'Temporary issue');

      // Preserved fields
      expect(updated.heightCm, 175.0);
      expect(updated.bmiValue, 22.9);
      expect(updated.bmiStatus, 'Healthy');
      expect(updated.hasActiveProgram, true);
      expect(updated.activeProgramTitle, 'Hypertrophy 101');
    });

    test('copyWith updates collection fields properly', () {
      const original = ProgressState();

      final workouts = [
        const WorkoutHistoryItem(
          id: 'w1',
          title: 'Upper Body',
          dateText: 'Yesterday',
          durationText: '40 min',
          caloriesText: '300 kcal',
        ),
      ];

      final weights = [
        WeightRecord(
          id: 'wt1',
          weightKg: 72.0,
          recordedAt: DateTime(2026, 3, 1),
        ),
      ];

      final activities = [const DayActivity(day: 'Mon', minutes: 45)];

      final volume = [
        const MovementVolumeData(
          pattern: 'push',
          totalSets: 10,
          totalReps: 100,
        ),
      ];

      final updated = original.copyWith(
        recentWorkouts: workouts,
        weightHistory: weights,
        weeklyActivity: activities,
        movementVolume: volume,
      );

      expect(updated.recentWorkouts, workouts);
      expect(updated.weightHistory, weights);
      expect(updated.weeklyActivity, activities);
      expect(updated.movementVolume, volume);
    });

    test('copyWith updates metrics correctly', () {
      const original = ProgressState();
      const newMetrics = ProgressMetrics(
        workoutCount: 15,
        caloriesBurned: 3500,
        totalMinutes: 450,
        streakDays: 5,
        completedThisWeek: 3,
        weeklyTarget: 4,
      );

      final updated = original.copyWith(metrics: newMetrics);

      expect(updated.metrics.workoutCount, 15);
      expect(updated.metrics.caloriesBurned, 3500);
      expect(updated.metrics.totalMinutes, 450);
      expect(updated.metrics.streakDays, 5);
      expect(updated.metrics.completedThisWeek, 3);
      expect(updated.metrics.weeklyTarget, 4);
    });
  });
}
