import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/progress/domain/models/progress_metrics.dart';
import 'package:workout_app/features/progress/presentation/controllers/progress_state.dart';
import 'package:workout_app/features/progress/presentation/widgets/overview/progress_overview_tab.dart';
import 'package:workout_app/features/progress/presentation/widgets/shared/progress_shared_widgets.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildWidget(ProgressState state) {
    return TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProgressOverviewTab(state: state)),
        ),
      ),
    );
  }

  testWidgets('renders empty state when metrics.workoutCount is 0', (
    tester,
  ) async {
    const state = ProgressState(metrics: ProgressMetrics(workoutCount: 0));

    await tester.pumpWidget(buildWidget(state));
    await tester.pumpAndSettle();

    expect(find.byType(ProgressEmptyState), findsWidgets);
    expect(find.byType(MetricCard), findsNothing);
  });

  testWidgets(
    'renders 4 metric cards and active program when workout data exists',
    (tester) async {
      const state = ProgressState(
        metrics: ProgressMetrics(
          workoutCount: 5,
          completedThisWeek: 3,
          weeklyTarget: 5,
          totalMinutes: 120,
          streakDays: 4,
        ),
        hasActiveProgram: true,
        activeProgramTitle: 'Morning Shred',
        activeProgramWeek: 2,
        activeProgramTotalWeeks: 6,
        activeProgramPercent: 33,
      );

      await tester.pumpWidget(buildWidget(state));
      await tester.pumpAndSettle();

      expect(find.byType(MetricCard), findsNWidgets(4));
      expect(find.text('5'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.byType(ProgramCard), findsOneWidget);
      expect(find.text('Morning Shred'), findsOneWidget);
      expect(find.byType(HighlightsCard), findsOneWidget);
      expect(find.byType(KeepGoingCard), findsOneWidget);
    },
  );
}
