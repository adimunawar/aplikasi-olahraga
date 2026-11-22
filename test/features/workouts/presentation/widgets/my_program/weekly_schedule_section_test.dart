import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_theme.dart';
import 'package:workout_app/features/program/domain/models/program_lifecycle.dart';
import 'package:workout_app/features/program/domain/services/program_week_schedule.dart';
import 'package:workout_app/features/workouts/presentation/widgets/my_program/weekly_schedule_section.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocale(AppLocale.id);
  });

  final now = DateTime.now();

  final sampleProgram = TrainingProgramEntity(
    id: 'prog-1',
    userId: 'user-1',
    name: 'Test Program',
    status: 'active',
    startDate: now,
    endDate: now.add(const Duration(days: 28)),
    weeklyFrequency: 3,
    targetDurationMinutes: 30,
    createdAt: now,
    updatedAt: now,
  );

  final sampleProfile = UserProfileEntity(
    id: 'prof-1',
    displayName: 'Test User',
    age: 25,
    heightCm: 175.0,
    currentWeightKg: 70.0,
    experienceLevel: 'beginner',
    equipments: const [],
    createdAt: now,
    updatedAt: now,
  );

  final sampleSession = ProgramWeekSession(
    scheduledDate: DateTime.now(),
    session: ProgramSessionEntity(
      id: 'session-1',
      programId: 'prog-1',
      dayNumber: 1,
      name: 'Full Body Push',
      focusLabel: 'Chest & Shoulders',
      targetDurationMinutes: 45,
      createdAt: now,
    ),
  );

  final sampleLifecycle = ProgramLifecycleInfo(
    state: ProgramLifecycle.active,
    startDate: now,
    endDate: now.add(const Duration(days: 28)),
    totalWeeks: 4,
    currentWeek: 1,
    completedSessions: 0,
    totalSessions: 12,
    daysRemaining: 28,
  );

  Widget createTestWidget({
    required AppLocale locale,
    required void Function(WorkoutDetailArgs args) onDetailNavigated,
  }) {
    LocaleSettings.setLocale(locale);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              child: WeeklyScheduleSection(
                weeklySessions: [sampleSession],
                selectedWeek: 1,
                currentWeek: 1,
                totalWeeks: 4,
                progressByWeek: const {},
                completedThisWeek: 0,
                lifecycle: sampleLifecycle,
                activeSession: null,
                program: sampleProgram,
                profile: sampleProfile,
                programWorkoutHistory: const [],
                onWeekSelected: (_) {},
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.workoutDetail,
          builder: (context, state) {
            final args = state.extra as WorkoutDetailArgs;
            onDetailNavigated(args);
            return const Scaffold(body: Text('Detail Screen'));
          },
        ),
      ],
    );

    return TranslationProvider(
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }

  testWidgets(
    'passes localized Indonesian strings to WorkoutDetailArgs when locale is ID',
    (tester) async {
      WorkoutDetailArgs? capturedArgs;

      await tester.pumpWidget(
        createTestWidget(
          locale: AppLocale.id,
          onDetailNavigated: (args) => capturedArgs = args,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Full Body Push'));
      await tester.pumpAndSettle();

      expect(capturedArgs, isNotNull);
      expect(capturedArgs!.weekDayText, equals('Minggu 1 • Hari 1'));
      expect(capturedArgs!.durationText, equals('45 mnt'));
      expect(capturedArgs!.levelText, equals('Pemula'));
    },
  );

  testWidgets(
    'passes localized English strings to WorkoutDetailArgs when locale is EN',
    (tester) async {
      WorkoutDetailArgs? capturedArgs;

      await tester.pumpWidget(
        createTestWidget(
          locale: AppLocale.en,
          onDetailNavigated: (args) => capturedArgs = args,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Full Body Push'));
      await tester.pumpAndSettle();

      expect(capturedArgs, isNotNull);
      expect(capturedArgs!.weekDayText, equals('Week 1 • Day 1'));
      expect(capturedArgs!.durationText, equals('45 min'));
      expect(capturedArgs!.levelText, equals('Beginner'));
    },
  );
}
