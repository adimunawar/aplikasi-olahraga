import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/features/program/domain/services/dynamic_program_generator.dart';
import 'mock_exercise_factory.dart';

void main() {
  late DynamicProgramGenerator generator;
  final catalog = getStandardMockCatalog();

  setUp(() {
    generator = const DynamicProgramGenerator();
  });

  UserProfileEntity createTestProfile({
    String goal = 'muscle_gain',
    int weeklyFrequency = 4,
    int durationMin = 45,
    String experienceLevel = 'beginner',
    List<String> equipments = const ['bodyweight'],
  }) {
    return UserProfileEntity(
      id: 'test_user_1',
      displayName: 'Adi',
      age: 28,
      heightCm: 170.0,
      currentWeightKg: 75.0,
      targetWeightKg: 82.0,
      targetTimeframeWeeks: 12,
      goal: goal,
      experienceLevel: experienceLevel,
      preferredDaysPerWeek: weeklyFrequency,
      weeklyFrequency: weeklyFrequency,
      preferredDurationMin: durationMin,
      availableDays: const ['monday', 'tuesday', 'thursday', 'friday'],
      equipments: equipments,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('DynamicProgramGenerator - Prioritas P0 (Frequency & Precision)', () {
    test('Generates exactly 2 sessions for 2-day frequency', () {
      final profile = createTestProfile(weeklyFrequency: 2);
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      expect(result.sessions.length, equals(2));
      expect(result.program.weeklyFrequency, equals(2));
    });

    test('Generates exactly 3 sessions for 3-day frequency', () {
      final profile = createTestProfile(weeklyFrequency: 3);
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      expect(result.sessions.length, equals(3));
      expect(result.program.weeklyFrequency, equals(3));
    });

    test('Generates exactly 4 sessions for 4-day frequency', () {
      final profile = createTestProfile(weeklyFrequency: 4);
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      expect(result.sessions.length, equals(4));
      expect(result.program.weeklyFrequency, equals(4));
    });

    test('Generates exactly 5 sessions for 5-day frequency (Fix Audit Finding #2)', () {
      final profile = createTestProfile(weeklyFrequency: 5);
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      expect(result.sessions.length, equals(5));
      expect(result.program.weeklyFrequency, equals(5));
    });

    test('Generates exactly 6 sessions for 6-day frequency', () {
      final profile = createTestProfile(weeklyFrequency: 6);
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      expect(result.sessions.length, equals(6));
      expect(result.program.weeklyFrequency, equals(6));
    });
  });

  group('DynamicProgramGenerator - Goal-Based Naming & Program Meta', () {
    test('Goal muscle_gain / bulking maps to Bulking Program', () {
      final profile = createTestProfile(goal: 'muscle_gain');
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      expect(result.program.name, equals('Bulking Program'));
    });

    test('Goal fat_loss / cut maps to Fat Loss & Conditioning', () {
      final profile = createTestProfile(goal: 'fat_loss');
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      expect(result.program.name, equals('Fat Loss & Conditioning'));
    });

    test('Goal maintain maps to Maintain & Stay Fit', () {
      final profile = createTestProfile(goal: 'maintain');
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      expect(result.program.name, equals('Maintain & Stay Fit'));
    });
  });

  group('DynamicProgramGenerator - Experience Level & Progression Baseline', () {
    test('Beginner level defaults to knee_push_up baseline', () {
      final profile = createTestProfile(experienceLevel: 'beginner');
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      final firstSession = result.sessions.first;
      final hasKneePushUp = firstSession.exercises.any(
        (e) => e.exercise.id == 'knee_push_up',
      );
      expect(hasKneePushUp, isTrue);
    });

    test('Intermediate level defaults to push_up baseline', () {
      final profile = createTestProfile(experienceLevel: 'intermediate');
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      final firstSession = result.sessions.first;
      final hasPushUp = firstSession.exercises.any(
        (e) => e.exercise.id == 'push_up',
      );
      expect(hasPushUp, isTrue);
    });

    test('Advanced level defaults to diamond_push_up baseline', () {
      final profile = createTestProfile(experienceLevel: 'advanced');
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      final firstSession = result.sessions.first;
      final hasDiamond = firstSession.exercises.any(
        (e) => e.exercise.id == 'diamond_push_up',
      );
      expect(hasDiamond, isTrue);
    });
  });

  group('DynamicProgramGenerator - Prescription Validity', () {
    test('All generated exercises have valid sets, reps, and rest', () {
      final profile = createTestProfile(weeklyFrequency: 4);
      final result = generator.generate(
        userProfile: profile,
        catalogExercises: catalog,
      );

      for (final session in result.sessions) {
        expect(session.exercises.isNotEmpty, isTrue);
        for (final exerciseDetail in session.exercises) {
          expect(exerciseDetail.prescription.targetSets, greaterThan(0));
          expect(exerciseDetail.prescription.minReps, greaterThan(0));
          expect(exerciseDetail.prescription.restSeconds, greaterThan(0));
        }
      }
    });
  });
}

