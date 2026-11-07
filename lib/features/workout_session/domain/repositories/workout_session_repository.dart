import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/database/models/workout_set_entity.dart';
import '../models/workout_session_result.dart';

/// Kontrak Repositori Sesi Latihan (Domain Layer)
abstract class WorkoutSessionRepository {
  /// Menyimpan sesi latihan yang telah selesai ke database lokal SQLite dan cloud Supabase
  Future<WorkoutSessionResult> completeWorkoutSession({
    required String programId,
    required int dayNumber,
    required String programTitle,
    required int durationSeconds,
    required int completedSets,
    required int totalExercises,
    required DateTime startedAt,
    List<WorkoutSetEntity> setLogs = const [],
  });

  /// Mengambil status crash recovery jika ada sesi yang belum selesai (WKO-10)
  Future<WorkoutSessionEntity?> getActiveInProgressSession();
}

