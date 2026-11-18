import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';
import '../models/exercise_prescription.dart';

/// Resolver preskripsi per exercise untuk Active Workout.
///
/// Urutan sumber (prioritas menurun):
/// 1. Preskripsi eksplisit dari args (paling akurat — berasal dari tabel
///    program_exercises, punya rentang min/max reps).
/// 2. Preskripsi dari [ProgramDay.items] (sets/reps/rest) + trackingType
///    exercise (reps vs duration).
/// 3. Default (3 set, 8–12 reps, 60 detik).
///
/// Kelas ini pure logic tanpa dependensi UI supaya mudah dites.
class WorkoutPrescriptionResolver {
  final ProgramDay day;
  final List<Exercise> exercises;

  /// Preskripsi eksplisit per exerciseId (dari program_exercises).
  final Map<String, WorkoutExercisePrescription> explicitPrescriptions;

  const WorkoutPrescriptionResolver({
    required this.day,
    required this.exercises,
    this.explicitPrescriptions = const {},
  });

  TrackingType _trackingFor(String exerciseId) =>
      exercises
          .where((exercise) => exercise.id == exerciseId)
          .firstOrNull
          ?.trackingType ??
      TrackingType.reps;

  /// Semua preskripsi sesi ini (dari items + overlay eksplisit).
  /// Dipakai controller untuk restore posisi & total set.
  Map<String, WorkoutExercisePrescription> buildAll() {
    final map = <String, WorkoutExercisePrescription>{
      for (final item in day.items)
        item.exerciseId: WorkoutExercisePrescription.fromWorkoutItem(
          item,
          trackingType: _trackingFor(item.exerciseId),
        ),
    };
    map.addAll(explicitPrescriptions);
    return Map.unmodifiable(map);
  }

  /// Preskripsi untuk satu exercise.
  WorkoutExercisePrescription forExercise(String exerciseId) {
    final explicit = explicitPrescriptions[exerciseId];
    if (explicit != null) return explicit;

    for (final item in day.items.where(
      (candidate) => candidate.exerciseId == exerciseId,
    )) {
      return WorkoutExercisePrescription.fromWorkoutItem(
        item,
        trackingType: _trackingFor(exerciseId),
      );
    }
    return const WorkoutExercisePrescription();
  }
}
