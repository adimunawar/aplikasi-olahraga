import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/onboarding/presentation/screens/onboarding_screen.dart';
// import 'package:workout_app/features/onboarding/presentation/screens/plan_preview_screen.dart';
import 'package:workout_app/features/onboarding/presentation/screens/plan_ready_screen.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.id);
  });

  group('Onboarding Theme Fidelity', () {
    testWidgets('OnboardingScreen renders in Light Mode and Dark Mode', (
      tester,
    ) async {
      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          ProviderScope(
            child: TranslationProvider(
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                home: const OnboardingScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Coach'), findsOneWidget);
        expect(find.text(t.onboarding.nav.getStarted), findsOneWidget);
      }
    });

    testWidgets('PlanReadyScreen renders in Light Mode and Dark Mode', (
      tester,
    ) async {
      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          ProviderScope(
            child: TranslationProvider(
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                home: const PlanReadyScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(t.onboarding.ready.viewMyPlan), findsOneWidget);
      }
    });
  });
}
