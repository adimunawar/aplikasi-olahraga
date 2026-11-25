import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../../program/domain/services/program_week_schedule.dart';
import '../../data/datasources/user_supabase_datasource.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/user_profile_repository.dart';
import 'profile_state.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(
    remoteDatasource: const UserSupabaseDatasource(),
    localDatabase: AppDatabase.instance,
  );
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      return ProfileController(
        repository: ref.watch(userProfileRepositoryProvider),
      );
    });

/// Riverpod StateNotifier untuk Halaman Profil Pengguna & Edit Sub-pages
class ProfileController extends StateNotifier<ProfileState> {
  final UserProfileRepository _repository;

  ProfileController({required this._repository}) : super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _repository.getUserProfile();
      final settings = await _repository.getUserSettings();

      final weight = profile.currentWeightKg;
      final height = profile.heightCm;

      double bmi = 0;
      if (height > 0 && weight > 0) {
        final hM = height / 100.0;
        bmi = double.parse((weight / (hM * hM)).toStringAsFixed(1));
      }

      final gender = settings.gender;
      final targetWeight = settings.targetWeightKg;
      final intensity = settings.trainingIntensity;
      final workoutRem = settings.workoutReminder;
      final remTime = settings.reminderTime;
      final restDayRem = settings.restDayReminder;
      final progressCheck = settings.progressCheckin;
      final streakRem = settings.streakReminder;
      final lang = settings.language;
      final themeMode = settings.theme;
      final haptic = settings.hapticFeedback;
      final sound = settings.soundEffects;
      final syncData = settings.dataSync;

      final lastUpdated = DateFormat('MMM d, yyyy').format(profile.updatedAt);

      state = state.copyWith(
        displayName: profile.displayName,
        journeyStatus: profile.experienceLevel.isEmpty
            ? ''
            : 'Bulking journey • ${profile.experienceLevel[0].toUpperCase()}${profile.experienceLevel.substring(1)}',
        age: profile.age,
        gender: gender,
        currentWeight: weight,
        currentHeight: height,
        currentBmi: bmi,
        targetWeight: targetWeight,
        goal: profile.goal == 'muscle_gain'
            ? 'Build Muscle (Bulking)'
            : profile.goal,
        experienceLevel: profile.experienceLevel.isEmpty
            ? ''
            : '${profile.experienceLevel[0].toUpperCase()}${profile.experienceLevel.substring(1)}',
        preferredDaysPerWeek: profile.preferredDaysPerWeek,
        preferredDurationMin: profile.preferredDurationMin,
        trainingIntensity: intensity,
        unitPreference: profile.unitPreference == 'metric'
            ? 'Metric (kg, cm)'
            : 'Imperial (lbs, in)',
        workoutReminder: workoutRem,
        reminderTime: remTime,
        restDayReminder: restDayRem,
        progressCheckin: progressCheck,
        streakReminder: streakRem,
        language: lang,
        theme: themeMode,
        hapticFeedback: haptic,
        soundEffects: sound,
        dataSync: syncData,
        lastUpdatedDate: lastUpdated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat profil: $e',
      );
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _repository.updateDisplayName(name);
      state = state.copyWith(displayName: name);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update nama: $e');
    }
  }

  Future<void> updatePersonalInfo({
    required String fullName,
    required int age,
    required String gender,
  }) async {
    try {
      final profile = await _repository.getUserProfile();
      final updatedProfile = profile.copyWith(
        displayName: fullName,
        age: age,
        updatedAt: DateTime.now(),
      );
      await _repository.saveUserProfile(updatedProfile);

      final settings = await _repository.getUserSettings();
      await _repository.saveUserSettings(
        settings.copyWith(gender: gender, updatedAt: DateTime.now()),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_gender', gender);

      state = state.copyWith(
        displayName: fullName,
        age: age,
        gender: gender,
        lastUpdatedDate: DateFormat('MMM d, yyyy').format(DateTime.now()),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update personal info: $e');
    }
  }

  Future<void> updateBodyData({
    required double weightKg,
    required double heightCm,
  }) async {
    try {
      await _repository.updateBodyData(weightKg: weightKg, heightCm: heightCm);
      final hM = heightCm / 100.0;
      final bmi = double.parse((weightKg / (hM * hM)).toStringAsFixed(1));
      final dateStr = DateFormat('MMM d, yyyy').format(DateTime.now());

      state = state.copyWith(
        currentWeight: weightKg,
        currentHeight: heightCm,
        currentBmi: bmi,
        lastUpdatedDate: dateStr,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update data tubuh: $e');
    }
  }

  Future<void> updateFitnessGoals({
    required String goal,
    required double targetWeight,
    required String experienceLevel,
  }) async {
    try {
      final profile = await _repository.getUserProfile();
      final updatedProfile = profile.copyWith(
        goal: goal,
        experienceLevel: experienceLevel.toLowerCase(),
        updatedAt: DateTime.now(),
      );
      await _repository.saveUserProfile(updatedProfile);

      final settings = await _repository.getUserSettings();
      await _repository.saveUserSettings(
        settings.copyWith(
          targetWeightKg: targetWeight,
          updatedAt: DateTime.now(),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('pref_target_weight', targetWeight);

      state = state.copyWith(
        goal: goal,
        targetWeight: targetWeight,
        experienceLevel: experienceLevel,
        journeyStatus: 'Bulking journey • $experienceLevel',
        lastUpdatedDate: DateFormat('MMM d, yyyy').format(DateTime.now()),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update fitness goals: $e');
    }
  }

  List<String> _getAvailableDays(int frequency, {required DateTime startDate}) {
    return ProgramWeekSchedule.availableWeekdaysForFrequency(
      startDate: startDate,
      frequency: frequency,
    );
  }

  @visibleForTesting
  List<String> getAvailableDaysForTesting(
    int frequency, {
    DateTime? startDate,
  }) {
    return _getAvailableDays(
      frequency,
      startDate: startDate ?? DateTime(2026, 11, 2),
    );
  }

  Future<void> updateWorkoutPreferences({
    required int trainingDaysPerWeek,
    required int workoutDurationMin,
    required String trainingIntensity,
  }) async {
    try {
      final profile = await _repository.getUserProfile();
      final updatedAt = DateTime.now();
      final userId = profile.id.isNotEmpty ? profile.id : 'default_user';
      var activeProgram = await AppDatabase.instance
          .getActiveTrainingProgram(userId)
          .catchError((_) => null);
      activeProgram ??= await AppDatabase.instance
          .getActiveTrainingProgram('default_user')
          .catchError((_) => null);

      // Keep the existing program's weekday anchor when only duration or
      // intensity changes. A frequency change starts a fresh schedule today;
      // HomeController will regenerate the matching session templates.
      final scheduleStartDate =
          activeProgram != null &&
              activeProgram.weeklyFrequency == trainingDaysPerWeek
          ? activeProgram.startDate
          : updatedAt;
      final availableDays = _getAvailableDays(
        trainingDaysPerWeek,
        startDate: scheduleStartDate,
      );

      final updatedProfile = profile.copyWith(
        preferredDaysPerWeek: trainingDaysPerWeek,
        weeklyFrequency: trainingDaysPerWeek,
        availableDays: availableDays,
        preferredDurationMin: workoutDurationMin,
        updatedAt: updatedAt,
      );

      await _repository.saveUserProfile(updatedProfile);

      final settings = await _repository.getUserSettings();
      await _repository.saveUserSettings(
        settings.copyWith(
          trainingIntensity: trainingIntensity,
          updatedAt: updatedAt,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_training_intensity', trainingIntensity);

      state = state.copyWith(
        preferredDaysPerWeek: trainingDaysPerWeek,
        preferredDurationMin: workoutDurationMin,
        trainingIntensity: trainingIntensity,
        lastUpdatedDate: DateFormat('MMM d, yyyy').format(updatedAt),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Gagal update workout preferences: $e',
      );
    }
  }

  Future<void> updateReminders({
    required bool workoutReminder,
    required String reminderTime,
    required bool restDayReminder,
    required bool progressCheckin,
    required bool streakReminder,
  }) async {
    try {
      final settings = await _repository.getUserSettings();
      await _repository.saveUserSettings(
        settings.copyWith(
          workoutReminder: workoutReminder,
          reminderTime: reminderTime,
          restDayReminder: restDayReminder,
          progressCheckin: progressCheckin,
          streakReminder: streakReminder,
          updatedAt: DateTime.now(),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pref_workout_reminder', workoutReminder);
      await prefs.setString('pref_reminder_time', reminderTime);
      await prefs.setBool('pref_rest_day_reminder', restDayReminder);
      await prefs.setBool('pref_progress_checkin', progressCheckin);
      await prefs.setBool('pref_streak_reminder', streakReminder);

      state = state.copyWith(
        workoutReminder: workoutReminder,
        reminderTime: reminderTime,
        restDayReminder: restDayReminder,
        progressCheckin: progressCheckin,
        streakReminder: streakReminder,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update reminders: $e');
    }
  }

  Future<void> updateAppSettings({
    required String language,
    required String theme,
    required String units,
    required bool hapticFeedback,
    required bool soundEffects,
    required bool dataSync,
  }) async {
    try {
      final profile = await _repository.getUserProfile();
      final unitCode = units.toLowerCase().contains('metric')
          ? 'metric'
          : 'imperial';
      final updatedProfile = profile.copyWith(
        unitPreference: unitCode,
        updatedAt: DateTime.now(),
      );
      await _repository.saveUserProfile(updatedProfile);

      final settings = await _repository.getUserSettings();
      await _repository.saveUserSettings(
        settings.copyWith(
          language: language,
          theme: theme,
          hapticFeedback: hapticFeedback,
          soundEffects: soundEffects,
          dataSync: dataSync,
          updatedAt: DateTime.now(),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_language', language);
      await prefs.setString('pref_theme', theme);
      await prefs.setBool('pref_haptic_feedback', hapticFeedback);
      await prefs.setBool('pref_sound_effects', soundEffects);
      await prefs.setBool('pref_data_sync', dataSync);

      state = state.copyWith(
        language: language,
        theme: theme,
        unitPreference: units,
        hapticFeedback: hapticFeedback,
        soundEffects: soundEffects,
        dataSync: dataSync,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update app settings: $e');
    }
  }
}
