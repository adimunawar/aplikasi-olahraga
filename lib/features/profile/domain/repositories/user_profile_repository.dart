import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/database/models/user_settings_entity.dart';

/// Abstract contract untuk repositori profil pengguna (Offline-First SQLite + Cloud Supabase)
abstract class UserProfileRepository {
  Future<UserProfileEntity> getUserProfile();
  Future<void> saveUserProfile(UserProfileEntity profile);
  Future<void> updateDisplayName(String name);
  Future<void> updateBodyData({required double weightKg, required double heightCm});

  Future<UserSettingsEntity> getUserSettings();
  Future<void> saveUserSettings(UserSettingsEntity settings);
}

