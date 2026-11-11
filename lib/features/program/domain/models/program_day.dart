import 'package:flutter/foundation.dart';

import '../../../exercises/domain/models/exercise.dart';

enum WorkoutTypeCode {
  p,
  k,
  c,
  f,
  r;

  static WorkoutTypeCode fromString(String val) {
    switch (val.toUpperCase().trim()) {
      case 'P':
        return WorkoutTypeCode.p;
      case 'K':
        return WorkoutTypeCode.k;
      case 'C':
        return WorkoutTypeCode.c;
      case 'F':
        return WorkoutTypeCode.f;
      case 'R':
      default:
        return WorkoutTypeCode.r;
    }
  }

  String get code => name.toUpperCase();

  String localizedTitle(String langCode) {
    final isEn = langCode.toLowerCase().startsWith('en');
    switch (this) {
      case WorkoutTypeCode.p:
        return isEn ? 'Push' : 'Dorong';
      case WorkoutTypeCode.k:
        return isEn ? 'Legs' : 'Kaki';
      case WorkoutTypeCode.c:
        return isEn ? 'Core' : 'Core';
      case WorkoutTypeCode.f:
        return isEn ? 'Full Body' : 'Full Body';
      case WorkoutTypeCode.r:
        return isEn ? 'Rest' : 'Istirahat';
    }
  }
}

@immutable
class WorkoutItem {
  final String exerciseId;
  final int sets;
  final int? reps;
  final int? durationSec;
  final int restSeconds;
  final bool isMain;
  final String? stage; // 'warmup', 'main', 'cooldown'

  const WorkoutItem({
    required this.exerciseId,
    required this.sets,
    this.reps,
    this.durationSec,
    this.restSeconds = 60,
    this.isMain = false,
    this.stage,
  });

  bool get isDurationBased =>
      durationSec != null && (reps == null || reps == 0);

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    return WorkoutItem(
      exerciseId: json['exercise_id'] as String,
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as int?,
      durationSec: json['duration_sec'] as int?,
      restSeconds: json['rest_seconds'] as int? ?? 60,
      isMain: json['is_main'] as bool? ?? false,
      stage: json['stage'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'exercise_id': exerciseId,
    'sets': sets,
    if (reps != null) 'reps': reps,
    if (durationSec != null) 'duration_sec': durationSec,
    'rest_seconds': restSeconds,
    'is_main': isMain,
    if (stage != null) 'stage': stage,
  };

  WorkoutItem copyWith({
    String? exerciseId,
    int? sets,
    int? reps,
    int? durationSec,
    int? restSeconds,
    bool? isMain,
    String? stage,
  }) {
    return WorkoutItem(
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSec: durationSec ?? this.durationSec,
      restSeconds: restSeconds ?? this.restSeconds,
      isMain: isMain ?? this.isMain,
      stage: stage ?? this.stage,
    );
  }
}

@immutable
class ProgramDay {
  final int day;
  final int week;
  final WorkoutTypeCode type;
  final LocalizedString focus;
  final bool isRest;
  final bool isRetestMilestone;
  final List<WorkoutItem> items;
  final String? title;
  final String? thumbnailAsset;
  final int estimatedDurationMinutes;

  const ProgramDay({
    required this.day,
    required this.week,
    required this.type,
    required this.focus,
    required this.isRest,
    required this.isRetestMilestone,
    required this.items,
    this.title,
    this.thumbnailAsset,
    this.estimatedDurationMinutes = 30,
  });

  factory ProgramDay.fromJson(Map<String, dynamic> json) {
    final dayNum =
        (json['day_number'] as num?)?.toInt() ??
        (json['day'] as num?)?.toInt() ??
        1;
    final weekNum =
        (json['week_number'] as num?)?.toInt() ??
        (json['week'] as num?)?.toInt() ??
        (((dayNum - 1) ~/ 7) + 1);

    final rawType =
        json['type_code'] as String? ?? json['type'] as String? ?? 'R';

    LocalizedString parsedFocus;
    if (json['focus'] != null) {
      parsedFocus = LocalizedString.fromJson(json['focus']);
    } else {
      final enFocus = json['focus_en']?.toString();
      final idFocus = json['focus_id']?.toString();
      parsedFocus = LocalizedString(
        id: idFocus ?? enFocus ?? 'Latihan',
        en: enFocus ?? idFocus ?? 'Workout',
      );
    }

    final rawItems = json['program_day_exercises'] ?? json['items'];

    return ProgramDay(
      day: dayNum,
      week: weekNum,
      type: WorkoutTypeCode.fromString(rawType),
      focus: parsedFocus,
      isRest: json['is_rest'] as bool? ?? false,
      isRetestMilestone: json['is_retest_milestone'] as bool? ?? false,
      title: json['title'] as String?,
      thumbnailAsset: json['thumbnail_asset'] as String? ?? json['thumbnail'] as String?,
      estimatedDurationMinutes: (json['estimated_duration_minutes'] as num?)?.toInt() ?? 30,
      items:
          (rawItems as List?)
              ?.map(
                (e) =>
                    WorkoutItem.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'week': week,
    'type': type.code,
    'focus': {'id': focus.id, 'en': focus.en},
    'is_rest': isRest,
    'is_retest_milestone': isRetestMilestone,
    if (title != null) 'title': title,
    if (thumbnailAsset != null) 'thumbnail_asset': thumbnailAsset,
    'estimated_duration_minutes': estimatedDurationMinutes,
    'items': items.map((e) => e.toJson()).toList(),
  };

  ProgramDay copyWith({
    int? day,
    int? week,
    WorkoutTypeCode? type,
    LocalizedString? focus,
    bool? isRest,
    bool? isRetestMilestone,
    List<WorkoutItem>? items,
    String? title,
    String? thumbnailAsset,
    int? estimatedDurationMinutes,
  }) {
    return ProgramDay(
      day: day ?? this.day,
      week: week ?? this.week,
      type: type ?? this.type,
      focus: focus ?? this.focus,
      isRest: isRest ?? this.isRest,
      isRetestMilestone: isRetestMilestone ?? this.isRetestMilestone,
      items: items ?? this.items,
      title: title ?? this.title,
      thumbnailAsset: thumbnailAsset ?? this.thumbnailAsset,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    );
  }
}
