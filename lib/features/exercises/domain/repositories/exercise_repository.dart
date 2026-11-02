import '../models/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> getExercises();
  Future<Exercise?> getExerciseById(String id);
  Future<List<Exercise>> getExercisesByCategory(ExerciseCategory category);
}

