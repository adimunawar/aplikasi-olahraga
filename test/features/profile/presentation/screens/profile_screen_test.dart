import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_state.dart';
import 'package:workout_app/features/profile/presentation/screens/profile_screen.dart';

class _FakeProfileController extends StateNotifier<ProfileState>
    implements ProfileController {
  _FakeProfileController() : super(const ProfileState(isLoading: false));

  @override
  Future<void> loadProfile() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('ProfileScreen navigates to all sub-routes via GoRouter', (
    tester,
  ) async {
    String? pushedRoute;
    final router = GoRouter(
      initialLocation: AppRoutes.profile,
      routes: [
        GoRoute(
          path: AppRoutes.profile,
          builder: (_, _) => const ProfileScreen(),
        ),
        for (final path in [
          AppRoutes.personalInfo,
          AppRoutes.bodyInfo,
          AppRoutes.fitnessGoals,
          AppRoutes.workoutPreferences,
          AppRoutes.reminders,
          AppRoutes.appSettings,
          AppRoutes.helpAbout,
        ])
          GoRoute(
            path: path,
            builder: (_, _) {
              pushedRoute = path;
              return Scaffold(body: Text('Route: $path'));
            },
          ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileControllerProvider.overrideWith(
            (ref) => _FakeProfileController(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('App Settings'));
    await tester.tap(find.text('App Settings'));
    await tester.pumpAndSettle();
    expect(pushedRoute, AppRoutes.appSettings);
  });
}
