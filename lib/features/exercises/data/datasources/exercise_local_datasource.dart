import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/exercise_entity.dart';
import '../../domain/models/exercise.dart';

/// Datasource lokal untuk katalog gerakan.
/// - Membaca dari cache database lokal SQLite.
/// - Jika SQLite masih kosong (misal baru install), otomatis melakukan initial seeding
///   dari asset JSON bawaan (assets/data/exercises.json) agar library tidak pernah kosong.
/// - Menghandle penyimpanan data hasil sinkronisasi Supabase ke SQLite.
class ExerciseLocalDatasource {
  static const String _assetPath = 'assets/data/exercises.json';
  final AppDatabase _db;
  List<Exercise>? _cachedExercises;

  ExerciseLocalDatasource({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  Future<List<Exercise>> loadExercises() async {
    if (_cachedExercises != null && _cachedExercises!.isNotEmpty) {
      return _cachedExercises!;
    }

    try {
      final entities = await _db.getAllExercises();
      if (entities.isNotEmpty) {
        _cachedExercises = entities.map((e) => e.toDomain()).toList();
        debugPrint(
          '[ExerciseLocalDatasource] Loaded ${_cachedExercises!.length} exercises from SQLite.',
        );
        return _cachedExercises!;
      }

      // SQLite kosong: Lakukan initial seeding dari asset JSON bawaan
      debugPrint(
        '[ExerciseLocalDatasource] SQLite kosong, melakukan initial seeding dari $_assetPath...',
      );
      final initialExercises = await _loadFromJsonAsset();
      if (initialExercises.isNotEmpty) {
        final entitiesToInsert = initialExercises
            .map((e) => ExerciseEntity.fromDomain(e))
            .toList();
        await _db.insertExercises(entitiesToInsert);
        _cachedExercises = initialExercises;
        debugPrint(
          '[ExerciseLocalDatasource] Berhasil seeding ${_cachedExercises!.length} exercises ke SQLite.',
        );
        return _cachedExercises!;
      }

      _cachedExercises = const [];
      return _cachedExercises!;
    } catch (e) {
      debugPrint('[ExerciseLocalDatasource] Failed to load SQLite catalog: $e');
      final fallback = await _loadFromJsonAsset();
      _cachedExercises = fallback;
      return _cachedExercises!;
    }
  }

  /// Ambil latihan berdasarkan fase/stage (misal: 'warmup', 'main', 'cooldown')
  Future<List<Exercise>> getExercisesByStage(String stage) async {
    final all = await loadExercises();
    if (stage.toLowerCase() == 'warmup') {
      return all
          .where(
            (e) =>
                e.category == ExerciseCategory.warmup ||
                e.id.toLowerCase().contains('warmup') ||
                e.name.id.toLowerCase().contains('pemanasan'),
          )
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

  /// Helper untuk membaca file JSON bawaan
  Future<List<Exercise>> _loadFromJsonAsset() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ExerciseLocalDatasource] Gagal membaca asset JSON: $e');
      return const [];
    }
  }
}
