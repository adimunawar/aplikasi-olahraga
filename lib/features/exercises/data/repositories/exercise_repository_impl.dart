import 'package:flutter/foundation.dart';

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
    // 1. Ambil data LANGSUNG dari Supabase Cloud
    try {
      debugPrint(
        '[ExerciseRepositoryImpl] 🚀 Memulai fetch langsung dari Supabase...',
      );
      final cloudEntities = await _remoteDatasource.fetchExercisesFromCloud();
      debugPrint(
        '[ExerciseRepositoryImpl] 📥 Total dari Supabase: ${cloudEntities.length} items',
      );

      if (cloudEntities.isNotEmpty) {
        // Filter khusus push-up untuk pengecekan data & log
        final pushUps = cloudEntities
            .where(
              (e) =>
                  e.id.toLowerCase().contains('push') ||
                  e.nameId.toLowerCase().contains('push') ||
                  e.nameEn.toLowerCase().contains('push'),
            )
            .toList();

        debugPrint('====================================================');
        debugPrint(
          '[ExerciseRepositoryImpl] 🔎 LOG KHUSUS PUSH-UP DARI SUPABASE:',
        );
        if (pushUps.isEmpty) {
          debugPrint('  ⚠️ Tidak ada item yang mengandung kata "push"');
        } else {
          for (final ex in pushUps) {
            debugPrint('  📌 ID           : "${ex.id}"');
            debugPrint('     Name         : "${ex.nameId}" / "${ex.nameEn}"');
            debugPrint('     thumbnail_url: "${ex.thumbnailUrl}"');
            debugPrint('     video_url    : "${ex.videoUrl}"');
            debugPrint('     startPose    : "${ex.startPoseAsset}"');
            debugPrint('     endPose      : "${ex.endPoseAsset}"');
            debugPrint('     trackingType : "${ex.trackingType}"');
          }
        }
        debugPrint('====================================================');

        await _datasource.saveExercisesFromCloud(cloudEntities);
        return cloudEntities.map((e) => e.toDomain()).toList();
      }
    } catch (e, stack) {
      debugPrint(
        '[ExerciseRepositoryImpl] ❌ Error saat fetch Supabase: $e\n$stack',
      );
    }

    // 2. Fallback ke SQLite lokal hanya jika Supabase gagal/offline
    debugPrint(
      '[ExerciseRepositoryImpl] ⚠️ Memakai fallback data SQLite lokal.',
    );
    return _datasource.loadExercises();
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
  Future<List<Exercise>> getExercisesByCategory(
    ExerciseCategory category,
  ) async {
    final list = await getExercises();
    return list.where((e) => e.category == category).toList();
  }
}
