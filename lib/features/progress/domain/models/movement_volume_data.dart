/// Data volume latihan per movement pattern (Fase 5: Biomechanical Volume Matrix)
class MovementVolumeData {
  final String pattern; // 'push', 'pull', 'squat', 'hinge', 'core', 'other'
  final int totalSets;
  final int totalReps;

  const MovementVolumeData({
    required this.pattern,
    required this.totalSets,
    required this.totalReps,
  });

  String get labelId {
    switch (pattern.toLowerCase().trim()) {
      case 'push':
        return 'Push (Dada & Bahu)';
      case 'pull':
        return 'Pull (Punggung & Biceps)';
      case 'squat':
        return 'Squat (Paha Depan)';
      case 'hinge':
        return 'Hinge (Paha Belakang & Glutes)';
      case 'core':
        return 'Core (Perut & Pinggang)';
      default:
        return 'Lainnya';
    }
  }

  factory MovementVolumeData.fromMap(Map<String, dynamic> map) {
    return MovementVolumeData(
      pattern: map['movement_pattern']?.toString() ?? 'other',
      totalSets: (map['sets_count'] as num?)?.toInt() ?? 0,
      totalReps: (map['reps_sum'] as num?)?.toInt() ?? 0,
    );
  }
}

