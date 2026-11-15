import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/program/domain/models/program_lifecycle.dart';
import 'package:workout_app/features/program/domain/services/program_lifecycle_calculator.dart';

void main() {
  final today = DateTime(2026, 11, 15);

  ProgramLifecycleInfo resolve({
    required DateTime start,
    int totalWeeks = 4,
    String storedStatus = 'active',
    int completed = 0,
    int total = 0,
  }) {
    return ProgramLifecycleCalculator.resolve(
      programStartDate: start,
      totalWeeks: totalWeeks,
      today: today,
      storedStatus: storedStatus,
      completedSessions: completed,
      totalSessions: total,
    );
  }

  group('ProgramLifecycleCalculator', () {
    test('marks a program that starts in the future as not started', () {
      final info = resolve(start: DateTime(2026, 11, 20));

      expect(info.state, ProgramLifecycle.notStarted);
      expect(info.canStartWorkout, isFalse);
      expect(info.isFinished, isFalse);
      expect(info.currentWeek, 1);
      expect(info.daysRemaining, 0);
    });

    test('keeps a running program active and reports days remaining', () {
      final info = resolve(start: DateTime(2026, 11, 2)); // 13 days ago

      expect(info.state, ProgramLifecycle.active);
      expect(info.canStartWorkout, isTrue);
      expect(info.currentWeek, 2);
      expect(info.endDate, DateTime(2026, 11, 29));
      // End date is inclusive: Nov 29 - Nov 15 = 14 days left.
      expect(info.daysRemaining, 14);
    });

    test('treats the last program day as still active', () {
      final info = resolve(
        start: DateTime(2026, 11, 9),
        totalWeeks: 1,
      );

      expect(info.endDate, today);
      expect(info.state, ProgramLifecycle.active);
    });

    test('expires a program after its duration even with no sessions left', () {
      final info = resolve(
        start: DateTime(2026, 8, 1),
        totalWeeks: 12,
        completed: 4,
        total: 12,
      );

      expect(info.state, ProgramLifecycle.expired);
      expect(info.canStartWorkout, isFalse);
      expect(info.isFinished, isTrue);
      expect(info.currentWeek, 12);
      expect(info.daysRemaining, 0);
      expect(info.completionRate, closeTo(1 / 3, 0.0001));
    });

    test('completes a program when every scheduled session is done', () {
      final info = resolve(
        start: DateTime(2026, 11, 2),
        completed: 12,
        total: 12,
      );

      expect(info.state, ProgramLifecycle.completed);
      expect(info.isFinished, isTrue);
      expect(info.currentWeek, 2);
    });

    test('honours the stored completed status', () {
      final info = resolve(
        start: DateTime(2026, 8, 1),
        storedStatus: 'completed',
        completed: 1,
        total: 12,
      );

      expect(info.state, ProgramLifecycle.completed);
    });

    test('an expired program with no schedule is still expired', () {
      final info = resolve(start: DateTime(2026, 8, 1));

      expect(info.state, ProgramLifecycle.expired);
      expect(info.currentWeek, 4);
    });

    test('clamps total weeks below one', () {
      final info = resolve(start: today, totalWeeks: 0);

      expect(info.totalWeeks, 1);
      expect(info.currentWeek, 1);
      expect(info.endDate, DateTime(2026, 11, 21));
      expect(info.state, ProgramLifecycle.active);
    });
  });
}
