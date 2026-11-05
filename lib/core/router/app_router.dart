import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/exercise_detail/presentation/screens/exercise_detail_screen.dart';
import '../../features/exercises/domain/models/exercise.dart';
import '../../features/exercises/presentation/screens/exercise_list_screen.dart';
import '../../features/home/presentation/screens/home_scaffold.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/nutrition/presentation/screens/nutrition_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/plans/presentation/screens/plans_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/personal_information_screen.dart';
import '../../features/profile/presentation/screens/body_information_screen.dart';
import '../../features/profile/presentation/screens/fitness_goals_screen.dart';
import '../../features/profile/presentation/screens/workout_preferences_screen.dart';
import '../../features/profile/presentation/screens/reminders_screen.dart';
import '../../features/profile/presentation/screens/app_settings_screen.dart';
import '../../features/profile/presentation/screens/help_about_screen.dart';
import '../../features/program/domain/models/program_day.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/workout_detail/presentation/screens/workout_detail_screen.dart';
import '../../features/workout_session/presentation/screens/workout_session_screen.dart';
import '../../features/workout_summary/presentation/screens/workout_summary_screen.dart';

/// Definisi nama dan path route seluruh aplikasi
class AppRoutes {
  static const String home = '/';
  static const String plans = '/plans';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';
  static const String workoutDetail = '/workout-detail';
  static const String workoutSession = '/workout-session';
  static const String workoutSummary = '/workout-summary';
  static const String exerciseDetail = '/exercise-detail';
  static const String calendar = '/calendar';
  static const String exercises = '/exercises';
  static const String nutrition = '/nutrition';

  // Sub-halaman Edit Profile (Mockup Resolusi Tinggi)
  static const String personalInfo = '/profile/personal-info';
  static const String bodyInfo = '/profile/body-info';
  static const String fitnessGoals = '/profile/fitness-goals';
  static const String workoutPreferences = '/profile/workout-preferences';
  static const String reminders = '/profile/reminders';
  static const String appSettings = '/profile/app-settings';
  static const String helpAbout = '/profile/help-about';
}

/// DTO Arguments untuk WorkoutDetailScreen
class WorkoutDetailArgs {
  final int dayNumber;
  final String weekDayText;
  final String workoutTitle;
  final String targetMusclesText;
  final String durationText;
  final String levelText;
  final String description;

  const WorkoutDetailArgs({
    this.dayNumber = 1,
    this.weekDayText = 'Week 1 • Day 1',
    this.workoutTitle = 'Upper Body',
    this.targetMusclesText = 'Chest',
    this.durationText = '45 min',
    this.levelText = 'Intermediate',
    this.description = '',
  });
}

/// DTO Arguments untuk WorkoutSessionScreen
class WorkoutSessionArgs {
  final ProgramDay day;
  final List<Exercise> exercises;

  const WorkoutSessionArgs({
    required this.day,
    required this.exercises,
  });
}

/// DTO Arguments untuk WorkoutSummaryScreen
class WorkoutSummaryArgs {
  final String userName;
  final String workoutTitle;
  final String weekDayText;
  final String durationText;
  final String exercisesCountText;
  final String setsCountText;
  final String caloriesText;
  final String? quoteText;

  const WorkoutSummaryArgs({
    this.userName = 'Adi',
    this.workoutTitle = 'Upper Body Strength',
    this.weekDayText = 'Week 3 • Day 1',
    this.durationText = '25 min',
    this.exercisesCountText = '5 / 5',
    this.setsCountText = '15',
    this.caloriesText = '≈ 185 kcal',
    this.quoteText,
  });
}

/// Global Navigation Key untuk akses context tanpa widget tree jika dibutuhkan
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Provider status onboarding pengguna
final hasCompletedOnboardingProvider = StateProvider<bool>((ref) => false);

/// Provider GoRouter yang terhubung dengan Riverpod
final appRouterProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: hasCompletedOnboarding ? AppRoutes.home : AppRoutes.onboarding,
    routes: [
      // 1. Stateful Shell Route untuk Bottom Navigation (Home, Plans, Progress, Profile)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => HomeScreen(
                  onNavigateToCalendar: () => context.push(AppRoutes.calendar),
                  onNavigateToExercises: () => context.push(AppRoutes.exercises),
                  onNavigateToNutrition: () => context.push(AppRoutes.nutrition),
                  onNavigateToProgress: () => context.go(AppRoutes.progress),
                ),
              ),
            ],
          ),
          // Branch 1: Plans
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.plans,
                builder: (context, state) => const PlansScreen(),
              ),
            ],
          ),
          // Branch 2: Progress
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // 2. Fullscreen Routes (tanpa Bottom Bar)
      GoRoute(
        path: AppRoutes.onboarding,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra as WorkoutDetailArgs? ?? const WorkoutDetailArgs();
          return WorkoutDetailScreen(
            dayNumber: args.dayNumber,
            weekDayText: args.weekDayText,
            workoutTitle: args.workoutTitle,
            targetMusclesText: args.targetMusclesText,
            durationText: args.durationText,
            levelText: args.levelText,
            description: args.description,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.workoutSession,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra as WorkoutSessionArgs;
          return WorkoutSessionScreen(
            day: args.day,
            exercises: args.exercises,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.workoutSummary,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra as WorkoutSummaryArgs? ?? const WorkoutSummaryArgs();
          return WorkoutSummaryScreen(
            userName: args.userName,
            workoutTitle: args.workoutTitle,
            weekDayText: args.weekDayText,
            durationText: args.durationText,
            exercisesCountText: args.exercisesCountText,
            setsCountText: args.setsCountText,
            caloriesText: args.caloriesText,
            quoteText: args.quoteText ??
                'Latihan yang konsisten seperti ini akan membantu kamu membangun massa otot dan tubuh yang lebih kuat. Pertahankan!',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.exerciseDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final exercise = state.extra as Exercise;
          return ExerciseDetailScreen(exercise: exercise);
        },
      ),
      GoRoute(
        path: AppRoutes.calendar,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.exercises,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ExerciseListScreen(),
      ),
      GoRoute(
        path: AppRoutes.nutrition,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NutritionScreen(),
      ),

      // Sub-halaman Edit Profile
      GoRoute(
        path: AppRoutes.personalInfo,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PersonalInformationScreen(),
      ),
      GoRoute(
        path: AppRoutes.bodyInfo,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BodyInformationScreen(),
      ),
      GoRoute(
        path: AppRoutes.fitnessGoals,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FitnessGoalsScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutPreferences,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WorkoutPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.reminders,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: AppRoutes.appSettings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpAbout,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HelpAboutScreen(),
      ),
    ],
  );
});
