import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';

/// Preskripsi latihan untuk SATU exercise (target set, rentang reps/durasi, rest).
///
/// Dibawa dari data program agar Active Workout tidak lagi memakai satu
/// konfigurasi global (3 set, 8–12 reps, 60s) untuk semua gerakan.
class WorkoutExercisePrescription {
  final int targetSets;
  final int minReps;
  final int maxReps;
  final int? targetDurationSeconds;
  final int restSeconds;
  final int? targetRir;

  const WorkoutExercisePrescription({
    this.targetSets = 3,
    this.minReps = 8,
    this.maxReps = 12,
    this.targetDurationSeconds,
    this.restSeconds = 60,
    this.targetRir,
  });

  /// Apakah latihan ini berbasis durasi waktu (misal plank)
  bool get isDuration =>
      targetDurationSeconds != null && targetDurationSeconds! > 0;

  /// Target efektif (durasi jika berbasis waktu, atau maxReps jika berbasis repetisi)
  int get effectiveTarget => targetDurationSeconds ?? maxReps;

  /// Preskripsi penuh dari tabel program_exercises.
  factory WorkoutExercisePrescription.fromProgramExercise(
    ProgramExerciseEntity entity, {
    TrackingType? trackingType,
  }) {
    final isDuration = trackingType == TrackingType.duration;
    return WorkoutExercisePrescription(
      targetSets: entity.targetSets,
      minReps: isDuration ? 0 : entity.minReps,
      maxReps: isDuration ? 0 : entity.maxReps,
      targetDurationSeconds: isDuration ? entity.maxReps : null,
      restSeconds: entity.restSeconds,
      targetRir: entity.targetRir,
    );
  }

  /// Fallback dari ProgramDay.items (tidak punya min/max terpisah, jadi
  /// min = max = reps).
  factory WorkoutExercisePrescription.fromWorkoutItem(
    WorkoutItem item, {
    TrackingType? trackingType,
  }) {
    final isDuration = trackingType == TrackingType.duration;
    final reps = item.reps;
    return WorkoutExercisePrescription(
      targetSets: item.sets > 0 ? item.sets : 3,
      minReps: isDuration ? 0 : (reps ?? 8),
      maxReps: isDuration ? 0 : (reps ?? 12),
      targetDurationSeconds: isDuration ? (reps ?? 30) : null,
      restSeconds: item.restSeconds,
    );
  }
}
