import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_schedule.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget buildSubject({
    int daysPerWeek = 4,
    int durationMin = 45,
    ValueChanged<int>? onDaysPerWeekChanged,
    ValueChanged<int>? onDurationMinChanged,
    Brightness brightness = Brightness.dark,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: StepSchedule(
            daysPerWeek: daysPerWeek,
            durationMin: durationMin,
            onDaysPerWeekChanged: onDaysPerWeekChanged ?? (_) {},
            onDurationMinChanged: onDurationMinChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders frequency options, durations, and handles selection', (
    tester,
  ) async {
    int? selectedDays;
    int? selectedDuration;

    await tester.pumpWidget(
      buildSubject(
        onDaysPerWeekChanged: (val) => selectedDays = val,
        onDurationMinChanged: (val) => selectedDuration = val,
      ),
    );

    final t = Translations.of(tester.element(find.byType(StepSchedule)));
    expect(find.text(t.onboarding.schedule.title), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    final fiveDaysFinder = find.text(t.onboarding.schedule.daysPerWeek(n: 5));
    await tester.ensureVisible(fiveDaysFinder);
    await tester.tap(fiveDaysFinder);
    await tester.pump();
    expect(selectedDays, 5);

    final sixtyMinFinder = find.text(t.onboarding.schedule.minutes(n: 60));
    await tester.ensureVisible(sixtyMinFinder);
    await tester.tap(sixtyMinFinder);
    await tester.pump();
    expect(selectedDuration, 60);
  });

  testWidgets('renders cleanly in light mode', (tester) async {
    await tester.pumpWidget(buildSubject(brightness: Brightness.light));

    expect(find.byType(StepSchedule), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
