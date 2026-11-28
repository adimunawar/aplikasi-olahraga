import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_about.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildSubject({
    String gender = 'male',
    int age = 28,
    ValueChanged<String>? onGenderChanged,
    ValueChanged<int>? onAgeChanged,
    Brightness brightness = Brightness.dark,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: StepAbout(
            gender: gender,
            age: age,
            onGenderChanged: onGenderChanged ?? (_) {},
            onAgeChanged: onAgeChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders gender cards, age stepper, and handles selection', (
    tester,
  ) async {
    String? selectedGender;
    int? updatedAge;

    await tester.pumpWidget(
      buildSubject(
        onGenderChanged: (val) => selectedGender = val,
        onAgeChanged: (val) => updatedAge = val,
      ),
    );

    final t = Translations.of(tester.element(find.byType(StepAbout)));
    expect(find.text(t.onboarding.about.title), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.textContaining('28'), findsOneWidget);

    await tester.tap(find.text(t.onboarding.about.female));
    await tester.pump();
    expect(selectedGender, 'female');

    final addButton = find.byIcon(Icons.add_rounded);
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pump();
    expect(updatedAge, 29);
  });

  testWidgets('renders cleanly in light mode', (tester) async {
    await tester.pumpWidget(
      buildSubject(gender: 'female', brightness: Brightness.light),
    );

    expect(find.byType(StepAbout), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
