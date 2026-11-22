import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/application/weight_analytics_service.dart';
import 'package:workout_app/features/progress/domain/models/progress_metrics.dart';
import 'package:workout_app/features/progress/domain/models/weight_record.dart';

void main() {
  group('Progress empty data defaults', () {
    test('metrics start at zero instead of sample values', () {
      const metrics = ProgressMetrics();

      expect(metrics.workoutCount, 0);
      expect(metrics.caloriesBurned, 0);
      expect(metrics.totalMinutes, 0);
      expect(metrics.streakDays, 0);
      expect(metrics.completedThisWeek, 0);
      expect(metrics.weeklyTarget, 0);
    });

    test('weight analytics does not invent a weight change or dates', () {
      const analytics = WeightAnalyticsService();

      final result = analytics.analyze(const <WeightRecord>[]);

      expect(result.currentWeight, 0);
      expect(result.weightChange, 0);
      expect(result.startLabel, isEmpty);
      expect(result.endLabel, isEmpty);
    });
  });
}
