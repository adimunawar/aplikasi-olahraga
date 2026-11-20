import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/features/workout_session/presentation/screens/workout_completed_screen.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  group('WorkoutCompletedScreen Widget Tests', () {
    late WorkoutCompletedArgs defaultArgs;

    setUp(() {
      LocaleSettings.setLocale(AppLocale.en);
      defaultArgs = const WorkoutCompletedArgs(
        userName: 'Adi',
        workoutTitle: 'Upper Body Blast',
        focusText: 'Chest, Quads & Core',
        durationMinutes: 30,
        exercisesCount: 4,
        caloriesBurned: 160,
        weekDayText: 'Week 2 • Day 3',
        setsCountText: '12',
      );
    });

    testWidgets('renders workout completed information correctly', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: WorkoutCompletedScreen(args: defaultArgs),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and subtitle
      expect(find.text('Workout Completed! 🎉'), findsOneWidget);
      expect(
        find.text("Great job! You've finished Chest, Quads & Core."),
        findsOneWidget,
      );

      // Check stats
      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('160'), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('Exercises'), findsOneWidget);
      expect(find.text('Est. Calories'), findsOneWidget);

      // Check rating section
      expect(find.text('How was the workout?'), findsOneWidget);
      expect(find.text('Too Easy'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Just Right'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Too Hard'), findsOneWidget);

      // Check action buttons
      expect(find.text('Save & Continue'), findsOneWidget);
      expect(find.text('View Workout Summary'), findsOneWidget);
    });

    testWidgets('allows selecting different workout rating emojis', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: WorkoutCompletedScreen(args: defaultArgs),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Too Easy"
      await tester.tap(find.text('Too Easy'));
      await tester.pumpAndSettle();

      // Tap "Hard"
      await tester.tap(find.text('Hard'));
      await tester.pumpAndSettle();

      // Screen stays responsive without errors
      expect(find.text('Hard'), findsOneWidget);
    });

    testWidgets('navigates to summary when View Workout Summary is tapped', (tester) async {
      WorkoutSummaryArgs? capturedArgs;

      final router = GoRouter(
        initialLocation: '/completed',
        routes: [
          GoRoute(
            path: '/completed',
            builder: (context, state) => WorkoutCompletedScreen(args: defaultArgs),
          ),
          GoRoute(
            path: AppRoutes.workoutSummary,
            builder: (context, state) {
              capturedArgs = state.extra as WorkoutSummaryArgs?;
              return const Scaffold(
                body: Center(child: Text('Workout Summary Screen')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('View Workout Summary'));
      await tester.pumpAndSettle();

      expect(find.text('Workout Summary Screen'), findsOneWidget);
      expect(capturedArgs, isNotNull);
      expect(capturedArgs!.workoutTitle, 'Upper Body Blast');
      expect(capturedArgs!.durationText, '30 min');
      expect(capturedArgs!.caloriesText, '≈ 160 kcal');
    });

    testWidgets('navigates to home when Save & Continue is tapped', (tester) async {
      final router = GoRouter(
        initialLocation: '/completed',
        routes: [
          GoRoute(
            path: '/completed',
            builder: (context, state) => WorkoutCompletedScreen(args: defaultArgs),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Screen')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save & Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('animates and disposes controllers cleanly without error', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: WorkoutCompletedScreen(args: defaultArgs),
          ),
        ),
      );

      // Advance frames partially during entrance animation
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Dispose widget cleanly
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  });
}
