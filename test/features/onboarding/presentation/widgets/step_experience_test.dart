import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_experience.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildSubject({
    required String selectedLevel,
    required ValueChanged<String> onLevelSelected,
    Brightness brightness = Brightness.dark,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: StepExperience(
            selectedLevel: selectedLevel,
            onLevelSelected: onLevelSelected,
          ),
        ),
      ),
    );
  }

  testWidgets('renders experience options with asset images and handles tap', (
    tester,
  ) async {
    String? tappedLevel;

    await tester.pumpWidget(
      buildSubject(
        selectedLevel: 'beginner',
        onLevelSelected: (level) => tappedLevel = level,
      ),
    );

    final t = Translations.of(tester.element(find.byType(StepExperience)));
    expect(find.text(t.onboarding.experience.title), findsOneWidget);
    expect(find.text(t.onboarding.experience.subtitle), findsOneWidget);

    for (final option in t.onboarding.experience.options) {
      expect(find.text(option.title), findsOneWidget);
      expect(find.text(option.description), findsOneWidget);
    }

    expect(find.byType(Image), findsNWidgets(3));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text(t.onboarding.experience.options[1].title));
    await tester.pump();

    expect(tappedLevel, t.onboarding.experience.options[1].id);
  });

  testWidgets('renders cleanly in light mode', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        selectedLevel: 'advanced',
        onLevelSelected: (_) {},
        brightness: Brightness.light,
      ),
    );

    expect(find.byType(StepExperience), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
