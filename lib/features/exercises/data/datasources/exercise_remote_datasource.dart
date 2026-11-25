import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/database/models/exercise_entity.dart';
import 'exercise_local_datasource.dart';

/// Remote Datasource untuk Exercises (Supabase Cloud):
/// - Menghubungkan aplikasi ke tabel 'exercises' di Supabase
/// - Mengambil update katalog latihan terbaru dari Cloud
/// - Menyinkronkan data cloud ke SQLite lokal secara Offline-First
class ExerciseRemoteDatasource {
  const ExerciseRemoteDatasource();

  /// Mengambil semua latihan dari Supabase
  Future<List<ExerciseEntity>> fetchExercisesFromCloud() async {
    final client = SupabaseConfig.client;
    if (client == null) {
      debugPrint(
        '[ExerciseRemoteDatasource] ⚠️ SupabaseConfig.client bernilai NULL! (isInitialized = ${SupabaseConfig.isInitialized})',
      );
      return [];
    }

    try {
      final response = await client
          .from('exercises')
          .select()
          .order('id', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      debugPrint(
        '[ExerciseRemoteDatasource] ☁️ Berhasil fetch ${data.length} exercises dari Supabase Cloud.',
      );
      for (final item in data) {
        final m = Map<String, dynamic>.from(item as Map);
        final id = m['id']?.toString().toLowerCase() ?? '';
        final vUrl =
            m['video_url'] ??
            (m['media'] is Map ? m['media']['video_url'] : null);
        final tUrl =
            m['thumbnail_url'] ??
            (m['media'] is Map ? m['media']['thumbnail_url'] : null);

        if (id.contains('knee') || id.contains('push')) {
          debugPrint('  👉 [Supabase Cloud] Match found: id="${m['id']}"');
          debugPrint('     thumbnail_url: "$tUrl"');
          debugPrint('     video_url    : "$vUrl"');
          debugPrint('     media map    : "${m['media']}"');
        } else if (vUrl != null || tUrl != null) {
          debugPrint(
            '  👉 [Supabase Cloud] ${m['id']} media: video=$vUrl, thumb=$tUrl',
          );
        }
      }

      return data.map((json) {
        final map = Map<String, dynamic>.from(json);
        final vUrl =
            (map['video_url'] ??
                    (map['media'] is Map ? map['media']['video_url'] : null))
                ?.toString();
        final tUrl =
            (map['thumbnail_url'] ??
                    (map['media'] is Map
                        ? map['media']['thumbnail_url']
                        : null))
                ?.toString();
        return ExerciseEntity(
          id: map['id']?.toString() ?? '',
          nameId: map['name_id']?.toString() ?? '',
          nameEn: map['name_en']?.toString() ?? '',
          category: map['category']?.toString() ?? 'push',
          stage: map['stage']?.toString() ?? 'main',
          difficulty: map['difficulty']?.toString() ?? 'intermediate',
          trackingType: map['tracking_type']?.toString() ?? 'reps',
          movementPattern: map['movement_pattern']?.toString() ?? 'other',
          equipmentsJson: map['equipments'] is String
              ? map['equipments'] as String
              : jsonEncode(map['equipments'] ?? ['none']),
          primaryMusclesJson: map['primary_muscles'] is String
              ? map['primary_muscles'] as String
              : jsonEncode(map['primary_muscles'] ?? []),
          stabilizerMusclesJson: map['stabilizer_muscles'] is String
              ? map['stabilizer_muscles'] as String
              : jsonEncode(map['stabilizer_muscles'] ?? []),
          stepsIdJson: map['steps_id'] is String
              ? map['steps_id'] as String
              : jsonEncode(map['steps_id'] ?? []),
          stepsEnJson: map['steps_en'] is String
              ? map['steps_en'] as String
              : jsonEncode(map['steps_en'] ?? []),
          commonMistakesIdJson: map['common_mistakes_id'] != null
              ? (map['common_mistakes_id'] is String
                    ? map['common_mistakes_id'] as String
                    : jsonEncode(map['common_mistakes_id']))
              : null,
          commonMistakesEnJson: map['common_mistakes_en'] != null
              ? (map['common_mistakes_en'] is String
                    ? map['common_mistakes_en'] as String
                    : jsonEncode(map['common_mistakes_en']))
              : null,
          breathingTipsId: map['breathing_tips_id']?.toString(),
          breathingTipsEn: map['breathing_tips_en']?.toString(),
          startPoseAsset: map['start_pose_asset']?.toString(),
          endPoseAsset: map['end_pose_asset']?.toString(),
          animationAsset: map['animation_asset']?.toString(),
          videoUrl: vUrl,
          thumbnailUrl: tUrl,
          isCustom: map['is_custom'] == true || map['is_custom'] == 1,
          isFavorite: map['is_favorite'] == true || map['is_favorite'] == 1,
          createdByUserId: map['created_by_user_id']?.toString(),
          createdAt:
              DateTime.tryParse(map['created_at']?.toString() ?? '') ??
              DateTime.now(),
          updatedAt:
              DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
              DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint(
        '[ExerciseRemoteDatasource] Gagal fetch exercises dari Supabase: $e',
      );
      return [];
    }
  }

  /// Sinkronisasi data cloud ke SQLite lokal
  Future<bool> syncWithLocal(ExerciseLocalDatasource localDatasource) async {
    final cloudEntities = await fetchExercisesFromCloud();
    if (cloudEntities.isEmpty) return false;

    await localDatasource.saveExercisesFromCloud(cloudEntities);
    debugPrint(
      '[ExerciseRemoteDatasource] Berhasil sync ${cloudEntities.length} exercises dari Cloud ke SQLite.',
    );
    return true;
  }
}
