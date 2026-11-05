import 'package:flutter/foundation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/database/models/user_settings_entity.dart';

/// Datasource untuk sinkronisasi Profil Pengguna dengan Supabase:
/// Menghubungkan nama, berat badan, tinggi badan, target ke tabel `user_profiles` dan `user_settings`.
class UserSupabaseDatasource {
  const UserSupabaseDatasource();

  /// Mengambil data profil pengguna terbaru dari Supabase
  Future<UserProfileEntity?> fetchProfileFromSupabase({
    String userId = 'default_user',
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) return null;

    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      final map = Map<String, dynamic>.from(response);
      return UserProfileEntity(
        id: map['id']?.toString() ?? userId,
        displayName: map['display_name']?.toString() ?? 'Adi Munawar',
        age: (map['age'] as num?)?.toInt() ?? 24,
        heightCm: (map['height_cm'] as num?)?.toDouble() ?? 174.0,
        currentWeightKg: (map['current_weight_kg'] as num?)?.toDouble() ?? 58.0,
        goal: map['goal']?.toString() ?? 'muscle_gain',
        experienceLevel: map['experience_level']?.toString() ?? 'beginner',
        preferredDurationMin: (map['preferred_duration_min'] as num?)?.toInt() ?? 45,
        preferredDaysPerWeek: (map['preferred_days_per_week'] as num?)?.toInt() ?? 4,
        unitPreference: map['unit_preference']?.toString() ?? 'metric',
        equipments: const ['bodyweight', 'dumbbells', 'mat'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('[Supabase] Error fetch user profile: $e');
      return null;
    }
  }

  /// Menyimpan atau memperbarui data profil pengguna ke Supabase
  Future<void> upsertProfileToSupabase(UserProfileEntity profile) async {
    final client = SupabaseConfig.client;
    if (client == null) return;

    try {
      await client.from('user_profiles').upsert({
        'id': profile.id,
        'display_name': profile.displayName,
        'age': profile.age,
        'height_cm': profile.heightCm,
        'current_weight_kg': profile.currentWeightKg,
        'goal': profile.goal,
        'experience_level': profile.experienceLevel,
        'preferred_duration_min': profile.preferredDurationMin,
        'preferred_days_per_week': profile.preferredDaysPerWeek,
        'unit_preference': profile.unitPreference,
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('[Supabase] Berhasil sync profil pengguna ke Supabase!');
    } catch (e) {
      debugPrint('[Supabase] Gagal sync user profile: $e');
    }
  }

  /// Mengambil setelan pengguna (settings) dari Supabase
  Future<UserSettingsEntity?> fetchSettingsFromSupabase({
    String settingsId = 'default_settings',
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) return null;

    try {
      final response = await client
          .from('user_settings')
          .select()
          .eq('id', settingsId)
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
    if (client == null) return;

    try {
      await client.from('user_settings').upsert(settings.toMap());
      debugPrint('[Supabase] Berhasil sync user settings ke Supabase!');
    } catch (e) {
      debugPrint('[Supabase] Note: sync user settings ke Supabase: $e');
    }
  }

  /// Memperbarui nama lengkap di Supabase
  Future<void> updateDisplayName(String name, {String userId = 'default_user'}) async {
    final client = SupabaseConfig.client;
    if (client == null) return;

    try {
      await client.from('user_profiles').update({
        'display_name': name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      debugPrint('[Supabase] Berhasil update nama ke: $name');
    } catch (e) {
      debugPrint('[Supabase] Error update name: $e');
    }
  }

  /// Memperbarui berat dan tinggi badan di Supabase
  Future<void> updateBodyData({
    required double weightKg,
    required double heightCm,
    String userId = 'default_user',
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) return;

    try {
      await client.from('user_profiles').update({
        'current_weight_kg': weightKg,
        'height_cm': heightCm,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      debugPrint('[Supabase] Berhasil update data tubuh: $weightKg kg, $heightCm cm');
    } catch (e) {
      debugPrint('[Supabase] Error update body data: $e');
    }
  }

  /// Memperbarui program aktif pengguna di Supabase
  Future<void> updateActiveProgram(
    String programId, {
    String userId = 'default_user',
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) return;

    try {
      await client.from('user_profiles').update({
        'active_program_id': programId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      debugPrint('[Supabase] Berhasil update active_program_id ke: $programId');
    } catch (e) {
      debugPrint('[Supabase] Error update active_program_id: $e');
    }
  }
}

