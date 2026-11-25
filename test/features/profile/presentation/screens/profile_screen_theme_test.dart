import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_state.dart';
import 'package:workout_app/features/profile/presentation/screens/app_settings_screen.dart';
import 'package:workout_app/features/profile/presentation/screens/body_information_screen.dart';
import 'package:workout_app/features/profile/presentation/screens/fitness_goals_screen.dart';
import 'package:workout_app/features/profile/presentation/screens/help_about_screen.dart';
import 'package:workout_app/features/profile/presentation/screens/personal_information_screen.dart';
import 'package:workout_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:workout_app/features/profile/presentation/screens/reminders_screen.dart';
import 'package:workout_app/features/profile/presentation/screens/workout_preferences_screen.dart';

class _FakeProfileController extends StateNotifier<ProfileState>
    implements ProfileController {
  _FakeProfileController() : super(const ProfileState(isLoading: false));

  @override
  Future<void> loadProfile() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget wrapWithApp(Widget screen, ThemeMode themeMode) {
    return ProviderScope(
      overrides: [
        profileControllerProvider.overrideWith(
          (ref) => _FakeProfileController(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: screen,
      ),
    );
  }

  group('ProfileScreen Theme Fidelity', () {
    testWidgets('renders AppBar and all cards in Light Mode and Dark Mode', (
      tester,
    ) async {
      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(wrapWithApp(const ProfileScreen(), themeMode));
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
        expect(find.text('Body Information'), findsOneWidget);
        expect(find.text('App Settings'), findsOneWidget);
      }
    });
  });

  group('Profile Sub-screens Theme Fidelity', () {
    final screens = <String, Widget>{
      'Personal Information': const PersonalInformationScreen(),
      'Body Information': const BodyInformationScreen(),
      'Fitness Goals': const FitnessGoalsScreen(),
      'Workout Preferences': const WorkoutPreferencesScreen(),
      'Reminders': const RemindersScreen(),
      'App Settings': const AppSettingsScreen(),
      'Help & About': const HelpAboutScreen(),
    };

    for (final entry in screens.entries) {
      testWidgets('${entry.key} renders in Light Mode and Dark Mode', (
        tester,
      ) async {
        for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
          await tester.pumpWidget(wrapWithApp(entry.value, themeMode));
          await tester.pumpAndSettle();

          expect(find.byType(AppBar), findsOneWidget);
          expect(find.text(entry.key), findsOneWidget);
        }
      });
    }
  });
}
