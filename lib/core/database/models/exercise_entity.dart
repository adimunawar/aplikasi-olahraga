import 'dart:convert';

import '../../../features/exercises/domain/models/exercise.dart';

/// Entity Database untuk Tabel 'exercises' (SQLite & Supabase)
/// Single Source of Truth untuk katalog latihan & pemanasan (Offline-First)
class ExerciseEntity {
  final String id;
  final String nameId;
  final String nameEn;
  final String category;
  final String stage; // 'warmup', 'main', 'cooldown'
  final String difficulty;
  final String trackingType; // 'reps' atau 'duration'
  final String primaryMusclesJson;
  final String stabilizerMusclesJson;
  final String stepsIdJson;
  final String stepsEnJson;
  final String? commonMistakesIdJson;
  final String? commonMistakesEnJson;
  final String? breathingTipsId;
  final String? breathingTipsEn;
  final String? startPoseAsset;
  final String? endPoseAsset;
  final String? animationAsset;
  final String? videoUrl;
  final bool isCustom;
  final bool isFavorite;
  final String? createdByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExerciseEntity({
    required this.id,
    required this.nameId,
    required this.nameEn,
    required this.category,
    this.stage = 'main',
    this.difficulty = 'intermediate',
    this.trackingType = 'reps',
    required this.primaryMusclesJson,
    required this.stabilizerMusclesJson,
    required this.stepsIdJson,
    required this.stepsEnJson,
    this.commonMistakesIdJson,
    this.commonMistakesEnJson,
    this.breathingTipsId,
    this.breathingTipsEn,
    this.startPoseAsset,
    this.endPoseAsset,
    this.animationAsset,
    this.videoUrl,
    this.isCustom = false,
    this.isFavorite = false,
    this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_id': nameId,
      'name_en': nameEn,
      'category': category,
      'stage': stage,
      'difficulty': difficulty,
      'tracking_type': trackingType,
      'primary_muscles': primaryMusclesJson,
      'stabilizer_muscles': stabilizerMusclesJson,
      'steps_id': stepsIdJson,
      'steps_en': stepsEnJson,
      'common_mistakes_id': commonMistakesIdJson,
      'common_mistakes_en': commonMistakesEnJson,
      'breathing_tips_id': breathingTipsId,
      'breathing_tips_en': breathingTipsEn,
      'start_pose_asset': startPoseAsset,
      'end_pose_asset': endPoseAsset,
      'animation_asset': animationAsset,
      'video_url': videoUrl,
      'is_custom': isCustom ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'created_by_user_id': createdByUserId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ExerciseEntity.fromMap(Map<String, dynamic> map) {
    return ExerciseEntity(
      id: map['id'] as String,
      nameId: map['name_id'] as String? ?? '',
      nameEn: map['name_en'] as String? ?? '',
      category: map['category'] as String? ?? 'push',
      stage: map['stage'] as String? ?? 'main',
      difficulty: map['difficulty'] as String? ?? 'intermediate',
      trackingType: map['tracking_type'] as String? ?? 'reps',
      primaryMusclesJson: map['primary_muscles'] as String? ?? '[]',
      stabilizerMusclesJson: map['stabilizer_muscles'] as String? ?? '[]',
      stepsIdJson: map['steps_id'] as String? ?? '[]',
      stepsEnJson: map['steps_en'] as String? ?? '[]',
      commonMistakesIdJson: map['common_mistakes_id'] as String?,
      commonMistakesEnJson: map['common_mistakes_en'] as String?,
      breathingTipsId: map['breathing_tips_id'] as String?,
      breathingTipsEn: map['breathing_tips_en'] as String?,
      startPoseAsset: map['start_pose_asset'] as String?,
      endPoseAsset: map['end_pose_asset'] as String?,
      animationAsset: map['animation_asset'] as String?,
      videoUrl: map['video_url'] as String?,
      isCustom: (map['is_custom'] as int? ?? 0) == 1,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdByUserId: map['created_by_user_id'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Konversi dari Domain Exercise (JSON) ke Database Entity
  factory ExerciseEntity.fromDomain(Exercise exercise, {DateTime? now}) {
    final timestamp = now ?? DateTime.now();

    // Deteksi stage pemanasan secara otomatis jika kategori warmup
    String detectedStage = 'main';
    if (exercise.category == ExerciseCategory.warmup || exercise.id.toLowerCase().contains('warmup')) {
      detectedStage = 'warmup';
    }

    return ExerciseEntity(
      id: exercise.id,
      nameId: exercise.name.id,
      nameEn: exercise.name.en,
      category: exercise.category.name,
      stage: detectedStage,
      difficulty: exercise.difficulty.name,
      trackingType: exercise.trackingType.name,
      primaryMusclesJson: jsonEncode(exercise.primaryMuscles.map((m) => m.toJson()).toList()),
      stabilizerMusclesJson: jsonEncode(exercise.stabilizerMuscles.map((m) => m.toJson()).toList()),
      stepsIdJson: jsonEncode(exercise.steps.id),
      stepsEnJson: jsonEncode(exercise.steps.en),
      commonMistakesIdJson: jsonEncode(exercise.commonMistakes.id),
      commonMistakesEnJson: jsonEncode(exercise.commonMistakes.en),
      breathingTipsId: exercise.breathing.id,
      breathingTipsEn: exercise.breathing.en,
      startPoseAsset: exercise.media.startPose,
      endPoseAsset: exercise.media.endPose,
      animationAsset: 'assets/images/exercises/${exercise.id}.webp',
      isCustom: false,
      isFavorite: false,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  /// Konversi ke Domain Exercise Model yang dikonsumsi oleh UI
  Exercise toDomain() {
    List<LocalizedString> parsedPrimary = [];
    try {
      final decoded = jsonDecode(primaryMusclesJson);
      if (decoded is List) {
        parsedPrimary = decoded.map((e) => LocalizedString.fromJson(e)).toList();
      }
    } catch (_) {}

    List<LocalizedString> parsedStabilizer = [];
    try {
      final decoded = jsonDecode(stabilizerMusclesJson);
      if (decoded is List) {
        parsedStabilizer = decoded.map((e) => LocalizedString.fromJson(e)).toList();
      }
    } catch (_) {}

    List<String> parsedStepsId = [];
    try {
      final decoded = jsonDecode(stepsIdJson);
      if (decoded is List) parsedStepsId = decoded.map((e) => e.toString()).toList();
    } catch (_) {}

    List<String> parsedStepsEn = [];
    try {
      final decoded = jsonDecode(stepsEnJson);
      if (decoded is List) parsedStepsEn = decoded.map((e) => e.toString()).toList();
    } catch (_) {}

    List<String> parsedMistakesId = [];
    if (commonMistakesIdJson != null) {
      try {
        final decoded = jsonDecode(commonMistakesIdJson!);
        if (decoded is List) parsedMistakesId = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }

    List<String> parsedMistakesEn = [];
    if (commonMistakesEnJson != null) {
      try {
        final decoded = jsonDecode(commonMistakesEnJson!);
        if (decoded is List) parsedMistakesEn = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }

    return Exercise(
      id: id,
      name: LocalizedString(id: nameId, en: nameEn),
      category: ExerciseCategory.fromString(category),
      difficulty: ExerciseDifficulty.fromString(difficulty),
      trackingType: TrackingType.fromString(trackingType),
      primaryMuscles: parsedPrimary,
      stabilizerMuscles: parsedStabilizer,
      steps: LocalizedList(id: parsedStepsId, en: parsedStepsEn),
      commonMistakes: LocalizedList(id: parsedMistakesId, en: parsedMistakesEn),
      breathing: LocalizedString(id: breathingTipsId ?? '', en: breathingTipsEn ?? ''),
      variations: const ExerciseVariationGroup(),
      media: ExerciseMedia(
        startPose: startPoseAsset ?? '',
        endPose: endPoseAsset ?? '',
      ),
    );
  }
}

