import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/features/home/presentation/widgets/goal_progress_card.dart';
import 'package:workout_app/features/home/presentation/widgets/home_error_banner.dart';
import 'package:workout_app/features/home/presentation/widgets/home_greeting_header.dart';
import 'package:workout_app/features/home/presentation/widgets/support_goal_nutrition_card.dart';
import 'package:workout_app/features/home/presentation/widgets/today_workout/today_workout_section.dart';
import 'package:workout_app/features/home/presentation/widgets/weekly_progress_calendar_card.dart';
import 'package:workout_app/i18n/strings.g.dart';

Widget createLocalizedTestWidget(Widget child, [AppLocale locale = AppLocale.id]) {
  LocaleSettings.setLocale(locale);
  return TranslationProvider(
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUp(() {
    LocaleSettings.setLocale(AppLocale.id);
  });

  group('Home Redesign Components - Unit & Widget Tests', () {
    testWidgets('HomeGreetingHeader renders personalized greeting and avatar', (tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          HomeGreetingHeader(
            userName: 'Adi',
            hasUnreadNotification: true,
          ),
        ),
      );

      // Verify user name and subtitle
      expect(find.textContaining('Adi'), findsOneWidget);
      expect(find.text('Tetap konsisten dan capai targetmu!'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('GoalProgressCard renders target, current weight, and timeline', (tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          GoalProgressCard(
            goalTitle: 'Goal: Naikkan Berat Badan',
            targetWeightKg: 82.0,
            currentWeightKg: 75.8,
            weightDeltaKg: 0.8,
            totalWeeks: 12,
            currentWeek: 3,
          ),
        ),
      );

      expect(find.text('Goal: Naikkan Berat Badan'), findsOneWidget);
      expect(find.text('82.0 kg'), findsOneWidget);
      expect(find.text('75.8 kg'), findsOneWidget);
      expect(find.text('+0.8 kg'), findsOneWidget);
      expect(find.text('12 Minggu Program'), findsOneWidget);
      expect(find.text('Minggu 3 dari 12'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('TodayWorkoutSection renders active workout state with Start Workout button', (tester) async {
      bool started = false;
      bool planViewed = false;

      await tester.pumpWidget(
        createLocalizedTestWidget(
          TodayWorkoutSection(
            state: WorkoutCardState.active,
            sessionTitle: 'Upper Body (Push)',
            targetMuscles: 'Chest, Shoulders, Triceps',
            durationMinutes: 45,
            estimatedCalories: 280,
            onStartWorkout: () => started = true,
            onViewPlan: () => planViewed = true,
          ),
        ),
      );

      expect(find.text('Latihan Hari Ini'), findsOneWidget);
      expect(find.text('Lihat Jadwal →'), findsOneWidget);
      expect(find.text('Upper Body (Push)'), findsOneWidget);
      expect(find.text('Chest, Shoulders, Triceps'), findsOneWidget);
      expect(find.text('Mulai Latihan'), findsOneWidget);

      await tester.tap(find.text('Mulai Latihan'));
      await tester.pump();
      expect(started, isTrue);

      await tester.tap(find.text('Lihat Jadwal →'));
      await tester.pump();
      expect(planViewed, isTrue);
    });

    testWidgets('TodayWorkoutSection renders rest day state with recovery tips', (tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          TodayWorkoutSection(
            state: WorkoutCardState.restDay,
            sessionTitle: '',
            targetMuscles: '',
            durationMinutes: 0,
            onStartWorkout: () {},
            onViewPlan: () {},
          ),
        ),
      );

      expect(find.text('Hari Ini Istirahat'), findsOneWidget);
      expect(find.text('Tips Pemulihan'), findsOneWidget);
      expect(find.text('Cukupi kebutuhan cairan tubuh'), findsOneWidget);
      expect(find.text('Tidur cukup 7–9 jam'), findsOneWidget);
      expect(find.text('Lakukan peregangan ringan atau mobilitas'), findsOneWidget);
    });

    testWidgets('TodayWorkoutSection renders no program state with create button', (tester) async {
      bool created = false;

      await tester.pumpWidget(
        createLocalizedTestWidget(
          TodayWorkoutSection(
            state: WorkoutCardState.noProgram,
            sessionTitle: '',
            targetMuscles: '',
            durationMinutes: 0,
            onStartWorkout: () {},
            onViewPlan: () {},
            onCreateProgram: () => created = true,
          ),
        ),
      );

      expect(find.text('Kamu belum memiliki program latihan'), findsOneWidget);
      expect(find.text('Buat Program Saya'), findsOneWidget);

      await tester.tap(find.text('Buat Program Saya'));
      await tester.pump();
      expect(created, isTrue);
    });

    testWidgets('WeeklyProgressCalendarCard renders 7 days with correct labels', (tester) async {
      final now = DateTime.now();
      final days = [
        DayProgressData(dayName: 'Mon', state: DayActivityState.completed, date: now),
        DayProgressData(dayName: 'Tue', state: DayActivityState.completed, date: now),
        DayProgressData(dayName: 'Wed', state: DayActivityState.today, date: now),
        DayProgressData(dayName: 'Thu', state: DayActivityState.upcoming, date: now),
        DayProgressData(dayName: 'Fri', state: DayActivityState.upcoming, date: now),
        DayProgressData(dayName: 'Sat', state: DayActivityState.rest, date: now),
        DayProgressData(dayName: 'Sun', state: DayActivityState.rest, date: now),
      ];

      await tester.pumpWidget(
        createLocalizedTestWidget(
          WeeklyProgressCalendarCard(
            days: days,
            onSeeDetails: () {},
          ),
        ),
      );

      expect(find.text('Kemajuan Minggu Ini'), findsOneWidget);
      expect(find.text('Lihat Detail →'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
    });

    testWidgets('SupportGoalNutritionCard renders nutrition goal support', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createLocalizedTestWidget(
          SupportGoalNutritionCard(
            userGoal: 'muscle_gain',
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Dukung Targetmu'), findsOneWidget);
      expect(find.text('Dapatkan tips nutrisi sederhana untuk pembentukan otot.'), findsOneWidget);

      await tester.tap(find.text('Dukung Targetmu'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('HomeErrorBanner renders offline connection warning and retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        createLocalizedTestWidget(
          HomeErrorBanner(
            lastSyncedTime: 'Today, 10:30 AM',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Masalah koneksi'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.text('Sinkronisasi terakhir: Today, 10:30 AM'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();
      expect(retried, isTrue);
    });
  });
}
