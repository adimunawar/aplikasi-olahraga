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
    bool isEndingEarly = false,
    Map<String, int>? targetSetsPerExercise,

    /// Jika diisi, record in_progress yang sudah ada di-update menjadi
    /// completed (bukan membuat record baru).
    String? sessionId,
  });

  /// Membuat sesi in_progress baru (WKO-10) agar latihan bisa dilanjutkan.
  Future<WorkoutSessionEntity> startWorkoutSession({
    required String programId,
    required int dayNumber,
    required String programTitle,
    required DateTime scheduledDate,
  });

  /// Menyimpan satu set yang sudah diselesaikan untuk pemulihan sesi.
  Future<void> saveSetLog(WorkoutSetEntity set);

  /// Menandai sesi in_progress sebagai abandoned.
  Future<void> abandonSession(String sessionId);

  /// Memperbarui akumulasi waktu aktif sesi secara berkala (elapsed aktif).
  Future<void> updateSessionProgress(
    String sessionId, {
    required int elapsedSeconds,
  });

  /// Semua set yang tercatat untuk sebuah sesi.
  Future<List<WorkoutSetEntity>> getSetsForSession(String sessionId);

  /// Mengambil status crash recovery jika ada sesi yang belum selesai (WKO-10)
  Future<WorkoutSessionEntity?> getActiveInProgressSession();
}
