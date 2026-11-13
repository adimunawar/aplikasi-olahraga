import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/features/onboarding/presentation/screens/plan_preview_screen.dart';
import 'package:workout_app/features/onboarding/presentation/screens/plan_ready_screen.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_goal.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_schedule.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_welcome.dart';
import 'package:workout_app/features/program/domain/services/dynamic_program_generator.dart';
import 'package:workout_app/features/program/presentation/controllers/draft_program_provider.dart';
import 'mock_exercise_factory.dart';

void main() {
  Widget createTestWidget(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('Onboarding Widgets - Step Verification', () {
    testWidgets('StepWelcome renders hero text and coach subtitle', (tester) async {
      await tester.pumpWidget(createTestWidget(const StepWelcome()));
      await tester.pumpAndSettle();

      expect(find.text('Your Personal\nWorkout Coach'), findsOneWidget);
      expect(
        find.textContaining('Get a workout program based'),
        findsOneWidget,
      );
    });

    testWidgets('StepGoal renders all 3 core fitness goals', (tester) async {
      String selected = 'muscle_gain';

      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return StepGoal(
                selectedGoal: selected,
                onGoalSelected: (val) => setState(() => selected = val),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gain Weight & Build Muscle'), findsOneWidget);
      expect(find.text('Lose Weight & Reduce Fat'), findsOneWidget);
      expect(find.text('Maintain & Stay Fit'), findsOneWidget);

      // Tap second goal
      await tester.tap(find.text('Lose Weight & Reduce Fat'));
      await tester.pumpAndSettle();

      expect(selected, equals('fat_loss'));
    });

    testWidgets('StepSchedule renders days options and session durations', (tester) async {
      int days = 4;
      int duration = 45;

      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return StepSchedule(
                daysPerWeek: days,
                durationMin: duration,
                onDaysPerWeekChanged: (d) => setState(() => days = d),
                onDurationMinChanged: (dur) => setState(() => duration = dur),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 days / week'), findsOneWidget);
      expect(find.text('3 days / week'), findsOneWidget);
      expect(find.text('4 days / week'), findsOneWidget);
      expect(find.text('5 days / week'), findsOneWidget);
      expect(find.text('6 days / week'), findsOneWidget);

      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('45 min'), findsOneWidget);
      expect(find.text('60 min'), findsOneWidget);

      // Select 5 days / week
      await tester.tap(find.text('5 days / week'));
      await tester.pumpAndSettle();
      expect(days, equals(5));

      // Select 60 min
      await tester.tap(find.text('60 min'));
      await tester.pumpAndSettle();
      expect(duration, equals(60));
    });
  });

  group('Onboarding Screens - PlanReadyScreen & PlanPreviewScreen (P0 & P1)', () {
    testWidgets('PlanReadyScreen displays celebration and View My Plan button', (tester) async {
      final mockProfile = UserProfileEntity(
        id: 'test_user',
        displayName: 'Adi',
        age: 28,
        heightCm: 170,
        currentWeightKg: 75,
        targetWeightKg: 82,
        targetTimeframeWeeks: 12,
        goal: 'muscle_gain',
        experienceLevel: 'beginner',
        preferredDaysPerWeek: 4,
        weeklyFrequency: 4,
        preferredDurationMin: 45,
        availableDays: const ['monday', 'tuesday', 'thursday', 'friday'],
        equipments: const ['bodyweight'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          const PlanReadyScreen(),
          overrides: [
            onboardingProfileProvider.overrideWith((ref) => mockProfile),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your plan is ready! 🎉'), findsOneWidget);
      expect(find.text('View My Plan'), findsOneWidget);
      expect(find.text('Bulking Program'), findsOneWidget);
      expect(find.textContaining('Days / Week'), findsOneWidget);
      expect(find.textContaining('Minutes / Session'), findsOneWidget);
      expect(find.textContaining('12 Weeks'), findsOneWidget);
    });

    testWidgets('PlanPreviewScreen has strictly 2 tabs (Overview & Workout Split, NO Progress tab)', (tester) async {
      final now = DateTime.now();
      final mockProgram = TrainingProgramEntity(
        id: 'test_prog',
        userId: 'test_user',
        name: 'Bulking Program',
        status: 'active',
        startDate: now,
        weeklyFrequency: 4,
        targetDurationMinutes: 45,
        createdAt: now,
        updatedAt: now,
      );

      final catalog = getStandardMockCatalog();
      final mockProfile = UserProfileEntity(
        id: 'test_user',
        displayName: 'Adi',
        age: 28,
        heightCm: 170,
        currentWeightKg: 75,
        targetWeightKg: 82,
        targetTimeframeWeeks: 12,
        goal: 'muscle_gain',
        experienceLevel: 'beginner',
        preferredDaysPerWeek: 4,
        weeklyFrequency: 4,
        preferredDurationMin: 45,
        availableDays: const ['monday', 'tuesday', 'thursday', 'friday'],
        equipments: const ['bodyweight'],
        createdAt: now,
        updatedAt: now,
      );

      final generatedResult = const DynamicProgramGenerator().generate(
        userProfile: mockProfile,
        catalogExercises: catalog,
      );

      await tester.pumpWidget(
        createTestWidget(
          const PlanPreviewScreen(),
          overrides: [
            draftProgramProvider.overrideWith((ref) => generatedResult),
            onboardingProfileProvider.overrideWith((ref) => mockProfile),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Prioritas P1: Harus ada Tab Overview & Workout Split
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Workout Split'), findsOneWidget);

      // Prioritas P1: Tab 'Progress' TIDAK BOLEH ADA di Plan Preview!
      expect(find.text('Progress'), findsNothing);

      // Prioritas P0: Ada tombol aktivasi
      expect(find.text('Activate & Start Workout ➔'), findsOneWidget);
      expect(find.text('Activate & Go to Dashboard'), findsOneWidget);

      // Verifikasi Program Overview data
      expect(find.text('Program Overview'), findsOneWidget);
      expect(find.text('Expected Progress'), findsOneWidget);
    });
  });
}

