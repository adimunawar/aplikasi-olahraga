/// Status Sesi Latihan sesuai PRD Bagian 10.4, 10.5, & 14
enum WorkoutSessionStatus {
  inProgress,
  completed,
  incomplete,
  abandoned;

  String toDbString() {
    switch (this) {
      case WorkoutSessionStatus.inProgress:
        return 'in_progress';
      case WorkoutSessionStatus.completed:
        return 'completed';
      case WorkoutSessionStatus.incomplete:
        return 'incomplete';
      case WorkoutSessionStatus.abandoned:
        return 'abandoned';
    }
  }

  static WorkoutSessionStatus fromDbString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'in_progress':
        return WorkoutSessionStatus.inProgress;
      case 'completed':
        return WorkoutSessionStatus.completed;
      case 'incomplete':
        return WorkoutSessionStatus.incomplete;
      case 'abandoned':
      default:
        return WorkoutSessionStatus.abandoned;
    }
  }
}

/// Entity WorkoutSession untuk persistensi lokal dan pemulihan sesi aktif (WKO-10 & HIS-02)
class WorkoutSessionEntity {
  final String id;
  final String programId;
  final int programDayId;
  final String programTitle;
  final DateTime scheduledDate;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final WorkoutSessionStatus status;
  final String? notes;

  const WorkoutSessionEntity({
    required this.id,
    required this.programId,
    required this.programDayId,
    required this.programTitle,
    required this.scheduledDate,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'program_id': programId,
      'program_day_id': programDayId,
      'program_title': programTitle,
      'scheduled_date': scheduledDate.toIso8601String(),
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'status': status.toDbString(),
      'notes': notes,
    };
  }

  factory WorkoutSessionEntity.fromMap(Map<String, dynamic> map) {
    return WorkoutSessionEntity(
      id: map['id']?.toString() ?? '',
      programId: map['program_id']?.toString() ?? '',
      programDayId: (map['program_day_id'] as num?)?.toInt() ?? 1,
      programTitle: map['program_title']?.toString() ?? 'Latihan',
      scheduledDate: map['scheduled_date'] != null
          ? DateTime.tryParse(map['scheduled_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      startedAt: map['started_at'] != null
          ? DateTime.tryParse(map['started_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endedAt: map['ended_at'] != null
          ? DateTime.tryParse(map['ended_at'].toString())
          : null,
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
      status: WorkoutSessionStatus.fromDbString(map['status']?.toString()),
      notes: map['notes']?.toString(),
    );
  }

  WorkoutSessionEntity copyWith({
    DateTime? endedAt,
    int? durationSeconds,
    WorkoutSessionStatus? status,
    String? notes,
  }) {
    return WorkoutSessionEntity(
      id: id,
      programId: programId,
      programDayId: programDayId,
      programTitle: programTitle,
      scheduledDate: scheduledDate,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

