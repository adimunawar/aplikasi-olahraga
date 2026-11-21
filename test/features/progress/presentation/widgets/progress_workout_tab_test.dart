import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/progress/domain/models/day_activity.dart';
import 'package:workout_app/features/progress/domain/models/movement_volume_data.dart';
import 'package:workout_app/features/progress/domain/models/progress_metrics.dart';
import 'package:workout_app/features/progress/domain/models/workout_history_item.dart';
import 'package:workout_app/features/progress/presentation/controllers/progress_state.dart';
import 'package:workout_app/features/progress/presentation/widgets/shared/progress_shared_widgets.dart';
import 'package:workout_app/features/progress/presentation/widgets/workout/progress_workout_tab.dart';
import 'package:workout_app/features/progress/presentation/widgets/workout/progress_workout_widgets.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildWidget(ProgressState state) {
    return TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProgressWorkoutTab(state: state)),
        ),
      ),
    );
  }

  testWidgets('renders empty performance state when workoutCount is 0', (
    tester,
  ) async {
    const state = ProgressState(metrics: ProgressMetrics(workoutCount: 0));

    await tester.pumpWidget(buildWidget(state));
    await tester.pumpAndSettle();

    expect(find.byType(ProgressEmptyState), findsOneWidget);
    expect(find.byType(WorkoutStatCard), findsNothing);
  });

  testWidgets('renders full workout tab content when data is populated', (
    tester,
  ) async {
    const state = ProgressState(
      metrics: ProgressMetrics(
        workoutCount: 4,
        completedThisWeek: 2,
        weeklyTarget: 4,
        totalMinutes: 90,
      ),
      hasActiveProgram: true,
      activeProgramTitle: 'Strength Program',
      activeProgramWeek: 1,
      activeProgramTotalWeeks: 4,
      activeProgramPercent: 25,
      weeklyActivity: [
        DayActivity(day: 'Mon', minutes: 45),
        DayActivity(day: 'Wed', minutes: 45),
      ],
      movementVolume: [
        MovementVolumeData(pattern: 'push', totalSets: 6, totalReps: 60),
      ],
      recentWorkouts: [
        WorkoutHistoryItem(
          id: 'w1',
          title: 'Upper Body A',
          dateText: '2026-11-20',
          durationText: '45 min',
          caloriesText: '250 kcal',
        ),
      ],
    );

    await tester.pumpWidget(buildWidget(state));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutStatCard), findsNWidgets(3));
    expect(find.byType(ProgramCard), findsOneWidget);
    expect(find.text('Strength Program'), findsOneWidget);
    expect(find.byType(WeeklyActivityCard), findsOneWidget);
    expect(find.byType(TrainingVolumeCard), findsOneWidget);
    expect(find.byType(RecentWorkoutsCard), findsOneWidget);
    expect(find.text('Upper Body A'), findsOneWidget);
  });
}
