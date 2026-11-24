import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/progress/domain/models/weight_record.dart';
import 'package:workout_app/features/progress/domain/models/workout_history_item.dart';
import 'package:workout_app/features/progress/presentation/controllers/progress_state.dart';
import 'package:workout_app/features/progress/presentation/widgets/history/progress_history_tab.dart';
import 'package:workout_app/features/progress/presentation/widgets/history/progress_history_widgets.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildWidget(ProgressState state) {
    return TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProgressHistoryTab(state: state)),
        ),
      ),
    );
  }

  testWidgets('renders empty state when there are no history entries', (
    tester,
  ) async {
    const state = ProgressState();

    await tester.pumpWidget(buildWidget(state));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryEmptyState), findsOneWidget);
    expect(find.byType(HistoryFilterChip), findsNWidgets(3));
  });

  testWidgets('renders history entries and handles filter chip toggles', (
    tester,
  ) async {
    final state = ProgressState(
      recentWorkouts: const [
        WorkoutHistoryItem(
          id: 'w1',
          title: 'Full Body Blast',
          dateText: '2026-11-20',
          durationText: '30 min',
          caloriesText: '200 kcal',
        ),
      ],
      weightHistory: [
        WeightRecord(
          id: 'wr1',
          weightKg: 70.0,
          recordedAt: DateTime.parse('2026-11-19 08:00:00'),
        ),
      ],
    );

    await tester.pumpWidget(buildWidget(state));
    await tester.pumpAndSettle();

    // Default 'All' filter shows both workout and measurement
    expect(find.text('Full Body Blast'), findsOneWidget);
    expect(find.text('Body Measurement'), findsOneWidget);

    // Tap 'Workout' filter chip
    await tester.tap(find.text(t.core.progress.history.workout));
    await tester.pumpAndSettle();

    expect(find.text('Full Body Blast'), findsOneWidget);
    expect(find.text('Body Measurement'), findsNothing);

    // Tap 'Measurement' filter chip
    await tester.tap(find.text(t.core.progress.history.measurement));
    await tester.pumpAndSettle();

    expect(find.text('Full Body Blast'), findsNothing);
    expect(find.text('Body Measurement'), findsOneWidget);
  });

  testWidgets('sort button toggles history order', (tester) async {
    final state = ProgressState(
      weightHistory: [
        WeightRecord(
          id: 'wr1',
          weightKg: 70.0,
          recordedAt: DateTime.parse('2026-11-10 08:00:00'),
        ),
        WeightRecord(
          id: 'wr2',
          weightKg: 69.5,
          recordedAt: DateTime.parse('2026-11-20 08:00:00'),
        ),
      ],
    );

    await tester.pumpWidget(buildWidget(state));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(2));

    // Tap sort toggle button
    await tester.tap(find.byIcon(Icons.swap_vert_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
