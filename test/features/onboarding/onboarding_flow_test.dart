import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/features/onboarding/presentation/screens/plan_ready_screen.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_goal.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_about.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_height.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_weight.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_experience.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_schedule.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_equipment.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_limitations.dart';
import 'package:workout_app/features/onboarding/presentation/widgets/step_welcome.dart';
import 'package:workout_app/features/program/presentation/controllers/draft_program_provider.dart';
import 'package:workout_app/i18n/strings.g.dart';

void main() {
  Widget createTestWidget(Widget child, {List<Override> overrides = const []}) {
    return TranslationProvider(
      child: ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
  }

  group('Onboarding Widgets - Step Verification', () {
    testWidgets('StepWelcome renders hero text and coach subtitle', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const StepWelcome()));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Coach Latihan', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Dapatkan program latihan sesuai',
          findRichText: true,
        ),
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

      expect(find.text('Naikkan Berat & Bangun Otot'), findsOneWidget);
      expect(find.text('Turunkan Berat & Kurangi Lemak'), findsOneWidget);
      expect(find.text('Jaga Berat & Tetap Bugar'), findsOneWidget);

      // Tap second goal
      await tester.tap(find.text('Turunkan Berat & Kurangi Lemak'));
      await tester.pumpAndSettle();

      expect(selected, equals('fat_loss'));
    });

    testWidgets('StepSchedule renders days options and session durations', (
      tester,
    ) async {
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

      expect(find.text('2 hari / minggu'), findsOneWidget);
      expect(find.text('3 hari / minggu'), findsOneWidget);
      expect(find.text('4 hari / minggu'), findsOneWidget);
      expect(find.text('5 hari / minggu'), findsOneWidget);
      expect(find.text('6 hari / minggu'), findsOneWidget);

      expect(find.text('30 menit'), findsOneWidget);
      expect(find.text('45 menit'), findsOneWidget);
      expect(find.text('60 menit'), findsOneWidget);

      // Select 5 days / week
      final fiveDays = find.text('5 hari / minggu');
      await tester.ensureVisible(fiveDays);
      await tester.tap(fiveDays);
      await tester.pumpAndSettle();
      expect(days, equals(5));

      // Select 60 min
      final sixtyMin = find.text('60 menit');
      await tester.ensureVisible(sixtyMin);
      await tester.tap(sixtyMin);
      await tester.pumpAndSettle();
      expect(duration, equals(60));
    });

    testWidgets('StepAbout allows selecting gender and stepping/typing age', (
      tester,
    ) async {
      int age = 28;
      String gender = 'male';

      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return StepAbout(
                gender: gender,
                age: age,
                onGenderChanged: (g) => setState(() => gender = g),
                onAgeChanged: (a) => setState(() => age = a),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial rendering
      expect(find.textContaining('28'), findsOneWidget);

      // Tap + button on age
      final addButtons = find.byIcon(Icons.add_rounded);
      await tester.ensureVisible(addButtons.first);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();
      expect(age, equals(29));

      // Tap - button on age
      final removeButtons = find.byIcon(Icons.remove_rounded);
      await tester.ensureVisible(removeButtons.first);
      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();
      expect(age, equals(28));
    });

    testWidgets('StepHeight renders height stage and ruler', (tester) async {
      double height = 170.0;

      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            key: const ValueKey('step_height_test'),
            builder: (context, setState) {
              return StepHeight(
                heightCm: height,
                onHeightChanged: (h) => setState(() => height = h),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('170 cm'), findsOneWidget);
    });

    testWidgets('StepWeight renders current and target weight with stepper', (
      tester,
    ) async {
      double currentWeight = 65.0;
      double targetWeight = 70.0;

      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            key: const ValueKey('step_weight_test'),
            builder: (context, setState) {
              return StepWeight(
                currentWeightKg: currentWeight,
                targetWeightKg: targetWeight,
                onCurrentWeightChanged: (cw) =>
                    setState(() => currentWeight = cw),
                onTargetWeightChanged: (tw) =>
                    setState(() => targetWeight = tw),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final addButtons = find.byIcon(Icons.add_rounded);
      await tester.ensureVisible(addButtons.first);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();
      expect(currentWeight, equals(65.5));
    });

    testWidgets(
      'StepExperience renders all 3 experience levels and allows selection',
      (tester) async {
        String level = 'beginner';

        await tester.pumpWidget(
          createTestWidget(
            StatefulBuilder(
              builder: (context, setState) {
                return StepExperience(
                  selectedLevel: level,
                  onLevelSelected: (l) => setState(() => level = l),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pemula'), findsOneWidget);
        expect(find.text('Menengah'), findsOneWidget);
        expect(find.text('Lanjutan'), findsOneWidget);

        // Select intermediate
        await tester.tap(find.text('Menengah'));
        await tester.pumpAndSettle();
        expect(level, equals('intermediate'));
      },
    );

    testWidgets('StepEquipment renders equipment list and allows toggling', (
      tester,
    ) async {
      List<String> equipments = ['bodyweight'];

      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return StepEquipment(
                selectedEquipments: equipments,
                onToggleEquipment: (eq) {
                  setState(() {
                    if (equipments.contains(eq)) {
                      equipments.remove(eq);
                    } else {
                      equipments.add(eq);
                    }
                  });
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Berat Tubuh'), findsOneWidget);
      expect(find.text('Dumbbell'), findsOneWidget);

      // Toggle Dumbbell
      await tester.tap(find.text('Dumbbell'));
      await tester.pumpAndSettle();
      expect(equipments.contains('dumbbell'), isTrue);
    });

    testWidgets(
      'StepLimitations renders limitation options and handles toggle',
      (tester) async {
        List<String> limitations = ['none'];

        await tester.pumpWidget(
          createTestWidget(
            StatefulBuilder(
              builder: (context, setState) {
                return StepLimitations(
                  selectedLimitations: limitations,
                  onToggleLimitation: (lim) {
                    setState(() {
                      if (lim == 'none') {
                        limitations = ['none'];
                      } else {
                        limitations.remove('none');
                        if (limitations.contains(lim)) {
                          limitations.remove(lim);
                        } else {
                          limitations.add(lim);
                        }
                      }
                    });
                  },
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tanpa batasan'), findsOneWidget);
        expect(find.textContaining('Lutut'), findsOneWidget);

        // Tap knee limitation
        await tester.tap(find.textContaining('Lutut'));
        await tester.pumpAndSettle();
        expect(limitations.contains('knee'), isTrue);
        expect(limitations.contains('none'), isFalse);
      },
    );
  });

  group('Onboarding Screens - PlanReadyScreen (P0)', () {
    testWidgets(
      'PlanReadyScreen displays celebration and View My Plan button',
      (tester) async {
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

        expect(find.text('Program kamu siap! 🎉'), findsOneWidget);
        expect(find.text('Lihat Program Saya'), findsOneWidget);
        expect(find.text('Program Bulking'), findsOneWidget);
        expect(find.textContaining('Hari / Minggu'), findsOneWidget);
        expect(find.textContaining('Menit / Sesi'), findsOneWidget);
        expect(find.textContaining('12 Minggu'), findsOneWidget);
      },
    );
  });
}
