import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:workout_app/features/onboarding/presentation/controllers/onboarding_state.dart';

void main() {
  UserProfileEntity fakeProfile() {
    return UserProfileEntity(
      id: 'default_user',
      displayName: 'Test User',
      gender: 'male',
      age: 25,
      heightCm: 170,
      currentWeightKg: 70,
      targetWeightKg: 75,
      targetTimeframeWeeks: 12,
      goal: 'muscle_gain',
      experienceLevel: 'beginner',
      preferredDaysPerWeek: 4,
      weeklyFrequency: 4,
      preferredDurationMin: 45,
      availableDays: const ['monday', 'wednesday', 'friday', 'sunday'],
      equipments: const ['bodyweight'],
      trainingLimitations: const ['none'],
      updatedAt: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
    );
  }

  group('OnboardingController', () {
    test('nextStep and prevStep respect step boundaries', () {
      final controller = OnboardingController(
        loadProfile: () async => fakeProfile(),
        saveProfile: (_) async {},
      );

      expect(controller.state.currentStep, 0);
      expect(controller.prevStep(), isFalse);

      for (var i = 0; i < OnboardingState.totalSteps; i++) {
        expect(controller.nextStep(), isTrue);
      }
      expect(controller.state.currentStep, OnboardingState.totalSteps);
      expect(controller.nextStep(), isFalse);

      expect(controller.prevStep(), isTrue);
      expect(controller.state.currentStep, OnboardingState.totalSteps - 1);
    });

    test('toggleEquipment keeps at least one selected equipment', () {
      final controller = OnboardingController(
        loadProfile: () async => fakeProfile(),
        saveProfile: (_) async {},
      );

      controller.toggleEquipment('bodyweight');
      expect(controller.state.equipments, ['bodyweight']);

      controller.toggleEquipment('dumbbell');
      expect(controller.state.equipments, ['bodyweight', 'dumbbell']);

      controller.toggleEquipment('bodyweight');
      expect(controller.state.equipments, ['dumbbell']);
    });

    test('toggleLimitation resets to none when empty or none selected', () {
      final controller = OnboardingController(
        loadProfile: () async => fakeProfile(),
        saveProfile: (_) async {},
      );

      controller.toggleLimitation('knee');
      expect(controller.state.limitations, ['knee']);

      controller.toggleLimitation('knee');
      expect(controller.state.limitations, ['none']);

      controller.toggleLimitation('back');
      controller.toggleLimitation('none');
      expect(controller.state.limitations, ['none']);
    });

    test('createPlan persists updated profile and returns it', () async {
      UserProfileEntity? saved;
      final controller = OnboardingController(
        loadProfile: () async => fakeProfile(),
        saveProfile: (profile) async => saved = profile,
      );

      controller.setGoal('fat_loss');
      controller.setGender('female');
      controller.setAge(30);
      controller.setHeightCm(165);
      controller.setCurrentWeightKg(62);
      controller.setTargetWeightKg(57);
      controller.setLevel('intermediate');
      controller.setDaysPerWeek(3);
      controller.setDurationMin(60);

      final result = await controller.createPlan(now: DateTime(2026, 3, 2));

      expect(result, isNotNull);
      expect(saved, isNotNull);
      expect(saved!.goal, 'fat_loss');
      expect(saved!.gender, 'female');
      expect(saved!.age, 30);
      expect(saved!.heightCm, 165);
      expect(saved!.currentWeightKg, 62);
      expect(saved!.targetWeightKg, 57);
      expect(saved!.experienceLevel, 'intermediate');
      expect(saved!.preferredDaysPerWeek, 3);
      expect(saved!.preferredDurationMin, 60);
    });

    test('createPlan resets loading state and returns null on error', () async {
      final controller = OnboardingController(
        loadProfile: () async => throw Exception('db error'),
        saveProfile: (_) async {},
      );

      final result = await controller.createPlan();

      expect(result, isNull);
      expect(controller.state.isCreatingPlan, isFalse);
    });
  });
}
