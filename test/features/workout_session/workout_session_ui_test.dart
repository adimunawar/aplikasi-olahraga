import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/workout_session/presentation/screens/rest_timer_screen.dart';
import 'package:workout_app/features/workout_session/presentation/widgets/active_workout_rep_counter.dart';
import 'package:workout_app/i18n/strings.g.dart';

Widget _localizedApp(Widget child) {
  return TranslationProvider(
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  group('ActiveWorkoutRepCounter', () {
    testWidgets('increments and decrements the entered rep value', (
      tester,
    ) async {
      var changedValue = 0;

      await tester.pumpWidget(
        _localizedApp(
          Scaffold(
            body: Center(
              child: ActiveWorkoutRepCounter(
                initialValue: 12,
                isDuration: false,
                onChanged: (value) => changedValue = value,
              ),
            ),
          ),
        ),
      );

      expect(find.text('12'), findsOneWidget);
      expect(find.text('reps'), findsOneWidget);
      expect(changedValue, 12);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(find.text('13'), findsOneWidget);
      expect(changedValue, 13);

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(find.text('12'), findsOneWidget);
      expect(changedValue, 12);
    });

    testWidgets('uses five-second steps and English unit for duration', (
      tester,
    ) async {
      var changedValue = 0;

      await tester.pumpWidget(
        _localizedApp(
          Scaffold(
            body: Center(
              child: ActiveWorkoutRepCounter(
                initialValue: 30,
                isDuration: true,
                onChanged: (value) => changedValue = value,
              ),
            ),
          ),
        ),
      );

      expect(find.text('30'), findsOneWidget);
      expect(find.text('sec'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();

      expect(find.text('35'), findsOneWidget);
      expect(changedValue, 35);
    });

    testWidgets('uses Indonesian unit when Indonesian locale is selected', (
      tester,
    ) async {
      LocaleSettings.setLocaleSync(AppLocale.id);

      await tester.pumpWidget(
        _localizedApp(
          Scaffold(
            body: Center(
              child: ActiveWorkoutRepCounter(
                initialValue: 30,
                isDuration: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('detik'), findsOneWidget);
    });
  });

  group('RestTimerScreen', () {
    testWidgets('renders English labels and wires all rest controls', (
      tester,
    ) async {
      var adjustedSeconds = 0;
      var pauseToggled = false;
      var skipped = false;

      await tester.pumpWidget(
        _localizedApp(
          SizedBox(
            width: 430,
            height: 800,
            child: RestTimerScreen(
              nextExerciseName: 'Push Up',
              nextSet: 2,
              totalSets: 3,
              remainingSeconds: 30,
              totalSeconds: 30,
              isPaused: false,
              onBack: () {},
              onAdjustTime: (delta) => adjustedSeconds += delta,
              onPauseToggle: () => pauseToggled = true,
              onSkipRest: () => skipped = true,
            ),
          ),
        ),
      );

      expect(find.text('Rest'), findsNWidgets(2));
      expect(find.text('Next: Push Up'), findsOneWidget);
      expect(find.text('Set 2 of 3'), findsOneWidget);
      expect(find.text('00:30'), findsOneWidget);
      expect(find.text('Keep breathing and stay hydrated.'), findsOneWidget);
      expect(find.text('-10s'), findsOneWidget);
      expect(find.text('+10s'), findsOneWidget);

      await tester.tap(find.text('-10s'));
      await tester.pump();
      expect(adjustedSeconds, -10);

      await tester.tap(find.text('+10s'));
      await tester.pump();
      expect(adjustedSeconds, 0);

      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();
      expect(pauseToggled, isTrue);

      await tester.tap(find.text('Skip Rest'));
      await tester.pump();
      expect(skipped, isTrue);
    });

    testWidgets('renders Indonesian strings when Indonesian locale is selected', (
      tester,
    ) async {
      LocaleSettings.setLocaleSync(AppLocale.id);

      await tester.pumpWidget(
        _localizedApp(
          SizedBox(
            width: 430,
            height: 800,
            child: RestTimerScreen(
              nextExerciseName: 'Push Up',
              nextSet: 2,
              totalSets: 3,
              remainingSeconds: 30,
              totalSeconds: 30,
              isPaused: true,
              onBack: () {},
              onAdjustTime: (_) {},
              onPauseToggle: () {},
              onSkipRest: () {},
            ),
          ),
        ),
      );

      expect(find.text('Istirahat'), findsNWidgets(2));
      expect(find.text('Berikutnya: Push Up'), findsOneWidget);
      expect(find.text('Set 2 dari 3'), findsOneWidget);
      expect(find.text('DIJEDA'), findsOneWidget);
      expect(find.text('-10 dtk'), findsOneWidget);
      expect(find.text('+10 dtk'), findsOneWidget);
      expect(find.text('Lewati Istirahat'), findsOneWidget);
    });
  });
}
