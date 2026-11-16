import 'package:flutter/foundation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/exercise_entity.dart';
import '../../domain/models/exercise.dart';

/// Datasource lokal untuk katalog gerakan.
/// SQLite menjadi cache offline; pengisian awal katalog dilakukan melalui
/// ExerciseRepositoryImpl (Supabase terlebih dahulu), bukan dari asset JSON.
class ExerciseLocalDatasource {
  final AppDatabase _db;
  List<Exercise>? _cachedExercises;

  ExerciseLocalDatasource({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  Future<List<Exercise>> loadExercises() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    try {
      final entities = await _db.getAllExercises();
      _cachedExercises = entities.map((e) => e.toDomain()).toList();
      debugPrint(
        '[ExerciseLocalDatasource] Loaded ${_cachedExercises!.length} exercises from SQLite.',
      );
      return _cachedExercises!;
    } catch (e) {
      debugPrint('[ExerciseLocalDatasource] Failed to load SQLite catalog: $e');
      _cachedExercises = const [];
      return _cachedExercises!;
    }
  }

  /// Ambil latihan berdasarkan fase/stage (misal: 'warmup', 'main', 'cooldown')
  Future<List<Exercise>> getExercisesByStage(String stage) async {
    final all = await loadExercises();
    if (stage.toLowerCase() == 'warmup') {
      return all
          .where((e) =>
              e.category == ExerciseCategory.warmup ||
              e.id.toLowerCase().contains('warmup') ||
              e.name.id.toLowerCase().contains('pemanasan'))
          .toList();
    }
    return all.where((e) => e.category != ExerciseCategory.warmup).toList();
  }

  /// Menyimpan & memperbarui latihan dari cloud Supabase ke database lokal SQLite
  Future<void> saveExercisesFromCloud(List<ExerciseEntity> entities) async {
    if (entities.isEmpty) return;
    await _db.insertExercises(entities);
    _cachedExercises = entities.map((e) => e.toDomain()).toList();
  }

  /// Toggle status favorit
  Future<void> toggleFavorite(String exerciseId, bool isFavorite) async {
    await _db.toggleExerciseFavorite(exerciseId, isFavorite);
  }

}}
