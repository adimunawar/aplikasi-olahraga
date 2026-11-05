import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/database/models/user_settings_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_supabase_datasource.dart';

/// Implementasi UserProfileRepository (Offline-First):
/// Mengutamakan SQLite lokal, lalu memperbarui ke Supabase Cloud.
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserSupabaseDatasource remoteDatasource;
  final AppDatabase localDatabase;

  const UserProfileRepositoryImpl({
    this.remoteDatasource = const UserSupabaseDatasource(),
    required this.localDatabase,
  });

  @override
  Future<UserProfileEntity> getUserProfile() async {
    // 1. Coba ambil dari Supabase jika online
    try {
      final remote = await remoteDatasource.fetchProfileFromSupabase();
      if (remote != null) {
        await localDatabase.saveUserProfile(remote);
        return remote;
      }
    } catch (_) {}

    // 2. Fallback ke SQLite lokal
    return await localDatabase.getUserProfile();
  }

  @override
  Future<void> saveUserProfile(UserProfileEntity profile) async {
    // 1. Simpan ke SQLite lokal (Single Source of Truth)
    await localDatabase.saveUserProfile(profile);

    // 2. Sinkronkan ke Supabase Cloud di background
    try {
      await remoteDatasource.upsertProfileToSupabase(profile);
    } catch (_) {}
  }

  @override
  Future<void> updateDisplayName(String name) async {
    // Simpan ke SQLite
    await localDatabase.updateUserProfileDisplayName(name);

    // Sinkronkan ke Supabase
    try {
      await remoteDatasource.updateDisplayName(name);
    } catch (_) {}
  }

  @override
  Future<void> updateBodyData({
    required double weightKg,
    required double heightCm,
  }) async {
    // Simpan ke SQLite
    await localDatabase.recordBodyWeight(weightKg);
    final profile = await localDatabase.getUserProfile();
    final updated = profile.copyWith(
      currentWeightKg: weightKg,
      heightCm: heightCm,
      updatedAt: DateTime.now(),
    );
    await localDatabase.saveUserProfile(updated);

    // Sinkronkan ke Supabase
    try {
      await remoteDatasource.updateBodyData(
        weightKg: weightKg,
        heightCm: heightCm,
      );
    } catch (_) {}
  }

  @override
  Future<UserSettingsEntity> getUserSettings() async {
    // 1. Coba ambil dari Supabase jika online
    try {
      final remote = await remoteDatasource.fetchSettingsFromSupabase();
      if (remote != null) {
        await localDatabase.saveUserSettings(remote);
        return remote;
      }
    } catch (_) {}

    // 2. Fallback ke SQLite lokal
    return await localDatabase.getUserSettings();
  }

  @override
  Future<void> saveUserSettings(UserSettingsEntity settings) async {
    // 1. Simpan ke SQLite lokal
    await localDatabase.saveUserSettings(settings);

    // 2. Sinkronkan ke Supabase Cloud di background
    try {
      await remoteDatasource.upsertSettingsToSupabase(settings);
    } catch (_) {}
  }
}

