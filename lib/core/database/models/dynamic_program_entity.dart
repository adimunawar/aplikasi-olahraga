import '../../../features/exercises/domain/models/exercise.dart';

/// Entity untuk Tabel 'training_programs'
class TrainingProgramEntity {
  final String id;
  final String userId;
  final String name;
  final String status; // 'active', 'completed', 'archived'
  final DateTime startDate;
  final DateTime? endDate;
  final int weeklyFrequency;
  final int targetDurationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrainingProgramEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.status = 'active',
    required this.startDate,
    this.endDate,
    this.weeklyFrequency = 3,
    this.targetDurationMinutes = 30,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Durasi program dalam minggu (default 4 minggu)
  int get durationWeeks {
    if (endDate != null) {
      final days = endDate!.difference(startDate).inDays;
      final weeks = (days / 7).round();
      return weeks > 0 ? weeks : 4;
    }
    return 4;
  }

  /// Convenience alias
  int get frequencyDaysPerWeek => weeklyFrequency;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'weekly_frequency': weeklyFrequency,
      'target_duration_minutes': targetDurationMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TrainingProgramEntity.fromMap(Map<String, dynamic> map) {
    return TrainingProgramEntity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      status: map['status'] as String? ?? 'active',
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      weeklyFrequency: (map['weekly_frequency'] as num?)?.toInt() ?? 3,
      targetDurationMinutes: (map['target_duration_minutes'] as num?)?.toInt() ?? 30,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

/// Entity untuk Tabel 'program_sessions'
class ProgramSessionEntity {
  final String id;
  final String programId;
  final int dayNumber; // 1, 2, ... N
  final String name; // e.g. 'Session A', 'Full Body 1'
  final int targetDurationMinutes;
  final String focusLabel; // e.g. 'Full Body', 'Push + Core'
  final DateTime createdAt;

  const ProgramSessionEntity({
    required this.id,
    required this.programId,
    required this.dayNumber,
    required this.name,
    this.targetDurationMinutes = 30,
    this.focusLabel = 'Full Body',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'program_id': programId,
      'day_number': dayNumber,
      'name': name,
      'target_duration_minutes': targetDurationMinutes,
      'focus_label': focusLabel,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ProgramSessionEntity.fromMap(Map<String, dynamic> map) {
    return ProgramSessionEntity(
      id: map['id'] as String,
      programId: map['program_id'] as String,
      dayNumber: (map['day_number'] as num?)?.toInt() ?? 1,
      name: map['name'] as String,
      targetDurationMinutes: (map['target_duration_minutes'] as num?)?.toInt() ?? 30,
      focusLabel: map['focus_label'] as String? ?? 'Full Body',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

/// Entity untuk Tabel 'program_exercises'
class ProgramExerciseEntity {
  final String id;
  final String programSessionId;
  final String exerciseId;
  final int sortOrder;
  final String stage; // 'warm_up', 'main', 'cool_down'
  final int targetSets;
  final int minReps;
  final int maxReps;
  final int? targetRir;
  final int restSeconds;

  const ProgramExerciseEntity({
    required this.id,
    required this.programSessionId,
    required this.exerciseId,
    required this.sortOrder,
    this.stage = 'main',
    this.targetSets = 3,
    this.minReps = 8,
    this.maxReps = 12,
    this.targetRir = 2,
    this.restSeconds = 60,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'program_session_id': programSessionId,
      'exercise_id': exerciseId,
      'sort_order': sortOrder,
      'stage': stage,
      'target_sets': targetSets,
      'min_reps': minReps,
      'max_reps': maxReps,
      'target_rir': targetRir,
      'rest_seconds': restSeconds,
    };
  }

  factory ProgramExerciseEntity.fromMap(Map<String, dynamic> map) {
    return ProgramExerciseEntity(
      id: map['id'] as String,
      programSessionId: map['program_session_id'] as String,
      exerciseId: map['exercise_id'] as String,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 1,
      stage: map['stage'] as String? ?? 'main',
      targetSets: (map['target_sets'] as num?)?.toInt() ?? 3,
      minReps: (map['min_reps'] as num?)?.toInt() ?? 8,
      maxReps: (map['max_reps'] as num?)?.toInt() ?? 12,
      targetRir: (map['target_rir'] as num?)?.toInt() ?? 2,
      restSeconds: (map['rest_seconds'] as num?)?.toInt() ?? 60,
    );
  }
}

/// DTO Lengkap: Sesi beserta daftar Latihan & detail gerakannya
class ProgramSessionDetail {
  final ProgramSessionEntity session;
  final List<ProgramExerciseDetailItem> exercises;

  const ProgramSessionDetail({
    required this.session,
    required this.exercises,
  });

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.prescription.targetSets);
}

class ProgramExerciseDetailItem {
  final ProgramExerciseEntity prescription;
  final Exercise exercise;

  const ProgramExerciseDetailItem({
    required this.prescription,
    required this.exercise,
  });
}

