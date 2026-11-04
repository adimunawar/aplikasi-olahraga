/// Status Set Latihan (PRD Bagian 10.4 & 14)
enum WorkoutSetStatus {
  completed,
  skipped,
  failed;

  String toDbString() {
    switch (this) {
      case WorkoutSetStatus.completed:
        return 'completed';
      case WorkoutSetStatus.skipped:
        return 'skipped';
      case WorkoutSetStatus.failed:
        return 'failed';
    }
  }

  static WorkoutSetStatus fromDbString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'completed':
        return WorkoutSetStatus.completed;
      case 'skipped':
        return WorkoutSetStatus.skipped;
      case 'failed':
      default:
        return WorkoutSetStatus.failed;
    }
  }
}

/// Entity WorkoutSet untuk merekam detail repetisi dan beban aktual tiap set (WKO-03 & WKO-04)
class WorkoutSetEntity {
  final String id;
  final String sessionId;
  final String exerciseId;
  final int setNumber;
  final int? targetReps;
  final int? actualReps;
  final double? targetLoadKg;
  final double? actualLoadKg;
  final int? durationSeconds;
  final WorkoutSetStatus status;

  const WorkoutSetEntity({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    this.targetReps,
    this.actualReps,
    this.targetLoadKg,
    this.actualLoadKg,
    this.durationSeconds,
    this.status = WorkoutSetStatus.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'target_reps': targetReps,
      'actual_reps': actualReps,
      'target_load_kg': targetLoadKg,
      'actual_load_kg': actualLoadKg,
      'duration_seconds': durationSeconds,
      'status': status.toDbString(),
    };
  }

  factory WorkoutSetEntity.fromMap(Map<String, dynamic> map) {
    return WorkoutSetEntity(
      id: map['id']?.toString() ?? '',
      sessionId: map['session_id']?.toString() ?? '',
      exerciseId: map['exercise_id']?.toString() ?? '',
      setNumber: (map['set_number'] as num?)?.toInt() ?? 1,
      targetReps: (map['target_reps'] as num?)?.toInt(),
      actualReps: (map['actual_reps'] as num?)?.toInt(),
      targetLoadKg: (map['target_load_kg'] as num?)?.toDouble(),
      actualLoadKg: (map['actual_load_kg'] as num?)?.toDouble(),
      durationSeconds: (map['duration_seconds'] as num?)?.toInt(),
      status: WorkoutSetStatus.fromDbString(map['status']?.toString()),
    );
  }
}

