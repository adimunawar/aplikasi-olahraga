import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_weight.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildSubject({
    double currentWeightKg = 65,
    double targetWeightKg = 62,
    String gender = 'male',
    ValueChanged<double>? onCurrentWeightChanged,
    ValueChanged<double>? onTargetWeightChanged,
    Brightness brightness = Brightness.dark,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: StepWeight(
            currentWeightKg: currentWeightKg,
            targetWeightKg: targetWeightKg,
            gender: gender,
            onCurrentWeightChanged: onCurrentWeightChanged ?? (_) {},
            onTargetWeightChanged: onTargetWeightChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders scale painter, character, and weight steppers', (
    tester,
  ) async {
    double? updatedCurrentWeight;
    double? updatedTargetWeight;

    await tester.pumpWidget(
      buildSubject(
        onCurrentWeightChanged: (val) => updatedCurrentWeight = val,
        onTargetWeightChanged: (val) => updatedTargetWeight = val,
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    final addButtons = find.byIcon(Icons.add_rounded);
    expect(addButtons, findsNWidgets(2));

    await tester.tap(addButtons.first);
    await tester.pump();
    expect(updatedCurrentWeight, 65.5);

    await tester.tap(addButtons.last);
    await tester.pump();
    expect(updatedTargetWeight, 62.5);
  });

  testWidgets('uses women_full_body asset when gender is female', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(gender: 'female'));

    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/women_full_body.webp',
    );
  });

  testWidgets('renders cleanly in light mode', (tester) async {
    await tester.pumpWidget(buildSubject(brightness: Brightness.light));

    expect(find.byType(StepWeight), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
