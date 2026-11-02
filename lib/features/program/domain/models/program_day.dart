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

  const WorkoutItem({
    required this.exerciseId,
    required this.sets,
    this.reps,
    this.durationSec,
    this.restSeconds = 60,
    this.isMain = false,
  });

  bool get isDurationBased => durationSec != null && (reps == null || reps == 0);

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    return WorkoutItem(
      exerciseId: json['exercise_id'] as String,
      sets: json['sets'] as int? ?? 3,
      reps: json['reps'] as int?,
      durationSec: json['duration_sec'] as int?,
      restSeconds: json['rest_seconds'] as int? ?? 60,
      isMain: json['is_main'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'exercise_id': exerciseId,
        'sets': sets,
        if (reps != null) 'reps': reps,
        if (durationSec != null) 'duration_sec': durationSec,
        'rest_seconds': restSeconds,
        'is_main': isMain,
      };

  WorkoutItem copyWith({
    String? exerciseId,
    int? sets,
    int? reps,
    int? durationSec,
    int? restSeconds,
    bool? isMain,
  }) {
    return WorkoutItem(
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSec: durationSec ?? this.durationSec,
      restSeconds: restSeconds ?? this.restSeconds,
      isMain: isMain ?? this.isMain,
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

  const ProgramDay({
    required this.day,
    required this.week,
    required this.type,
    required this.focus,
    required this.isRest,
    required this.isRetestMilestone,
    required this.items,
  });

  factory ProgramDay.fromJson(Map<String, dynamic> json) {
    final dayNum = json['day'] as int;
    final weekNum = json['week'] as int? ?? (((dayNum - 1) ~/ 7) + 1);
    return ProgramDay(
      day: dayNum,
      week: weekNum,
      type: WorkoutTypeCode.fromString(json['type'] as String? ?? 'R'),
      focus: LocalizedString.fromJson(json['focus']),
      isRest: json['is_rest'] as bool? ?? false,
      isRetestMilestone: json['is_retest_milestone'] as bool? ?? false,
      items: (json['items'] as List?)
              ?.map((e) => WorkoutItem.fromJson(e as Map<String, dynamic>))
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
        'items': items.map((e) => e.toJson()).toList(),
      };
}

