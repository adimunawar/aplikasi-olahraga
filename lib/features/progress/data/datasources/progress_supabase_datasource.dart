import 'package:flutter/foundation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/models/day_activity.dart';
import '../../domain/models/progress_metrics.dart';
import '../../domain/models/weight_record.dart';
import '../../domain/models/workout_history_item.dart';

/// Datasource remote untuk integrasi tabel Supabase (Cloud Sync):
/// Sesuai filosofi Local-First (Audit Remediasi P0):
/// - Hanya aktif jika pengguna telah login dengan akun Supabase Auth resmi.
/// - Tidak pernah mengambil atau mengirim data sebagai 'default_user'.
/// - Jika belum login, seluruh kalkulasi progress menggunakan 100% SQLite lokal.
class ProgressSupabaseDatasource {
  const ProgressSupabaseDatasource();

  /// Mengambil metrik teratas dari Supabase (jika Cloud Sync aktif)
  Future<ProgressMetrics> fetchTopMetrics({String? userId}) async {
    final client = SupabaseConfig.client;
    final uid = userId ?? SupabaseConfig.currentAuthUserId;
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return const ProgressMetrics();
    }

    try {
      final response = await client
          .from('workout_sessions')
          .select()
          .eq('user_id', uid)
          .eq('status', 'completed');

      final List<dynamic> list = response as List<dynamic>;
      if (list.isEmpty) return const ProgressMetrics();

      final workoutCount = list.length;
      int totalSeconds = 0;
      int totalCalories = 0;

      for (final item in list) {
        final map = Map<String, dynamic>.from(item);
        final dur = (map['duration_seconds'] as num?)?.toInt() ?? 0;
        final cal = (map['calories_burned'] as num?)?.toInt() ?? 0;
        totalSeconds += dur;
        totalCalories += cal;
      }

      final totalMinutes = totalSeconds > 0 ? (totalSeconds / 60).round() : workoutCount * 25;
      if (totalCalories == 0) totalCalories = workoutCount * 254;

      int streak = 0;
      try {
        final profileRes = await client
            .from('user_profiles')
            .select('streak_days')
            .eq('id', uid)
            .maybeSingle();
        if (profileRes != null && profileRes['streak_days'] != null) {
          streak = (profileRes['streak_days'] as num).toInt();
        }
      } catch (_) {}

      return ProgressMetrics(
        workoutCount: workoutCount,
        caloriesBurned: totalCalories,
        totalMinutes: totalMinutes,
        streakDays: streak,
        completedThisWeek: 0,
        weeklyTarget: 4,
      );
    } catch (e) {
      debugPrint('[Supabase] Error fetchTopMetrics: $e');
      return const ProgressMetrics();
    }
  }

  /// Mengambil riwayat berat badan dari `body_measurements`
  Future<List<WeightRecord>> fetchWeightHistory({String? userId}) async {
    final client = SupabaseConfig.client;
    final uid = userId ?? SupabaseConfig.currentAuthUserId;
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return [];
    }

    try {
      final response = await client
          .from('body_measurements')
          .select()
          .eq('user_id', uid)
          .eq('measurement_type', 'weight')
          .order('recorded_at', ascending: true);

      final List<dynamic> list = response as List<dynamic>;
      return list.map((item) {
        final map = Map<String, dynamic>.from(item);
        final val = (map['value'] as num?)?.toDouble() ?? 58.0;
        final date = DateTime.tryParse(map['recorded_at']?.toString() ?? '') ?? DateTime.now();
        return WeightRecord(
          id: map['id']?.toString() ?? '',
          weightKg: val,
          recordedAt: date,
        );
      }).toList();
    } catch (e) {
      debugPrint('[Supabase] Error fetchWeightHistory: $e');
      return [];
    }
  }

  /// Mengambil riwayat latihan terbaru dari `workout_sessions`
  Future<List<WorkoutHistoryItem>> fetchRecentWorkouts({
    String? userId,
    int limit = 5,
  }) async {
    final client = SupabaseConfig.client;
    final uid = userId ?? SupabaseConfig.currentAuthUserId;
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return [];
    }

    try {
      final response = await client
          .from('workout_sessions')
          .select()
          .eq('user_id', uid)
          .eq('status', 'completed')
          .order('started_at', ascending: false)
          .limit(limit);

      final List<dynamic> list = response as List<dynamic>;
      if (list.isEmpty) return [];

      return list.map((item) {
        final map = Map<String, dynamic>.from(item);
        final title = map['program_title']?.toString() ?? 'Upper Body Workout';
        final durSeconds = (map['duration_seconds'] as num?)?.toInt() ?? 2400;
        final minutes = (durSeconds / 60).round();
        final cals = (map['calories_burned'] as num?)?.toInt() ?? 320;
        final startedAtStr = map['started_at']?.toString() ?? '';
        final date = DateTime.tryParse(startedAtStr) ?? DateTime.now();

        return WorkoutHistoryItem(
          id: map['id']?.toString() ?? '',
          title: title,
          dateText: _formatShortDate(date),
          durationText: '$minutes minutes',
          caloriesText: '$cals kcal',
          thumbnailAsset: title.toLowerCase().contains('leg')
              ? 'assets/images/coach_flex.png'
              : 'assets/images/Home Workout Push-Up Guide.png',
        );
      }).toList();
    } catch (e) {
      debugPrint('[Supabase] Error fetchRecentWorkouts: $e');
      return [];
    }
  }

  /// Mengambil aktivitas mingguan (Mon - Sun)
  Future<List<DayActivity>> fetchWeeklyActivity({String? userId}) async {
    final client = SupabaseConfig.client;
    final uid = userId ?? SupabaseConfig.currentAuthUserId;
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return [];
    }

    try {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final mondayStart = DateTime(monday.year, monday.month, monday.day).toIso8601String();

      final response = await client
          .from('workout_sessions')
          .select()
          .eq('user_id', uid)
          .eq('status', 'completed')
          .gte('started_at', mondayStart);

      final List<dynamic> list = response as List<dynamic>;
      if (list.isEmpty) return [];

      final dayMinutes = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
      for (final item in list) {
        final map = Map<String, dynamic>.from(item);
        final startedAtStr = map['started_at']?.toString() ?? '';
        final date = DateTime.tryParse(startedAtStr);
        if (date != null) {
          final durSec = (map['duration_seconds'] as num?)?.toInt() ?? 0;
          final mins = (durSec / 60).round();
          dayMinutes[date.weekday] = (dayMinutes[date.weekday] ?? 0) + mins;
        }
      }

      final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return List.generate(7, (index) {
        final weekday = index + 1;
        return DayActivity(day: dayLabels[index], minutes: dayMinutes[weekday] ?? 0);
      });
    } catch (e) {
      debugPrint('[Supabase] Error fetchWeeklyActivity: $e');
      return [];
    }
  }

  /// Menambahkan pengukuran berat badan baru ke cloud
  Future<void> recordWeight({
    required double weightKg,
    String? userId,
  }) async {
    final client = SupabaseConfig.client;
    final uid = userId ?? SupabaseConfig.currentAuthUserId;
    if (client == null || uid == null || !SupabaseConfig.canSyncToCloud) {
      return;
    }

    try {
      final now = DateTime.now();
      await client.from('body_measurements').insert({
        'id': 'bm_${now.millisecondsSinceEpoch}',
        'user_id': uid,
        'measurement_type': 'weight',
        'value': weightKg,
        'unit': 'kg',
        'recorded_at': now.toIso8601String(),
      });

      await client.from('user_profiles').update({
        'current_weight_kg': weightKg,
        'updated_at': now.toIso8601String(),
      }).eq('id', uid);

      debugPrint('[Supabase] Berhasil catat berat badan: $weightKg kg untuk user $uid');
    } catch (e) {
      debugPrint('[Supabase] Gagal catat berat badan: $e');
    }
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
