import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/domain/models/progress_metrics.dart';

void main() {
  group('ProgressMetrics', () {
    test('default constructor initializes with zeroes', () {
      const metrics = ProgressMetrics();

      expect(metrics.workoutCount, 0);
      expect(metrics.caloriesBurned, 0);
      expect(metrics.totalMinutes, 0);
      expect(metrics.streakDays, 0);
      expect(metrics.completedThisWeek, 0);
      expect(metrics.weeklyTarget, 0);
    });

    test('copyWith updates specified fields correctly', () {
      const initial = ProgressMetrics(
        workoutCount: 2,
        caloriesBurned: 150,
        totalMinutes: 30,
        streakDays: 1,
        completedThisWeek: 2,
        weeklyTarget: 4,
      );

      final updated = initial.copyWith(workoutCount: 3, streakDays: 2);

      expect(updated.workoutCount, 3);
      expect(updated.caloriesBurned, 150);
      expect(updated.totalMinutes, 30);
      expect(updated.streakDays, 2);
      expect(updated.completedThisWeek, 2);
      expect(updated.weeklyTarget, 4);
    });
  });
}
