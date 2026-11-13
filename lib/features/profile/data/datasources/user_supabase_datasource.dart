import 'package:flutter/foundation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/database/models/user_settings_entity.dart';

/// Datasource untuk sinkronisasi Profil Pengguna dengan Supabase (Cloud Sync):
/// Sesuai filosofi Local-First (Audit Remediasi P0):
/// - Hanya aktif jika pengguna telah login dengan akun Supabase Auth resmi.
/// - Tidak pernah mengirim data sebagai 'default_user'.
/// - Jika belum login, operasi dibatalkan secara aman dan data tetap 100% lokal di SQLite.
class UserSupabaseDatasource {
  const UserSupabaseDatasource();

  /// Mengambil data profil pengguna terbaru dari Supabase (jika Cloud Sync aktif)
  Future<UserProfileEntity?> fetchProfileFromSupabase({String? userId}) async {
    final client = SupabaseConfig.client;
    final uid = _authorizedUserId(userId);
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return null;
    }

    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response == null) return null;

      final map = Map<String, dynamic>.from(response);
      return UserProfileEntity.fromMap(map);
    } catch (e) {
      debugPrint('[Supabase] Error fetch user profile: $e');
      return null;
    }
  }

  /// Menyimpan atau memperbarui data profil pengguna ke Supabase
  Future<void> upsertProfileToSupabase(UserProfileEntity profile) async {
    final client = SupabaseConfig.client;
    final uid = SupabaseConfig.currentAuthUserId;
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return;
    }

    try {
      final payload = profile.toMap()
        ..['id'] = uid
        ..['user_id'] = uid
        // PostgREST jsonb columns must receive JSON arrays, not encoded strings.
        ..['available_days'] = profile.availableDays
        ..['training_limitations'] = profile.trainingLimitations
        ..['equipments'] = profile.equipments;
      await client.from('user_profiles').upsert(payload);
      debugPrint('[Supabase] Berhasil sync profil pengguna ke Supabase untuk user $uid!');
    } catch (e) {
      debugPrint('[Supabase] Gagal sync user profile: $e');
    }
  }

  /// Mengambil setelan pengguna (settings) dari Supabase
  Future<UserSettingsEntity?> fetchSettingsFromSupabase({String? settingsId}) async {
    final client = SupabaseConfig.client;
    final uid = _authorizedUserId(settingsId);
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return null;
    }

    try {
      final response = await client
          .from('user_settings')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response == null) return null;
      return UserSettingsEntity.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      debugPrint('[Supabase] Note: user_settings remote fetch: $e');
      return null;
    }
  }

  /// Menyimpan atau memperbarui setelan pengguna ke Supabase
  Future<void> upsertSettingsToSupabase(UserSettingsEntity settings) async {
    final client = SupabaseConfig.client;
    final uid = SupabaseConfig.currentAuthUserId;
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return;
    }

    try {
      final payload = settings.toMap()
        ..['id'] = uid
        ..['user_id'] = uid
        ..['workout_reminder'] = settings.workoutReminder
        ..['rest_day_reminder'] = settings.restDayReminder
        ..['progress_checkin'] = settings.progressCheckin
        ..['streak_reminder'] = settings.streakReminder
        ..['haptic_feedback'] = settings.hapticFeedback
        ..['sound_effects'] = settings.soundEffects
        ..['data_sync'] = settings.dataSync;
      await client.from('user_settings').upsert(payload);
      debugPrint('[Supabase] Berhasil sync user settings ke Supabase!');
    } catch (e) {
      debugPrint('[Supabase] Note: sync user settings ke Supabase: $e');
    }
  }

  /// Memperbarui nama lengkap di Supabase
  Future<void> updateDisplayName(String name, {String? userId}) async {
    final client = SupabaseConfig.client;
    final uid = _authorizedUserId(userId);
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return;
    }

    try {
      await client.from('user_profiles').update({
        'display_name': name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', uid);
      debugPrint('[Supabase] Berhasil update nama ke: $name');
    } catch (e) {
      debugPrint('[Supabase] Error update name: $e');
    }
  }

  /// Memperbarui berat dan tinggi badan di Supabase
  Future<void> updateBodyData({
    required double weightKg,
    required double heightCm,
    String? userId,
  }) async {
    final client = SupabaseConfig.client;
    final uid = _authorizedUserId(userId);
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return;
    }

    try {
      await client.from('user_profiles').update({
        'current_weight_kg': weightKg,
        'height_cm': heightCm,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', uid);
      debugPrint('[Supabase] Berhasil update data tubuh: $weightKg kg, $heightCm cm');
    } catch (e) {
      debugPrint('[Supabase] Error update body data: $e');
    }
  }

  /// Memperbarui program aktif pengguna di Supabase
  Future<void> updateActiveProgram(String programId, {String? userId}) async {
    final client = SupabaseConfig.client;
    final uid = _authorizedUserId(userId);
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return;
    }

    try {
      await client.from('user_profiles').update({
        'active_program_id': programId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', uid);
      debugPrint('[Supabase] Berhasil update active_program_id ke: $programId');
    } catch (e) {
      debugPrint('[Supabase] Error update active_program_id: $e');
    }
  }
}


String? _authorizedUserId(String? requestedUserId) {
  if (!SupabaseConfig.canSyncToCloud) return null;

  final authenticatedUserId = SupabaseConfig.currentAuthUserId;
  if (authenticatedUserId == null) return null;

  // Never allow a caller-supplied ID to read or mutate another user's row.
  if (requestedUserId != null && requestedUserId != authenticatedUserId) {
    return null;
  }

  return authenticatedUserId;
}
