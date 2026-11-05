import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/exercise_entity.dart';
import '../../domain/models/exercise.dart';

/// Datasource Offline-First untuk Gerakan Latihan (Exercises)
/// - Membaca langsung dari SQLite Database lokal
/// - Melakukan initial seeding otomatis dari exercises.json jika tabel kosong
/// - Mendukung filter per stage ('warmup', 'main', 'cooldown') dan pencarian
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
      // 1. Cek jumlah data di SQLite
      final count = await _db.getExerciseCount();

      if (count > 0) {
        // Ambil data langsung dari SQLite
        final entities = await _db.getAllExercises();
        _cachedExercises = entities.map((e) => e.toDomain()).toList();
        return _cachedExercises!;
      }

      // 2. Jika tabel masih kosong (first install): Lakukan Seeding dari exercises.json
      final initialExercises = await _loadFromJsonAsset();
      final entities = initialExercises.map((e) => ExerciseEntity.fromDomain(e)).toList();

      await _db.insertExercises(entities);
      _cachedExercises = initialExercises;
      return _cachedExercises!;
    } catch (_) {
      // Fallback aman jika database belum siap: baca langsung dari JSON
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

  /// Helper untuk membaca file JSON bawaan
  Future<List<Exercise>> _loadFromJsonAsset() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
