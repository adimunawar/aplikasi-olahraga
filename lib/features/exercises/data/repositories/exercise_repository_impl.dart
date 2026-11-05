import '../../domain/models/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/exercise_local_datasource.dart';
import '../datasources/exercise_remote_datasource.dart';

/// Repository Gerakan Latihan (Offline-First Architecture):
/// - Membaca seketika dari database SQLite lokal (zero latency)
/// - Menjalankan sinkronisasi background ke Supabase Cloud jika online
class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseLocalDatasource _datasource;
  final ExerciseRemoteDatasource _remoteDatasource;

  ExerciseRepositoryImpl(
    this._datasource, {
    ExerciseRemoteDatasource? remoteDatasource,
  }) : _remoteDatasource = remoteDatasource ?? const ExerciseRemoteDatasource();

  @override
  Future<List<Exercise>> getExercises() async {
    // 1. Ambil data langsung dari SQLite lokal (instan, 100% offline-first)
    final localList = await _datasource.loadExercises();

    // 2. Sinkronkan dengan Supabase di background tanpa memblokir UI
    _syncInBackground();

    return localList;
  }

  void _syncInBackground() {
    _remoteDatasource.syncWithLocal(_datasource).catchError((_) => false);
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    final list = await getExercises();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Exercise>> getExercisesByCategory(ExerciseCategory category) async {
    final list = await getExercises();
    return list.where((e) => e.category == category).toList();
  }
}
