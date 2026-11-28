import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_goal.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildSubject({
    String selectedGoal = 'muscle_gain',
    ValueChanged<String>? onGoalSelected,
    Brightness brightness = Brightness.dark,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: StepGoal(
            selectedGoal: selectedGoal,
            onGoalSelected: onGoalSelected ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders goal options with asset images and handles tap', (
    tester,
  ) async {
    String? tappedGoal;

    await tester.pumpWidget(
      buildSubject(onGoalSelected: (goal) => tappedGoal = goal),
    );

    final t = Translations.of(tester.element(find.byType(StepGoal)));
    expect(find.text(t.onboarding.goal.title), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(3));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text(t.onboarding.goal.options[1].title));
    await tester.pump();

    expect(tappedGoal, t.onboarding.goal.options[1].id);
  });

  testWidgets('renders cleanly in light mode', (tester) async {
    await tester.pumpWidget(
      buildSubject(selectedGoal: 'maintenance', brightness: Brightness.light),
    );

    expect(find.byType(StepGoal), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
