import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_limitations.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildSubject({
    List<String> selectedLimitations = const ['none'],
    ValueChanged<String>? onToggleLimitation,
    Brightness brightness = Brightness.dark,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: StepLimitations(
            selectedLimitations: selectedLimitations,
            onToggleLimitation: onToggleLimitation ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders limitation cards with anatomy assets and handles tap', (
    tester,
  ) async {
    String? toggled;

    await tester.pumpWidget(
      buildSubject(onToggleLimitation: (id) => toggled = id),
    );

    final t = Translations.of(tester.element(find.byType(StepLimitations)));
    expect(find.text(t.onboarding.limitations.title), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(6));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    final kneeFinder = find.text(t.onboarding.limitations.options[1].label);
    await tester.ensureVisible(kneeFinder);
    await tester.tap(kneeFinder);
    await tester.pump();
    expect(toggled, 'knee');
  });

  testWidgets('renders cleanly in light mode', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        selectedLimitations: const ['knee', 'back'],
        brightness: Brightness.light,
      ),
    );

    expect(find.byType(StepLimitations), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
  });
}
