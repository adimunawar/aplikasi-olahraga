import '../../domain/models/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/exercise_local_datasource.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseLocalDatasource _datasource;

  ExerciseRepositoryImpl(this._datasource);

  @override
  Future<List<Exercise>> getExercises() async {
    return _datasource.loadExercises();
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    final list = await _datasource.loadExercises();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Exercise>> getExercisesByCategory(ExerciseCategory category) async {
    final list = await _datasource.loadExercises();
    return list.where((e) => e.category == category).toList();
  }
}

