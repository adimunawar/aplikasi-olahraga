import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../program/domain/services/program_week_schedule.dart';
import 'onboarding_state.dart';

typedef LoadUserProfile = Future<UserProfileEntity> Function();
typedef SaveUserProfile = Future<void> Function(UserProfileEntity profile);

final onboardingControllerProvider =
    StateNotifierProvider.autoDispose<OnboardingController, OnboardingState>((
      ref,
    ) {
      final db = AppDatabase.instance;
      return OnboardingController(
        loadProfile: db.getUserProfile,
        saveProfile: db.saveUserProfile,
      );
    });

/// Coordinates onboarding form state, step navigation, and profile persistence.
class OnboardingController extends StateNotifier<OnboardingState> {
  final LoadUserProfile _loadProfile;
  final SaveUserProfile _saveProfile;

  OnboardingController({required this._loadProfile, required this._saveProfile})
    : super(const OnboardingState());

  bool nextStep() {
    if (state.currentStep >= OnboardingState.totalSteps) return false;
    state = state.copyWith(currentStep: state.currentStep + 1);
    return true;
  }

  bool prevStep() {
    if (state.currentStep <= 0) return false;
    state = state.copyWith(currentStep: state.currentStep - 1);
    return true;
  }

  void setGoal(String goal) => state = state.copyWith(goal: goal);
  void setGender(String gender) => state = state.copyWith(gender: gender);
  void setAge(int age) => state = state.copyWith(age: age);
  void setHeightCm(double heightCm) =>
      state = state.copyWith(heightCm: heightCm);
  void setCurrentWeightKg(double weightKg) =>
      state = state.copyWith(currentWeightKg: weightKg);
  void setTargetWeightKg(double weightKg) =>
      state = state.copyWith(targetWeightKg: weightKg);
  void setLevel(String level) => state = state.copyWith(level: level);
  void setDaysPerWeek(int days) => state = state.copyWith(daysPerWeek: days);
  void setDurationMin(int minutes) =>
      state = state.copyWith(durationMin: minutes);

  void toggleEquipment(String id) {
    final next = List<String>.from(state.equipments);
    if (next.contains(id)) {
      if (next.length > 1) {
        next.remove(id);
      }
    } else {
      next.add(id);
    }
    state = state.copyWith(equipments: List.unmodifiable(next));
  }

  void toggleLimitation(String id) {
    if (id == 'none') {
      state = state.copyWith(limitations: const ['none']);
      return;
    }

    final next = List<String>.from(state.limitations)..remove('none');
    if (next.contains(id)) {
      next.remove(id);
      if (next.isEmpty) {
        next.add('none');
      }
    } else {
      next.add(id);
    }
    state = state.copyWith(limitations: List.unmodifiable(next));
  }

  Future<UserProfileEntity?> createPlan({DateTime? now}) async {
    state = state.copyWith(isCreatingPlan: true);

    try {
      final programStartDate = now ?? DateTime.now();
      final availableDays = ProgramWeekSchedule.availableWeekdaysForFrequency(
        startDate: programStartDate,
        frequency: state.daysPerWeek,
      );
      final currentProfile = await _loadProfile();
      final updatedProfile = currentProfile.copyWith(
        gender: state.gender,
        age: state.age,
        heightCm: state.heightCm,
        currentWeightKg: state.currentWeightKg,
        targetWeightKg: state.targetWeightKg,
        targetTimeframeWeeks: 12,
        goal: state.goal,
        experienceLevel: state.level,
        preferredDaysPerWeek: state.daysPerWeek,
        weeklyFrequency: state.daysPerWeek,
        preferredDurationMin: state.durationMin,
        availableDays: availableDays,
        equipments: state.equipments,
        trainingLimitations: state.limitations,
        updatedAt: programStartDate,
      );
      await _saveProfile(updatedProfile);
      return updatedProfile;
    } catch (e, stackTrace) {
      debugPrint('[Onboarding] Error preparing profile: $e\n$stackTrace');
      if (mounted) {
        state = state.copyWith(isCreatingPlan: false);
      }
      return null;
    }
  }
}
