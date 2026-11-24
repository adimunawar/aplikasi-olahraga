import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/domain/models/weight_record.dart';
import 'package:workout_app/features/progress/presentation/controllers/progress_state.dart';
import 'package:workout_app/features/progress/presentation/widgets/body/progress_body_tab.dart';
import 'package:workout_app/features/progress/presentation/widgets/shared/progress_shared_widgets.dart';
import 'package:workout_app/i18n/strings.g.dart';

Widget _buildTestApp({
  required ProgressState state,
  int rangeWeeks = 8,
  ValueChanged<double?>? onLogWeight,
}) {
  return TranslationProvider(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ProgressBodyTab(
            state: state,
            rangeWeeks: rangeWeeks,
            onLogWeight: onLogWeight ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  group('ProgressBodyTab (Without Mockito)', () {
    testWidgets('renders body metric selector chips', (tester) async {
      const state = ProgressState();

      await tester.pumpWidget(_buildTestApp(state: state));
      await tester.pumpAndSettle();

      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Muscle Mass'), findsOneWidget);
      expect(find.text('Body Fat'), findsOneWidget);
    });

    testWidgets('switches to Muscle Mass and shows MetricNotTrackedCard', (
      tester,
    ) async {
      const state = ProgressState();

      await tester.pumpWidget(_buildTestApp(state: state));
      await tester.pumpAndSettle();

      // Tap Muscle Mass chip
      await tester.tap(find.text('Muscle Mass'));
      await tester.pumpAndSettle();

      expect(find.byType(MetricNotTrackedCard), findsOneWidget);
      expect(find.textContaining('Muscle Mass'), findsWidgets);
    });

    testWidgets(
      'displays WeightTrendCard and CurrentWeightSummary when weight data exists',
      (tester) async {
        final state = ProgressState(
          currentWeight: 72.0,
          weightChange: -1.5,
          weightHistory: [
            WeightRecord(
              id: 'w1',
              weightKg: 73.5,
              recordedAt: DateTime.now().subtract(const Duration(days: 14)),
            ),
            WeightRecord(id: 'w2', weightKg: 72.0, recordedAt: DateTime.now()),
          ],
        );

        await tester.pumpWidget(_buildTestApp(state: state));
        await tester.pumpAndSettle();

        expect(find.byType(WeightTrendCard), findsOneWidget);
        expect(find.byType(CurrentWeightSummary), findsOneWidget);
        expect(find.text('72.0 kg'), findsOneWidget);
      },
    );

    testWidgets(
      'triggers onLogWeight callback when log measurement button is tapped',
      (tester) async {
        double? loggedWeight;
        final state = ProgressState(
          currentWeight: 75.0,
          weightHistory: [
            WeightRecord(id: 'w1', weightKg: 75.0, recordedAt: DateTime.now()),
          ],
        );

        await tester.pumpWidget(
          _buildTestApp(
            state: state,
            onLogWeight: (val) {
              loggedWeight = val;
            },
          ),
        );
        await tester.pumpAndSettle();

        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);

        await tester.tap(button);
        await tester.pumpAndSettle();

        expect(loggedWeight, 75.0);
      },
    );
  });
}
