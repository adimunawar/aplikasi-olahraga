import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/home/presentation/widgets/goal_progress_card.dart';
import 'package:workout_app/features/home/presentation/widgets/home_error_banner.dart';
import 'package:workout_app/features/home/presentation/widgets/home_greeting_header.dart';
import 'package:workout_app/features/home/presentation/widgets/support_goal_nutrition_card.dart';
import 'package:workout_app/features/home/presentation/widgets/today_workout/today_workout_section.dart';
import 'package:workout_app/features/home/presentation/widgets/weekly_progress_calendar_card.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.id);
  });

  Widget buildHomeComponents(ThemeMode themeMode) {
    final today = DateTime(2026, 11, 24);
    final days = [
      DayProgressData(
        dayName: 'Sen',
        state: DayActivityState.completed,
        date: today,
      ),
      DayProgressData(
        dayName: 'Sel',
        state: DayActivityState.today,
        date: today.add(const Duration(days: 1)),
      ),
      DayProgressData(
        dayName: 'Rab',
        state: DayActivityState.upcoming,
        date: today.add(const Duration(days: 2)),
      ),
    ];

    return TranslationProvider(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const HomeGreetingHeader(userName: 'Adi'),
                const GoalProgressCard(
                  goalTitle: 'Goal: Naikkan Berat Badan',
                  targetWeightKg: 82,
                  currentWeightKg: 75.8,
                  totalWeeks: 12,
                  currentWeek: 3,
                ),
                const HomeErrorBanner(
                  lastSyncedTime: 'Hari ini, 10:30',
                  onRetry: _noop,
                ),
                WeeklyProgressCalendarCard(
                  days: days,
                  onSeeDetails: _noop,
                ),
                const SupportGoalNutritionCard(
                  userGoal: 'muscle_gain',
                  onTap: _noop,
                ),
                TodayWorkoutSection(
                  state: WorkoutCardState.active,
                  sessionTitle: 'Upper Body',
                  targetMuscles: 'Chest, Shoulders',
                  durationMinutes: 45,
                  estimatedCalories: 280,
                  onStartWorkout: _noop,
                  onViewPlan: _noop,
                  onHydrationTap: _noop,
                  onSleepTap: _noop,
                  onStretchingTap: _noop,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Home components follow the Light theme', (tester) async {
    await tester.pumpWidget(buildHomeComponents(ThemeMode.light));
    await tester.pumpAndSettle();

    expect(find.text('82.0 kg'), findsOneWidget);
    expect(find.text('Masalah koneksi'), findsOneWidget);
    expect(find.text('Mulai Latihan'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.lightTheme.scaffoldBackgroundColor);

    final weight = tester.widget<Text>(find.text('82.0 kg'));
    expect(weight.style?.color, AppTheme.lightTheme.colorScheme.onSurface);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home components follow the Dark theme', (tester) async {
    await tester.pumpWidget(buildHomeComponents(ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(find.text('82.0 kg'), findsOneWidget);
    expect(find.text('Masalah koneksi'), findsOneWidget);
    expect(find.text('Mulai Latihan'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.darkTheme.scaffoldBackgroundColor);

    final weight = tester.widget<Text>(find.text('82.0 kg'));
    expect(weight.style?.color, AppTheme.darkTheme.colorScheme.onSurface);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
