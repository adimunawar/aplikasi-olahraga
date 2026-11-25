import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_state.dart';
import 'package:workout_app/features/profile/presentation/screens/fitness_goals_screen.dart';

class _RecordingController extends StateNotifier<ProfileState>
    implements ProfileController {
  _RecordingController()
    : super(
        const ProfileState(
          isLoading: false,
          goal: 'Build Muscle (Bulking)',
          targetWeight: 68.0,
          experienceLevel: 'Beginner',
        ),
      );

  String? savedGoal;
  double? savedTargetWeight;
  String? savedExperienceLevel;

  @override
  Future<void> updateFitnessGoals({
    required String goal,
    required double targetWeight,
    required String experienceLevel,
  }) async {
    savedGoal = goal;
    savedTargetWeight = targetWeight;
    savedExperienceLevel = experienceLevel;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('FitnessGoalsScreen selects experience level and saves', (
    tester,
  ) async {
    final controller = _RecordingController();
    final router = GoRouter(
      initialLocation: AppRoutes.profile,
      routes: [
        GoRoute(
          path: AppRoutes.profile,
          builder: (_, _) => const Scaffold(body: Text('Root')),
        ),
        GoRoute(
          path: AppRoutes.fitnessGoals,
          builder: (_, _) => const FitnessGoalsScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: router,
        ),
      ),
    );
    router.push(AppRoutes.fitnessGoals);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Intermediate'));
    await tester.pump();
    expect(
      find.textContaining('Trained consistently for 6+ months'),
      findsOneWidget,
    );

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(controller.savedGoal, 'Build Muscle (Bulking)');
    expect(controller.savedTargetWeight, 68.0);
    expect(controller.savedExperienceLevel, 'Intermediate');
    expect(find.text('Root'), findsOneWidget);
  });
}
