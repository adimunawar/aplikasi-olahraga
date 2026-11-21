import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/data/datasources/progress_supabase_datasource.dart';

void main() {
  const datasource = ProgressSupabaseDatasource();

  group('ProgressSupabaseDatasource (Local-First & Consent Protected)', () {
    test(
      'fetchTopMetrics returns empty metrics when unauthenticated or offline',
      () async {
        // By default without Supabase Auth session, canSyncToCloud is false
        final metrics = await datasource.fetchTopMetrics();

        expect(metrics.workoutCount, 0);
        expect(metrics.caloriesBurned, 0);
        expect(metrics.totalMinutes, 0);
        expect(metrics.streakDays, 0);
      },
    );

    test('fetchTopMetrics ignores default_user placeholder id', () async {
      final metrics = await datasource.fetchTopMetrics(userId: 'default_user');

      expect(metrics.workoutCount, 0);
      expect(metrics.caloriesBurned, 0);
    });

    test(
      'fetchWeightHistory returns empty list when unauthenticated',
      () async {
        final history = await datasource.fetchWeightHistory();

        expect(history, isEmpty);
      },
    );

    test('fetchWeightHistory ignores default_user placeholder id', () async {
      final history = await datasource.fetchWeightHistory(
        userId: 'default_user',
      );

      expect(history, isEmpty);
    });

    test(
      'fetchRecentWorkouts returns empty list when unauthenticated',
      () async {
        final workouts = await datasource.fetchRecentWorkouts();

        expect(workouts, isEmpty);
      },
    );

    test('fetchRecentWorkouts ignores default_user placeholder id', () async {
      final workouts = await datasource.fetchRecentWorkouts(
        userId: 'default_user',
      );

      expect(workouts, isEmpty);
    });

    test(
      'recordWeight does not throw when unauthenticated and silently skips',
      () async {
        // Offline/unauthenticated recordWeight should not crash
        await expectLater(datasource.recordWeight(weightKg: 72.5), completes);
      },
    );
  });
}
