import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/workouts/domain/models/week_progress.dart';
import 'package:workout_app/features/workouts/presentation/widgets/my_program/weekly_schedule_selector.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  WeekProgress week(int number, int completed, int total, WeekStatus status) {
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
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
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

  group('WeeklyScheduleSelector Pill Design & Theme Fidelity', () {
    testWidgets('renders pill status indicators accurately', (tester) async {
      await pumpSelector(
        tester,
        selectedWeek: 3,
        currentWeek: 3,
        totalWeeks: 5,
        progress: {
          1: week(1, 3, 3, WeekStatus.completed),
          2: week(2, 3, 3, WeekStatus.completed),
          3: week(3, 0, 3, WeekStatus.current),
          4: week(4, 0, 3, WeekStatus.upcoming),
          5: week(5, 0, 3, WeekStatus.upcoming),
        },
        onWeekSelected: (_) {},
      );

      // Completed weeks (W1, W2) show check icon
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));

      // Week labels W1 to W5 are present
      expect(find.text('W1'), findsOneWidget);
      expect(find.text('W2'), findsOneWidget);
      expect(find.text('W3'), findsOneWidget);
      expect(find.text('W4'), findsOneWidget);
      expect(find.text('W5'), findsOneWidget);
    });

    testWidgets('renders properly in Dark Mode without crashing', (
      tester,
    ) async {
      await pumpSelector(
        tester,
        selectedWeek: 3,
        currentWeek: 3,
        totalWeeks: 5,
        progress: {
          1: week(1, 3, 3, WeekStatus.completed),
          2: week(2, 3, 3, WeekStatus.completed),
          3: week(3, 0, 3, WeekStatus.current),
          4: week(4, 0, 3, WeekStatus.upcoming),
          5: week(5, 0, 3, WeekStatus.upcoming),
        },
        onWeekSelected: (_) {},
        themeMode: ThemeMode.dark,
      );

      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
      expect(find.text('W3'), findsOneWidget);
    });

    testWidgets('allows tapping any week pill to select week', (tester) async {
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
        onWeekSelected: (w) => selected = w,
      );

      await tester.tap(find.text('W4'));
      await tester.pumpAndSettle();

      expect(selected, 4);
    });

    testWidgets('falls back gracefully when progress data is empty', (
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
      expect(find.text('W2'), findsOneWidget);
    });
  });
}
