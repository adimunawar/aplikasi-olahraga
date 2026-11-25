import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_state.dart';
import 'package:workout_app/features/profile/presentation/screens/workout_preferences_screen.dart';

class _RecordingController extends StateNotifier<ProfileState>
    implements ProfileController {
  _RecordingController()
    : super(
        const ProfileState(
          isLoading: false,
          preferredDaysPerWeek: 4,
          preferredDurationMin: 45,
          trainingIntensity: 'Moderate',
        ),
      );

  int? savedDays;
  int? savedDurationMin;
  String? savedIntensity;

  @override
  Future<void> updateWorkoutPreferences({
    required int trainingDaysPerWeek,
    required int workoutDurationMin,
    required String trainingIntensity,
  }) async {
    savedDays = trainingDaysPerWeek;
    savedDurationMin = workoutDurationMin;
    savedIntensity = trainingIntensity;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('WorkoutPreferencesScreen updates days, intensity and saves', (
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
          path: AppRoutes.workoutPreferences,
          builder: (_, _) => const WorkoutPreferencesScreen(),
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
    router.push(AppRoutes.workoutPreferences);
    await tester.pumpAndSettle();

    await tester.tap(find.text('5'));
    await tester.tap(find.text('High'));
    await tester.pump();
    expect(find.textContaining('Intense tempo'), findsOneWidget);

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(controller.savedDays, 5);
    expect(controller.savedDurationMin, 45);
    expect(controller.savedIntensity, 'High');
    expect(find.text('Root'), findsOneWidget);
  });
}
