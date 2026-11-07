import 'package:flutter/foundation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/database/models/workout_set_entity.dart';
import '../../../../core/database/models/progression_decision_entity.dart';

/// Datasource remote Supabase untuk Workout Session & Analytics (Fase 5: Dual Database Sync)
class WorkoutSessionSupabaseDatasource {
  const WorkoutSessionSupabaseDatasource();

  /// Mengirim data sesi latihan yang telah selesai ke tabel 'workout_sessions' di Supabase
  Future<void> syncCompletedSession(WorkoutSessionEntity session) async {
    final client = SupabaseConfig.client;
    if (client == null) return;

    try {
      await client.from('workout_sessions').insert({
        'id': session.id,
        'user_id': 'default_user',
        'program_id': session.programId,
        'program_day_id': session.programDayId,
        'program_title': session.programTitle,
        'scheduled_date': session.scheduledDate.toIso8601String(),
        'started_at': session.startedAt.toIso8601String(),
        'ended_at': session.endedAt?.toIso8601String(),
        'duration_seconds': session.durationSeconds,
        'calories_burned': session.caloriesBurned,
        'status': session.status.toDbString(),
        'notes': session.notes,
      });
      debugPrint('[Supabase] Berhasil sinkronisasi sesi latihan ${session.id}');
    } catch (e) {
      debugPrint('[Supabase] Gagal sinkronisasi sesi latihan ke cloud: $e (Aman tersimpan di lokal SQLite)');
    }
  }

  /// Mengirim data set individual ke tabel 'workout_sets' di Supabase
  Future<void> syncCompletedSets(List<WorkoutSetEntity> sets) async {
    final client = SupabaseConfig.client;
    if (client == null || sets.isEmpty) return;

    try {
      final payload = sets.map((s) => s.toMap()).toList();
      await client.from('workout_sets').upsert(payload);
      debugPrint('[Supabase] Berhasil sinkronisasi ${sets.length} sets ke cloud');
    } catch (e) {
      debugPrint('[Supabase] Gagal sinkronisasi workout_sets: $e');
    }
  }

  /// Mengirim audit log keputusan Coach Adi ke tabel 'progression_decisions' di Supabase
  Future<void> syncProgressionDecisions(List<ProgressionDecisionEntity> decisions) async {
    final client = SupabaseConfig.client;
    if (client == null || decisions.isEmpty) return;

    try {
      final payload = decisions.map((d) => d.toMap()).toList();
      await client.from('progression_decisions').upsert(payload);
      debugPrint('[Supabase] Berhasil sinkronisasi ${decisions.length} progression decisions ke cloud');
    } catch (e) {
      debugPrint('[Supabase] Gagal sinkronisasi progression_decisions: $e');
    }
  }
}

