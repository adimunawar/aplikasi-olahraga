import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';

void main() {
  group('UserProfileEntity - Onboarding Data Unit Tests', () {
    test('Correctly instantiates UserProfileEntity from onboarding inputs', () {
      final profile = UserProfileEntity(
        id: 'user_123',
        displayName: 'User',
        gender: 'male',
        age: 28,
        heightCm: 175.0,
        currentWeightKg: 70.0,
        targetWeightKg: 78.0,
        targetTimeframeWeeks: 12,
        goal: 'muscle_gain',
        experienceLevel: 'beginner',
        preferredDaysPerWeek: 4,
        weeklyFrequency: 4,
        preferredDurationMin: 45,
        availableDays: const ['monday', 'tuesday', 'thursday', 'friday'],
        trainingLimitations: const ['none'],
        equipments: const ['bodyweight', 'dumbbell'],
        timezone: 'Asia/Jakarta',
        unitPreference: 'metric',
        createdAt: DateTime.parse('2026-11-14T08:00:00Z'),
        updatedAt: DateTime.parse('2026-11-14T08:00:00Z'),
      );

      expect(profile.id, equals('user_123'));
      expect(profile.gender, equals('male'));
      expect(profile.age, equals(28));
      expect(profile.heightCm, equals(175.0));
      expect(profile.currentWeightKg, equals(70.0));
      expect(profile.targetWeightKg, equals(78.0));
      expect(profile.durationPreferenceMinutes, equals(45));
      expect(profile.availableEquipment, contains('dumbbell'));
    });

    test('Calculates weight delta and direction correctly for bulking/cutting', () {
      final bulkingProfile = UserProfileEntity(
        id: 'u1',
        displayName: 'User 1',
        age: 25,
        heightCm: 170.0,
        currentWeightKg: 65.0,
        targetWeightKg: 72.0,
        goal: 'muscle_gain',
        experienceLevel: 'beginner',
        preferredDaysPerWeek: 3,
        preferredDurationMin: 30,
        availableDays: const ['monday', 'wednesday', 'friday'],
        equipments: const ['bodyweight'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final weightGainDelta = bulkingProfile.targetWeightKg! - bulkingProfile.currentWeightKg;
      expect(weightGainDelta, equals(7.0));
      expect(weightGainDelta > 0, isTrue);

      final cuttingProfile = UserProfileEntity(
        id: 'u2',
        displayName: 'User 2',
        age: 30,
        heightCm: 180.0,
        currentWeightKg: 90.0,
        targetWeightKg: 80.0,
        goal: 'fat_loss',
        experienceLevel: 'intermediate',
        preferredDaysPerWeek: 4,
        preferredDurationMin: 45,
        availableDays: const ['monday', 'tuesday', 'thursday', 'friday'],
        equipments: const ['bodyweight'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );


      final weightLossDelta = cuttingProfile.targetWeightKg! - cuttingProfile.currentWeightKg;
      expect(weightLossDelta, equals(-10.0));
      expect(weightLossDelta < 0, isTrue);
    });

    test('Serializes to Map and deserializes from Map (Round-trip integrity)', () {
      final original = UserProfileEntity(
        id: 'roundtrip_user',
        displayName: 'Coach Adi',
        gender: 'female',
        age: 26,
        heightCm: 165.0,
        currentWeightKg: 55.0,
        targetWeightKg: 58.0,
        targetTimeframeWeeks: 8,
        goal: 'maintenance',
        experienceLevel: 'advanced',
        preferredDaysPerWeek: 5,
        weeklyFrequency: 5,
        preferredDurationMin: 60,
        availableDays: const ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
        trainingLimitations: const ['joint_pain'],
        equipments: const ['bodyweight', 'pull_up_bar'],
        timezone: 'UTC',
        unitPreference: 'metric',
        createdAt: DateTime.parse('2026-11-14T08:00:00Z'),
        updatedAt: DateTime.parse('2026-11-14T08:00:00Z'),
      );

      final map = original.toMap();
      final reconstructed = UserProfileEntity.fromMap(map);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.displayName, equals(original.displayName));
      expect(reconstructed.gender, equals(original.gender));
      expect(reconstructed.age, equals(original.age));
      expect(reconstructed.heightCm, equals(original.heightCm));
      expect(reconstructed.currentWeightKg, equals(original.currentWeightKg));
      expect(reconstructed.targetWeightKg, equals(original.targetWeightKg));
      expect(reconstructed.targetTimeframeWeeks, equals(original.targetTimeframeWeeks));
      expect(reconstructed.goal, equals(original.goal));
      expect(reconstructed.experienceLevel, equals(original.experienceLevel));
      expect(reconstructed.weeklyFrequency, equals(original.weeklyFrequency));
      expect(reconstructed.preferredDurationMin, equals(original.preferredDurationMin));
      expect(reconstructed.availableDays, equals(original.availableDays));
      expect(reconstructed.trainingLimitations, equals(original.trainingLimitations));
      expect(reconstructed.equipments, equals(original.equipments));
    });

    test('Handles null optional fields gracefully with defaults', () {
      final minimalMap = {
        'id': 'minimal_user',
        'current_weight_kg': 60.0,
        'height_cm': 168.0,
      };

      final profile = UserProfileEntity.fromMap(minimalMap);

      expect(profile.id, equals('minimal_user'));
      expect(profile.currentWeightKg, equals(60.0));
      expect(profile.heightCm, equals(168.0));
      expect(profile.displayName, equals('User'));
      expect(profile.goal, equals('muscle_gain'));
      expect(profile.experienceLevel, equals('beginner'));
      expect(profile.weeklyFrequency, equals(3));
      expect(profile.availableDays, contains('monday'));
    });
  });
}
