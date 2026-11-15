import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/workouts/domain/models/week_progress.dart';
import 'package:workout_app/features/workouts/presentation/widgets/weekly_schedule_selector.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  WeekProgress week(
    int number,
    int completed,
    int total,
    WeekStatus status,
  ) {
    return WeekProgress(
      weekNumber: number,
      completedSessions: completed,
      totalSessions: total,
      status: status,
    );
  }

  Future<void> pumpSelector(
    WidgetTester tester, {
    required int selectedWeek,
    required int currentWeek,
    required int totalWeeks,
    required Map<int, WeekProgress> progress,
    required ValueChanged<int> onWeekSelected,
  }) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 420,
                child: WeeklyScheduleSelector(
                  selectedWeek: selectedWeek,
                  currentWeek: currentWeek,
                  totalWeeks: totalWeeks,
                  weekProgress: progress,
                  onWeekSelected: onWeekSelected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('WeeklyScheduleSelector', () {
    testWidgets('renders status from history instead of week number', (
      tester,
    ) async {
      await pumpSelector(
        tester,
        selectedWeek: 4,
        currentWeek: 4,
        totalWeeks: 5,
        progress: {
          1: week(1, 3, 3, WeekStatus.completed),
          2: week(2, 1, 3, WeekStatus.partial),
          3: week(3, 0, 3, WeekStatus.missed),
          4: week(4, 0, 3, WeekStatus.current),
          5: week(5, 0, 3, WeekStatus.upcoming),
        },
        onWeekSelected: (_) {},
      );

      // Current week keeps the current badge.
      expect(find.text('Saat Ini'), findsOneWidget);

      // Fully completed -> check.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Partially completed -> small progress ring.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Missed -> warning.
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

      // Upcoming -> preview affordance, not a full lock.
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });

    testWidgets('allows opening future weeks for preview', (tester) async {
      var selected = 1;

      await pumpSelector(
        tester,
        selectedWeek: 1,
        currentWeek: 1,
        totalWeeks: 5,
        progress: {
          1: week(1, 0, 3, WeekStatus.current),
          2: week(2, 0, 3, WeekStatus.upcoming),
          3: week(3, 0, 3, WeekStatus.upcoming),
          4: week(4, 0, 3, WeekStatus.upcoming),
          5: week(5, 0, 3, WeekStatus.upcoming),
        },
        onWeekSelected: (week) => selected = week,
      );

      await tester.tap(find.text('W4'));
      await tester.pumpAndSettle();

      expect(selected, 4);
    });

    testWidgets('falls back gracefully when progress data is missing', (
      tester,
    ) async {
      await pumpSelector(
        tester,
        selectedWeek: 2,
        currentWeek: 2,
        totalWeeks: 3,
        progress: const {},
        onWeekSelected: (_) {},
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Saat Ini'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
