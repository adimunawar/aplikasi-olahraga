import 'package:flutter/foundation.dart';

enum ExerciseCategory {
  push,
  legs,
  core,
  fullBody;

  static ExerciseCategory fromString(String val) {
    switch (val.toLowerCase()) {
      case 'push':
      case 'upper_body':
        return ExerciseCategory.push;
      case 'legs':
      case 'lower_body':
        return ExerciseCategory.legs;
      case 'core':
        return ExerciseCategory.core;
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
      case ExerciseCategory.legs:
        return isEn ? 'Legs' : 'Kaki';
      case ExerciseCategory.core:
        return isEn ? 'Core' : 'Core';
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
    return val.toLowerCase() == 'duration' || val.toLowerCase() == 'seconds'
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

  String get(String langCode) => langCode.toLowerCase().startsWith('en') ? en : id;
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
      final idList = (json['id'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final enList = (json['en'] as List?)?.map((e) => e.toString()).toList() ?? idList;
      return LocalizedList(id: idList, en: enList);
    }
    return const LocalizedList(id: [], en: []);
  }

  List<String> get(String langCode) =>
      langCode.toLowerCase().startsWith('en') ? en : id;
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
        easier: (json['easier'] as List?)?.map((e) => e.toString()).toList() ?? [],
        harder: (json['harder'] as List?)?.map((e) => e.toString()).toList() ?? [],
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

  const ExerciseMedia({
    required this.startPose,
    required this.endPose,
  });

  factory ExerciseMedia.fromJson(Map<String, dynamic>? json) {
    return ExerciseMedia(
      startPose: json?['start_pose']?.toString() ?? '',
      endPose: json?['end_pose']?.toString() ?? '',
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
  final List<LocalizedString> primaryMuscles;
  final List<LocalizedString> stabilizerMuscles;
  final LocalizedList steps;
  final LocalizedList commonMistakes;
  final LocalizedString breathing;
  final ExerciseVariationGroup variations;
  final ExerciseMedia media;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.trackingType,
    required this.primaryMuscles,
    required this.stabilizerMuscles,
    required this.steps,
    required this.commonMistakes,
    required this.breathing,
    required this.variations,
    required this.media,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: LocalizedString.fromJson(json['name']),
      category: ExerciseCategory.fromString(json['category'] as String? ?? ''),
      difficulty: ExerciseDifficulty.fromString(json['difficulty'] as String? ?? ''),
      trackingType: TrackingType.fromString(json['tracking_type'] as String? ?? 'reps'),
      primaryMuscles: (json['primary_muscles'] as List?)
              ?.map((e) => LocalizedString.fromJson(e))
              .toList() ??
          [],
      stabilizerMuscles: (json['stabilizer_muscles'] as List?)
              ?.map((e) => LocalizedString.fromJson(e))
              .toList() ??
          [],
      steps: LocalizedList.fromJson(json['steps']),
      commonMistakes: LocalizedList.fromJson(json['common_mistakes']),
      breathing: LocalizedString.fromJson(json['breathing']),
      variations: ExerciseVariationGroup.fromJson(json['variations']),
      media: ExerciseMedia.fromJson(json['media'] as Map<String, dynamic>?),
    );
  }
}

