import 'package:flutter/foundation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/database/models/workout_session_entity.dart';

/// Datasource remote Supabase untuk Workout Session (Data Layer)
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
}

