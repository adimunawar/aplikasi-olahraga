import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../program/domain/models/program_day.dart';

/// Preskripsi latihan untuk SATU exercise (target set, rentang reps, rest).
///
/// Dibawa dari data program agar Active Workout tidak lagi memakai satu
/// konfigurasi global (3 set, 8–12 reps, 60s) untuk semua gerakan.
class WorkoutExercisePrescription {
  final int targetSets;
  final int minReps;
  final int maxReps;
  final int restSeconds;
  final int? targetRir;

  const WorkoutExercisePrescription({
    this.targetSets = 3,
    this.minReps = 8,
    this.maxReps = 12,
    this.restSeconds = 60,
    this.targetRir,
  });

  /// Preskripsi penuh dari tabel program_exercises.
  factory WorkoutExercisePrescription.fromProgramExercise(
    ProgramExerciseEntity entity,
  ) {
    return WorkoutExercisePrescription(
      targetSets: entity.targetSets,
      minReps: entity.minReps,
      maxReps: entity.maxReps,
      restSeconds: entity.restSeconds,
      targetRir: entity.targetRir,
    );
  }

  /// Fallback dari ProgramDay.items (tidak punya min/max terpisah, jadi
  /// min = max = reps).
  factory WorkoutExercisePrescription.fromWorkoutItem(WorkoutItem item) {
    final reps = item.reps;
    return WorkoutExercisePrescription(
      targetSets: item.sets > 0 ? item.sets : 3,
      minReps: reps ?? 8,
      maxReps: reps ?? 12,
      restSeconds: item.restSeconds,
    );
  }
}
