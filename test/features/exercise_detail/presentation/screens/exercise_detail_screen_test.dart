import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/exercise_detail/presentation/screens/exercise_detail_screen.dart';
import 'package:workout_app/features/exercise_detail/presentation/widgets/exercise_detail_widgets.dart';

import '../../../onboarding/mock_exercise_factory.dart';

void main() {
  final testExercise = createMockExercise(
    id: 'knee_push_up',
    name: 'Knee Push Up',
  );

  Widget createSubject({required ThemeMode themeMode}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: ExerciseDetailScreen(exercise: testExercise),
    );
  }

  group('ExerciseDetailScreen & ExerciseDetailHeader Tests', () {
    testWidgets('Renders all cards and header cleanly in Dark Mode without MaterialLocalizations error', (tester) async {
      await tester.pumpWidget(createSubject(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      // Verify no assertion error was thrown and header renders
      expect(find.byType(ExerciseDetailHeader), findsOneWidget);
      expect(find.text('Knee Push Up'), findsOneWidget);

      // Verify all 5 modular cards are present
      expect(find.byType(ExerciseDemoCard), findsOneWidget);
      expect(find.byType(ExerciseFocusAreaCard), findsOneWidget);
      expect(find.byType(ExerciseHowToPerformCard), findsOneWidget);
      expect(find.byType(ExerciseCommonMistakesCard), findsOneWidget);
      expect(find.byType(ExerciseTipsCard), findsOneWidget);
    });

    testWidgets('Renders cleanly in Light Mode', (tester) async {
      await tester.pumpWidget(createSubject(themeMode: ThemeMode.light));
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseDetailHeader), findsOneWidget);
      expect(find.text('Knee Push Up'), findsOneWidget);
      expect(find.byType(ExerciseDemoCard), findsOneWidget);
    });

    testWidgets('Bookmark icon toggles state on tap', (tester) async {
      await tester.pumpWidget(createSubject(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bookmark_outline_rounded), findsOneWidget);

      // Tap bookmark
      await tester.tap(find.byIcon(Icons.bookmark_outline_rounded));
      await tester.pumpAndSettle();

      // State is toggled to filled bookmark
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    });
  });
}
