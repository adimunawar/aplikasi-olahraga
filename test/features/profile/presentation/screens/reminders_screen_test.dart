import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_state.dart';
import 'package:workout_app/features/profile/presentation/screens/reminders_screen.dart';

class _RecordingController extends StateNotifier<ProfileState>
    implements ProfileController {
  _RecordingController() : super(const ProfileState(isLoading: false));

  bool? savedRestDayReminder;

  @override
  Future<void> updateReminders({
    required bool workoutReminder,
    required String reminderTime,
    required bool restDayReminder,
    required bool progressCheckin,
    required bool streakReminder,
  }) async {
    savedRestDayReminder = restDayReminder;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('RemindersScreen toggles reminder switch and saves', (
    tester,
  ) async {
    final controller = _RecordingController();
    final router = GoRouter(
      initialLocation: AppRoutes.reminders,
      routes: [
        GoRoute(
          path: AppRoutes.reminders,
          builder: (_, _) => const RemindersScreen(),
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
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();

    expect(controller.savedRestDayReminder, isNotNull);
  });
}
