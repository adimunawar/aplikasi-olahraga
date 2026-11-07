/// Data pencapaian kenaikan tangga variasi latihan dari Coach Adi (Fase 5)
class ProgressionMilestone {
  final String exerciseId;
  final String decision; // 'progress', 'maintain', 'regress', 'recover'
  final String reason;
  final DateTime date;
  final String? nextExerciseId;

  const ProgressionMilestone({
    required this.exerciseId,
    required this.decision,
    required this.reason,
    required this.date,
    this.nextExerciseId,
  });

  String get exerciseNameFormatted {
    return exerciseId
        .split('_')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String? get nextExerciseNameFormatted {
    if (nextExerciseId == null) return null;
    return nextExerciseId!
        .split('_')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}

