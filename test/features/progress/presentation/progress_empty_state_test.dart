import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/presentation/widgets/shared/highlights_card.dart';
import 'package:workout_app/features/progress/presentation/widgets/shared/progress_empty_state.dart';
import 'package:workout_app/i18n/strings.g.dart';

Widget _localizedApp(Widget child) {
  return TranslationProvider(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('ProgressEmptyState displays its icon, title, and guidance', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        const ProgressEmptyState(
          icon: Icons.fitness_center_rounded,
          title: 'No workout data yet',
          message:
              'Complete your first workout to see your training progress here.',
        ),
      ),
    );

    expect(find.text('No workout data yet'), findsOneWidget);
    expect(
      find.text(
        'Complete your first workout to see your training progress here.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
  });

  testWidgets(
    'HighlightsCard does not display invented values when there is no data',
    (tester) async {
      await tester.pumpWidget(
        _localizedApp(
          const HighlightsCard(
            completed: 0,
            target: 0,
            weightChange: 0,
            streak: 0,
          ),
        ),
      );

      expect(find.text('No highlights yet'), findsOneWidget);
      expect(find.textContaining('0.0 kg'), findsNothing);
      expect(find.textContaining('0 consecutive active days'), findsNothing);
    },
  );
}
