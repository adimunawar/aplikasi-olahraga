import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_state.dart';
import 'package:workout_app/features/profile/presentation/screens/app_settings_screen.dart';
import 'package:workout_app/i18n/strings.g.dart';

class _RecordingController extends StateNotifier<ProfileState>
    implements ProfileController {
  _RecordingController() : super(const ProfileState(isLoading: false));

  String? savedTheme;

  @override
  Future<void> updateAppSettings({
    required String language,
    required String theme,
    required String units,
    required bool hapticFeedback,
    required bool soundEffects,
    required bool dataSync,
  }) async {
    savedTheme = theme;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('AppSettingsScreen picks theme via bottom sheet', (tester) async {
    LocaleSettings.setLocale(AppLocale.en);
    final controller = _RecordingController();
    final router = GoRouter(
      initialLocation: AppRoutes.appSettings,
      routes: [
        GoRoute(
          path: AppRoutes.appSettings,
          builder: (_, _) => const AppSettingsScreen(),
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

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(controller.savedTheme, 'Dark');
  });
}
