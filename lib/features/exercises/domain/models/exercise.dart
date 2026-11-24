import 'package:flutter/foundation.dart';
import '../../../../core/utils/media_url_resolver.dart';

import '../../../../core/utils/media_url_resolver.dart';

enum ExerciseCategory {
  push,
  pull,
  legs,
  core,
  fullBody,
  warmup,
  cooldown;

  static ExerciseCategory fromString(String val) {
    switch (val.toLowerCase()) {
      case 'push':
      case 'upper_body':
        return ExerciseCategory.push;
      case 'pull':
      case 'tarik':
        return ExerciseCategory.pull;
      case 'legs':
      case 'lower_body':
        return ExerciseCategory.legs;
      case 'core':
        return ExerciseCategory.core;
      case 'warmup':
      case 'warm_up':
      case 'pemanasan':
        return ExerciseCategory.warmup;
      case 'cooldown':
      case 'cool_down':
      case 'pendinginan':
        return ExerciseCategory.cooldown;
      case 'full_body':
      default:
        return ExerciseCategory.fullBody;
    }
  }

  String localizedName(String langCode) {
    final isEn = langCode.toLowerCase().startsWith('en');
    switch (this) {
      case ExerciseCategory.push:
        return isEn ? 'Push' : 'Dorong';
      case ExerciseCategory.pull:
        return isEn ? 'Pull' : 'Tarik';
      case ExerciseCategory.legs:
        return isEn ? 'Legs' : 'Kaki';
      case ExerciseCategory.core:
        return isEn ? 'Core' : 'Core';
      case ExerciseCategory.warmup:
        return isEn ? 'Warm-up' : 'Pemanasan';
      case ExerciseCategory.cooldown:
        return isEn ? 'Cool-down' : 'Pendinginan';
      case ExerciseCategory.fullBody:
        return isEn ? 'Full Body' : 'Seluruh Tubuh';
    }
  }
}

enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced;

  static ExerciseDifficulty fromString(String val) {
    switch (val.toLowerCase()) {
      case 'beginner':
        return ExerciseDifficulty.beginner;
      case 'advanced':
        return ExerciseDifficulty.advanced;
      case 'intermediate':
      default:
        return ExerciseDifficulty.intermediate;
    }
  }

  String localizedName(String langCode) {
    final isEn = langCode.toLowerCase().startsWith('en');
    switch (this) {
      case ExerciseDifficulty.beginner:
        return isEn ? 'Beginner' : 'Pemula';
      case ExerciseDifficulty.intermediate:
        return isEn ? 'Intermediate' : 'Menengah';
      case ExerciseDifficulty.advanced:
        return isEn ? 'Advanced' : 'Lanjut';
    }
  }
}

enum TrackingType {
  reps,
  duration;

  static TrackingType fromString(String val) {
    final lower = val.toLowerCase().trim();
    return lower == 'duration' ||
            lower == 'duration_sec' ||
            lower == 'duration_seconds' ||
            lower == 'seconds' ||
            lower == 'time'
        ? TrackingType.duration
        : TrackingType.reps;
  }
}

@immutable
class LocalizedString {
  final String id;
  final String en;

  const LocalizedString({required this.id, required this.en});

  factory LocalizedString.fromJson(dynamic json) {
    if (json is String) {
      return LocalizedString(id: json, en: json);
    }
    if (json is Map) {
      return LocalizedString(
        id: json['id']?.toString() ?? '',
        en: json['en']?.toString() ?? json['id']?.toString() ?? '',
      );
    }
    return const LocalizedString(id: '', en: '');
  }

  String get(String langCode) =>
      langCode.toLowerCase().startsWith('en') ? en : id;

  Map<String, dynamic> toJson() => {'id': id, 'en': en};
}

@immutable
class LocalizedList {
  final List<String> id;
  final List<String> en;

  const LocalizedList({required this.id, required this.en});

  factory LocalizedList.fromJson(dynamic json) {
    if (json is List) {
      final list = json.map((e) => e.toString()).toList();
      return LocalizedList(id: list, en: list);
    }
    if (json is Map) {
      final idList =
          (json['id'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final enList =
          (json['en'] as List?)?.map((e) => e.toString()).toList() ?? idList;
      return LocalizedList(id: idList, en: enList);
    }
    return const LocalizedList(id: [], en: []);
  }

  List<String> get(String langCode) =>
      langCode.toLowerCase().startsWith('en') ? en : id;

  Map<String, dynamic> toJson() => {'id': id, 'en': en};
}

@immutable
class ExerciseVariationGroup {
  final List<String> easier;
  final List<String> harder;

  const ExerciseVariationGroup({
    this.easier = const [],
    this.harder = const [],
  });

  factory ExerciseVariationGroup.fromJson(dynamic json) {
    if (json is Map) {
      return ExerciseVariationGroup(
        easier:
            (json['easier'] as List?)?.map((e) => e.toString()).toList() ?? [],
        harder:
            (json['harder'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
    }
    if (json is List) {
      return ExerciseVariationGroup(
        harder: json.map((e) => e.toString()).toList(),
      );
    }
    return const ExerciseVariationGroup();
  }
}

@immutable
class ExerciseMedia {
  final String startPose;
  final String endPose;
  final String? videoUrl;
  final String? thumbnailUrl;

  const ExerciseMedia({
    required this.startPose,
    required this.endPose,
    this.videoUrl,
    this.thumbnailUrl,
  });

  factory ExerciseMedia.fromJson(Map<String, dynamic>? json) {
    return ExerciseMedia(
      startPose:
          MediaUrlResolver.resolve(json?['start_pose']?.toString()) ?? '',
      endPose: MediaUrlResolver.resolve(json?['end_pose']?.toString()) ?? '',
      videoUrl: MediaUrlResolver.resolve(json?['video_url']?.toString()),
      thumbnailUrl: MediaUrlResolver.resolve(
        json?['thumbnail_url']?.toString(),
      ),
    );
  }
}

@immutable
class Exercise {
  final String id;
  final LocalizedString name;
  final ExerciseCategory category;
  final ExerciseDifficulty difficulty;
  final TrackingType trackingType;
  final String movementPattern;
  final List<String> equipments;
  final List<LocalizedString> primaryMuscles;
  final List<LocalizedString> stabilizerMuscles;
  final LocalizedList steps;
  final LocalizedList commonMistakes;
  final LocalizedString breathing;
  final ExerciseVariationGroup variations;
  final ExerciseMedia media;
  final String? videoUrl;
  final String? thumbnailUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.trackingType,
    this.movementPattern = 'other',
    this.equipments = const ['none'],
    required this.primaryMuscles,
    required this.stabilizerMuscles,
    required this.steps,
    required this.commonMistakes,
    required this.breathing,
    required this.variations,
    required this.media,
    this.videoUrl,
    this.thumbnailUrl,
  });

  /// URL video demonstrasi (di-resolve dari R2 ke Vercel proxy jika ada)
  String? get resolvedVideoUrl {
    final raw = videoUrl ?? media.videoUrl;
    if (raw == null || raw.trim().isEmpty) return null;
    return MediaUrlResolver.resolve(raw);
  }

  /// URL thumbnail (.webp / gambar) (di-resolve dari R2 ke Vercel proxy jika ada)
  String? get resolvedThumbnailUrl {
    final raw = thumbnailUrl ?? media.thumbnailUrl;
    if (raw == null || raw.trim().isEmpty) return null;
    return MediaUrlResolver.resolve(raw);
  }

  /// URL gambar poster (di-resolve dari R2 ke Vercel proxy jika ada)
  String get resolvedImageUrl {
    final thumb = resolvedThumbnailUrl;
    if (thumb != null && thumb.isNotEmpty) return thumb;

    if (media.startPose.isNotEmpty) {
      final resolved = MediaUrlResolver.resolve(media.startPose);
      if (resolved != null && resolved.isNotEmpty) return resolved;
    }
    return media.startPose;
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final rawEquipments = json['equipments'];
    List<String> parsedEquipments = ['none'];
    if (rawEquipments is List) {
      parsedEquipments = rawEquipments.map((e) => e.toString()).toList();
    }

    final parsedMedia = ExerciseMedia.fromJson(
      json['media'] as Map<String, dynamic>?,
    );
    final rawVideoUrl = json['video_url']?.toString() ?? parsedMedia.videoUrl;
    final videoUrl = MediaUrlResolver.resolve(rawVideoUrl);

    final rawThumbnailUrl =
        json['thumbnail_url']?.toString() ?? parsedMedia.thumbnailUrl;
    final thumbnailUrl = MediaUrlResolver.resolve(rawThumbnailUrl);

    return Exercise(
      id: json['id'] as String,
      name: LocalizedString.fromJson(json['name']),
      category: ExerciseCategory.fromString(json['category'] as String? ?? ''),
      difficulty: ExerciseDifficulty.fromString(
        json['difficulty'] as String? ?? '',
      ),
      trackingType: TrackingType.fromString(
        json['tracking_type'] as String? ?? 'reps',
      ),
      movementPattern: json['movement_pattern']?.toString() ?? 'other',
      equipments: parsedEquipments,
      primaryMuscles:
          (json['primary_muscles'] as List?)
              ?.map((e) => LocalizedString.fromJson(e))
              .toList() ??
          [],
      stabilizerMuscles:
          (json['stabilizer_muscles'] as List?)
              ?.map((e) => LocalizedString.fromJson(e))
              .toList() ??
          [],
      steps: LocalizedList.fromJson(json['steps']),
      commonMistakes: LocalizedList.fromJson(json['common_mistakes']),
      breathing: LocalizedString.fromJson(json['breathing']),
      variations: ExerciseVariationGroup.fromJson(json['variations']),
      media: ExerciseMedia(
        startPose: parsedMedia.startPose,
        endPose: parsedMedia.endPose,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      ),
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
    );
  }
}
