import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_height.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildSubject({
    double heightCm = 170,
    ValueChanged<double>? onHeightChanged,
    Brightness brightness = Brightness.dark,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: StepHeight(
            heightCm: heightCm,
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

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('170 cm'), findsOneWidget);
  });

  testWidgets('renders cleanly in light mode', (tester) async {
    await tester.pumpWidget(buildSubject(brightness: Brightness.light));

    expect(find.byType(StepHeight), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
