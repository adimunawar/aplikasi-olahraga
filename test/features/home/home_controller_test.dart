import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/home/presentation/controllers/home_controller.dart';
import 'package:workout_app/features/home/presentation/controllers/home_state.dart';

void main() {
  group('HomeController - Program Week Calculation (Point 2)', () {
    test('Calculates Week 1 on the start date', () {
      final startDate = DateTime(2026, 11, 1);
      final targetDate = DateTime(2026, 11, 1);

      final week = HomeController.calculateProgramWeek(
        startDate: startDate,
        targetDate: targetDate,
        totalWeeks: 12,
      );

      expect(week, equals(1));
    });

    test('Calculates Week 1 for any day in the first 7 days (day 0 to 6)', () {
      final startDate = DateTime(2026, 11, 1);

      for (int i = 0; i < 7; i++) {
        final targetDate = startDate.add(Duration(days: i));
        final week = HomeController.calculateProgramWeek(
          startDate: startDate,
          targetDate: targetDate,
          totalWeeks: 12,
        );
        expect(week, equals(1), reason: 'Day $i should be in Week 1');
      }
    });

    test('Calculates Week 2 starting exactly on day 7', () {
      final startDate = DateTime(2026, 11, 1);
      final targetDate = startDate.add(const Duration(days: 7));

      final week = HomeController.calculateProgramWeek(
        startDate: startDate,
        targetDate: targetDate,
        totalWeeks: 12,
      );

      expect(week, equals(2));
    });

    test('Calculates Week 3 on day 14', () {
      final startDate = DateTime(2026, 11, 1);
      final targetDate = startDate.add(const Duration(days: 14));

      final week = HomeController.calculateProgramWeek(
        startDate: startDate,
        targetDate: targetDate,
        totalWeeks: 12,
      );

      expect(week, equals(3));
    });

    test('Clamps week to totalWeeks when elapsed time exceeds totalWeeks', () {
      final startDate = DateTime(2026, 1, 1);
      final targetDate = DateTime(2026, 12, 1); // 11 months later

      final week = HomeController.calculateProgramWeek(
        startDate: startDate,
        targetDate: targetDate,
        totalWeeks: 12,
      );

      expect(week, equals(12));
    });

    test('Returns Week 1 if targetDate is before startDate', () {
      final startDate = DateTime(2026, 11, 10);
      final targetDate = DateTime(2026, 11, 5);

      final week = HomeController.calculateProgramWeek(
        startDate: startDate,
        targetDate: targetDate,
        totalWeeks: 12,
      );

      expect(week, equals(1));
    });
  });

  group('HomeState - Error Types & Immutability (Point 3)', () {
    test('Default errorType is none', () {
      const state = HomeState();
      expect(state.errorType, equals(HomeErrorType.none));
      expect(state.isLoading, isTrue);
    });

    test('copyWith updates errorType and message correctly', () {
      const state = HomeState();
      final updated = state.copyWith(
        errorType: HomeErrorType.database,
        errorMessage: 'SQLite disk I/O error',
      );

      expect(updated.errorType, equals(HomeErrorType.database));
      expect(updated.errorMessage, equals('SQLite disk I/O error'));
    });

    test('Differentiates program generation error from network error', () {
      const state = HomeState();
      final genError = state.copyWith(
        errorType: HomeErrorType.programGeneration,
        errorMessage: 'Missing catalog exercise',
      );
      final netError = state.copyWith(
        errorType: HomeErrorType.network,
        errorMessage: 'Connection timed out',
      );

      expect(genError.errorType, isNot(equals(netError.errorType)));
      expect(genError.errorType, equals(HomeErrorType.programGeneration));
      expect(netError.errorType, equals(HomeErrorType.network));
    });
  });
}
