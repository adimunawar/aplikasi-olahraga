import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/onboarding/domain/models/user_profile.dart';
import 'package:workout_app/features/onboarding/domain/services/target_calculator.dart';
import 'package:workout_app/features/program/domain/models/program_day.dart';

void main() {
  group('TargetCalculator Unit Tests', () {
    const profile = UserProfile(
      goal: WorkoutGoal.hypertrophy,
      fallbackLevel: FitnessLevel.intermediate,
      weightKg: 70.0,
    );

    test('Calculates rep targets based on direct assessment test results', () {
      const baseItem = WorkoutItem(
        exerciseId: 'push_up',
        sets: 3,
        reps: 10,
        restSeconds: 60,
      );

      // User tested max 20 pushups.
      // Week 1 factor is 0.60 -> 20 * 0.60 = 12 reps
      final targetW1 = TargetCalculator.calculateTarget(
        baseItem: baseItem,
        week: 1,
        profile: profile,
        testResults: {'push_up': 20},
      );
      expect(targetW1.reps, equals(12));

      // Week 4 factor is 0.75 -> 20 * 0.75 = 15 reps
      final targetW4 = TargetCalculator.calculateTarget(
        baseItem: baseItem,
        week: 4,
        profile: profile,
        testResults: {'push_up': 20},
      );
      expect(targetW4.reps, equals(15));
    });

    test('Calculates duration targets for plank and time-based movements', () {
      const plankItem = WorkoutItem(
        exerciseId: 'plank',
        sets: 3,
        durationSec: 30,
        restSeconds: 45,
      );


      // User held plank for 60 seconds
      // Week 1 factor is 0.60 -> 60 * 0.60 = 36 seconds
      final targetW1 = TargetCalculator.calculateTarget(
        baseItem: plankItem,
        week: 1,
        profile: profile,
        testResults: {'plank': 60},
      );
      expect(targetW1.durationSec, equals(36));

      // Clamp test: minimum time bound is 15 seconds
      final targetClamped = TargetCalculator.calculateTarget(
        baseItem: plankItem,
        week: 1,
        profile: profile,
        testResults: {'plank': 10},
      );
      expect(targetClamped.durationSec, equals(15));
    });

    test('Calculates variation exercises from parent test results', () {
      const inclinePushUp = WorkoutItem(
        exerciseId: 'incline_push_up',
        sets: 3,
        reps: 10,
        restSeconds: 60,
      );

      // Pushup test = 20. Incline pushup multiplier = 1.2 * factor (0.60) = 0.72 -> 20 * 0.72 = 14 reps
      final targetIncline = TargetCalculator.calculateTarget(
        baseItem: inclinePushUp,
        week: 1,
        profile: profile,
        testResults: {'push_up': 20},
      );
      expect(targetIncline.reps, equals(14));

      const diamondPushUp = WorkoutItem(
        exerciseId: 'diamond_push_up',
        sets: 3,
        reps: 8,
        restSeconds: 60,
      );

      // Diamond pushup multiplier = 0.6 * factor (0.60) = 0.36 -> 20 * 0.36 = 7 reps
      final targetDiamond = TargetCalculator.calculateTarget(
        baseItem: diamondPushUp,
        week: 1,
        profile: profile,
        testResults: {'push_up': 20},
      );
      expect(targetDiamond.reps, equals(7));
    });

    test('Falls back to profile fitness level when no test result is present', () {
      const baseItem = WorkoutItem(
        exerciseId: 'squats',
        sets: 3,
        reps: 10,
        restSeconds: 60,
      );

      // Beginner multiplier = 0.7 -> 10 * 0.7 = 7 reps
      const beginnerProfile = UserProfile(fallbackLevel: FitnessLevel.beginner);
      final targetBeginner = TargetCalculator.calculateTarget(
        baseItem: baseItem,
        week: 1,
        profile: beginnerProfile,
      );
      expect(targetBeginner.reps, equals(7));

      // Advanced multiplier = 1.3 -> 10 * 1.3 = 13 reps
      const advancedProfile = UserProfile(fallbackLevel: FitnessLevel.advanced);
      final targetAdvanced = TargetCalculator.calculateTarget(
        baseItem: baseItem,
        week: 1,
        profile: advancedProfile,
      );
      expect(targetAdvanced.reps, equals(13));
    });
  });

  group('UserProfile Model Unit Tests', () {
    test('Calculates daily protein target based on weight and protein factor', () {
      const p = UserProfile(weightKg: 70.0, proteinFactor: 1.6);
      expect(p.dailyProteinTargetG, equals(112.0));
    });

    test('Serializes to JSON and parses back correctly', () {
      const original = UserProfile(
        goal: WorkoutGoal.hypertrophy,
        daysPerWeek: 5,
        age: 27,
        heightCm: 172.0,
        weightKg: 68.0,
        fallbackLevel: FitnessLevel.advanced,
        readinessFlags: ['knee_pain'],
        proteinFactor: 1.8,
        foodExclusions: ['nuts'],
      );

      final json = original.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.goal, equals(WorkoutGoal.hypertrophy));
      expect(restored.daysPerWeek, equals(5));
      expect(restored.age, equals(27));
      expect(restored.heightCm, equals(172.0));
      expect(restored.weightKg, equals(68.0));
      expect(restored.fallbackLevel, equals(FitnessLevel.advanced));
      expect(restored.readinessFlags, contains('knee_pain'));
      expect(restored.foodExclusions, contains('nuts'));
    });
  });
}
