import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/core/database/models/user_settings_entity.dart';
import 'package:workout_app/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:workout_app/features/profile/presentation/controllers/profile_controller.dart';

class FakeUserProfileRepository implements UserProfileRepository {
  UserProfileEntity currentProfile;
  UserSettingsEntity currentSettings;

  UserProfileEntity? lastSavedProfile;
  UserSettingsEntity? lastSavedSettings;

  FakeUserProfileRepository({
    required this.currentProfile,
    required this.currentSettings,
  });

  @override
  Future<UserProfileEntity> getUserProfile() async => currentProfile;

  @override
  Future<void> saveUserProfile(UserProfileEntity profile) async {
    lastSavedProfile = profile;
    currentProfile = profile;
  }

  @override
  Future<UserSettingsEntity> getUserSettings() async => currentSettings;

  @override
  Future<void> saveUserSettings(UserSettingsEntity settings) async {
    lastSavedSettings = settings;
    currentSettings = settings;
  }

  @override
  Future<void> updateBodyData({
    required double weightKg,
    required double heightCm,
  }) async {}

  @override
  Future<void> updateDisplayName(String name) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeUserProfileRepository fakeRepository;
  late ProfileController controller;

  final initialProfile = UserProfileEntity(
    id: 'user_1',
    displayName: 'Adi Munawar',
    age: 28,
    heightCm: 175.0,
    currentWeightKg: 70.0,
    targetWeightKg: 75.0,
    goal: 'muscle_gain',
    experienceLevel: 'intermediate',
    preferredDurationMin: 45,
    preferredDaysPerWeek: 3,
    weeklyFrequency: 3,
    availableDays: const ['monday', 'wednesday', 'friday'],
    equipments: const ['dumbbell'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final initialSettings = UserSettingsEntity(
    id: 'user_1',
    gender: 'male',
    targetWeightKg: 75.0,
    trainingIntensity: 'medium',
    workoutReminder: true,
    reminderTime: '08:00 AM',
    restDayReminder: true,
    progressCheckin: true,
    streakReminder: true,
    language: 'id',
    theme: 'system',
    hapticFeedback: true,
    soundEffects: true,
    dataSync: true,
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeRepository = FakeUserProfileRepository(
      currentProfile: initialProfile,
      currentSettings: initialSettings,
    );
    controller = ProfileController(repository: fakeRepository);
  });

  group('ProfileController - Pemetaan Jadwal Latihan (_getAvailableDays)', () {
    test('Frekuensi 2 hari menghasilkan Monday, Thursday', () {
      final days = controller.getAvailableDaysForTesting(2);
      expect(days, equals(['monday', 'thursday']));
    });

    test('Frekuensi 3 hari menghasilkan Monday, Wednesday, Friday', () {
      final days = controller.getAvailableDaysForTesting(3);
      expect(days, equals(['monday', 'wednesday', 'friday']));
    });

    test('Frekuensi 4 hari menghasilkan Monday, Wednesday, Friday, Sunday', () {
      final days = controller.getAvailableDaysForTesting(4);
      expect(days, equals(['monday', 'wednesday', 'friday', 'sunday']));
    });

    test('Frekuensi 5 hari menghasilkan Monday, Tuesday, Thursday, Saturday, Sunday', () {
      final days = controller.getAvailableDaysForTesting(5);
      expect(
        days,
        equals(['monday', 'tuesday', 'thursday', 'saturday', 'sunday']),
      );
    });

    test('Frekuensi 6 hari menghasilkan Monday, Tuesday, Wednesday, Friday, Saturday, Sunday', () {
      final days = controller.getAvailableDaysForTesting(6);
      expect(
        days,
        equals([
          'monday',
          'tuesday',
          'wednesday',
          'friday',
          'saturday',
          'sunday',
        ]),
      );
    });

    test('Frekuensi di luar 2-6 hari melempar ArgumentError', () {
      expect(
        () => controller.getAvailableDaysForTesting(1),
        throwsArgumentError,
      );
      expect(
        () => controller.getAvailableDaysForTesting(7),
        throwsArgumentError,
      );
    });
  });

  group(
    'ProfileController - Konsistensi 3 Properti Jadwal saat updateWorkoutPreferences',
    () {
      test(
        'Mengubah frekuensi ke 4 hari memperbarui preferredDaysPerWeek, weeklyFrequency, dan availableDays secara konsisten',
        () async {
          await controller.updateWorkoutPreferences(
            trainingDaysPerWeek: 4,
            workoutDurationMin: 50,
            trainingIntensity: 'high',
          );

          final saved = fakeRepository.lastSavedProfile;
          expect(saved, isNotNull);
          expect(saved!.preferredDaysPerWeek, equals(4));
          expect(saved.weeklyFrequency, equals(4));
          expect(
            saved.availableDays,
            equals(['monday', 'tuesday', 'thursday', 'friday']),
          );
          expect(saved.preferredDurationMin, equals(50));

          // Verifikasi state controller juga ter-update
          expect(controller.state.preferredDaysPerWeek, equals(4));
          expect(controller.state.preferredDurationMin, equals(50));
          expect(controller.state.trainingIntensity, equals('high'));
        },
      );

      test(
        'Mengubah frekuensi ke 5 hari memperbarui ketiga properti menjadi 5 hari',
        () async {
          await controller.updateWorkoutPreferences(
            trainingDaysPerWeek: 5,
            workoutDurationMin: 60,
            trainingIntensity: 'extreme',
          );

          final saved = fakeRepository.lastSavedProfile;
          expect(saved, isNotNull);
          expect(saved!.preferredDaysPerWeek, equals(5));
          expect(saved.weeklyFrequency, equals(5));
          expect(
            saved.availableDays,
            equals(['monday', 'tuesday', 'wednesday', 'thursday', 'friday']),
          );
        },
      );

      test(
        'Mengubah frekuensi ke 2 hari memperbarui ketiga properti menjadi 2 hari',
        () async {
          await controller.updateWorkoutPreferences(
            trainingDaysPerWeek: 2,
            workoutDurationMin: 30,
            trainingIntensity: 'low',
          );

          final saved = fakeRepository.lastSavedProfile;
          expect(saved, isNotNull);
          expect(saved!.preferredDaysPerWeek, equals(2));
          expect(saved.weeklyFrequency, equals(2));
          expect(saved.availableDays, equals(['tuesday', 'thursday']));
        },
      );
    },
  );
}
