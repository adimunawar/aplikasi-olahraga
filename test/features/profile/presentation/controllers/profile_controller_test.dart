import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/core/database/models/user_settings_entity.dart';
import 'package:workout_app/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';

class _FakeUserProfileRepository implements UserProfileRepository {
  _FakeUserProfileRepository({
    UserProfileEntity? profile,
    UserSettingsEntity? settings,
    this.shouldThrowOnLoad = false,
  })  : _profile = profile ??
            UserProfileEntity(
              id: 'user_1',
              displayName: 'Adi',
              age: 26,
              heightCm: 175,
              currentWeightKg: 70,
              goal: 'muscle_gain',
              experienceLevel: 'beginner',
              preferredDaysPerWeek: 4,
              preferredDurationMin: 45,
              unitPreference: 'metric',
              equipments: const ['dumbbells'],
              createdAt: DateTime(2026, 11, 1),
              updatedAt: DateTime(2026, 11, 20),
            ),
        _settings = settings ??
            UserSettingsEntity(
              gender: 'Male',
              targetWeightKg: 75,
              trainingIntensity: 'Moderate',
              language: 'Bahasa Indonesia',
              theme: 'Light',
              updatedAt: DateTime(2026, 11, 20),
            );

  UserProfileEntity _profile;
  UserSettingsEntity _settings;
  final bool shouldThrowOnLoad;

  @override
  Future<UserProfileEntity> getUserProfile() async {
    if (shouldThrowOnLoad) throw StateError('db error');
    return _profile;
  }

  @override
  Future<void> saveUserProfile(UserProfileEntity profile) async {
    _profile = profile;
  }

  @override
  Future<void> updateDisplayName(String name) async {
    _profile = _profile.copyWith(displayName: name);
  }

  @override
  Future<void> updateBodyData({
    required double weightKg,
    required double heightCm,
  }) async {
    _profile = _profile.copyWith(
      currentWeightKg: weightKg,
      heightCm: heightCm,
    );
  }

  @override
  Future<UserSettingsEntity> getUserSettings() async {
    if (shouldThrowOnLoad) throw StateError('db error');
    return _settings;
  }

  @override
  Future<void> saveUserSettings(UserSettingsEntity settings) async {
    _settings = settings;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileController', () {
    test('loadProfile maps profile, settings, and calculates BMI', () async {
      final repo = _FakeUserProfileRepository();
      final controller = ProfileController(repository: repo);

      await controller.loadProfile();

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.displayName, 'Adi');
      expect(controller.state.currentBmi, 22.9);
      expect(controller.state.goal, 'Build Muscle (Bulking)');
      expect(controller.state.experienceLevel, 'Beginner');
      expect(controller.state.journeyStatus, 'Bulking journey • Beginner');
      expect(controller.state.unitPreference, 'Metric (kg, cm)');
      expect(controller.state.language, 'Bahasa Indonesia');
    });

    test('loadProfile sets errorMessage when repository throws', () async {
      final repo = _FakeUserProfileRepository(shouldThrowOnLoad: true);
      final controller = ProfileController(repository: repo);

      await controller.loadProfile();

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, contains('Gagal memuat profil'));
    });

    test('updatePersonalInfo persists profile, settings, and prefs', () async {
      final repo = _FakeUserProfileRepository();
      final controller = ProfileController(repository: repo);
      await controller.loadProfile();

      await controller.updatePersonalInfo(
        fullName: 'Budi',
        age: 30,
        gender: 'Female',
      );

      expect(controller.state.displayName, 'Budi');
      expect(controller.state.age, 30);
      expect(controller.state.gender, 'Female');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pref_gender'), 'Female');
    });

    test('updateBodyData updates weight, height, and recalculates BMI',
        () async {
      final repo = _FakeUserProfileRepository();
      final controller = ProfileController(repository: repo);
      await controller.loadProfile();

      await controller.updateBodyData(weightKg: 80, heightCm: 180);

      expect(controller.state.currentWeight, 80);
      expect(controller.state.currentHeight, 180);
      expect(controller.state.currentBmi, 24.7);
    });

    test('updateFitnessGoals updates goal, targetWeight, and level', () async {
      final repo = _FakeUserProfileRepository();
      final controller = ProfileController(repository: repo);
      await controller.loadProfile();

      await controller.updateFitnessGoals(
        goal: 'Fat Loss & Lean Definition',
        targetWeight: 68,
        experienceLevel: 'Intermediate',
      );

      expect(controller.state.goal, 'Fat Loss & Lean Definition');
      expect(controller.state.targetWeight, 68);
      expect(controller.state.experienceLevel, 'Intermediate');
      expect(
        controller.state.journeyStatus,
        'Bulking journey • Intermediate',
      );
    });

    test('updateReminders updates reminder settings and state', () async {
      final repo = _FakeUserProfileRepository();
      final controller = ProfileController(repository: repo);
      await controller.loadProfile();

      await controller.updateReminders(
        workoutReminder: false,
        reminderTime: '06:30 AM',
        restDayReminder: false,
        progressCheckin: true,
        streakReminder: false,
      );

      expect(controller.state.workoutReminder, isFalse);
      expect(controller.state.reminderTime, '06:30 AM');
      expect(controller.state.restDayReminder, isFalse);
      expect(controller.state.progressCheckin, isTrue);
      expect(controller.state.streakReminder, isFalse);
    });

    test('updateAppSettings maps units and updates state', () async {
      final repo = _FakeUserProfileRepository();
      final controller = ProfileController(repository: repo);
      await controller.loadProfile();

      await controller.updateAppSettings(
        language: 'English',
        theme: 'Dark',
        units: 'Imperial (lbs, in)',
        hapticFeedback: false,
        soundEffects: false,
        dataSync: true,
      );

      expect(controller.state.language, 'English');
      expect(controller.state.theme, 'Dark');
      expect(controller.state.unitPreference, 'Imperial (lbs, in)');
      expect(controller.state.hapticFeedback, isFalse);
      expect(controller.state.soundEffects, isFalse);
      expect(controller.state.dataSync, isTrue);
      expect((await repo.getUserProfile()).unitPreference, 'imperial');
    });
  });
}
