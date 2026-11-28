import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_height.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildSubject({
    double heightCm = 170,
    String gender = 'male',
    ValueChanged<double>? onHeightChanged,
    Brightness brightness = Brightness.dark,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: StepHeight(
            heightCm: heightCm,
            gender: gender,
            onHeightChanged: onHeightChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders character stage, painters, and height badge', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/about-you-men.webp',
    );
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('170 cm'), findsOneWidget);
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

    expect(find.byType(StepHeight), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
