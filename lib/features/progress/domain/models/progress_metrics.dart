/// Immutable Domain Model untuk ringkasan metrik progres latihan
class ProgressMetrics {
  final int workoutCount;
  final int caloriesBurned;
  final int totalMinutes;
  final int streakDays;
  final int completedThisWeek;
  final int weeklyTarget;

  const ProgressMetrics({
    this.workoutCount = 10,
    this.caloriesBurned = 2540,
    this.totalMinutes = 250,
    this.streakDays = 3,
    this.completedThisWeek = 3,
    this.weeklyTarget = 4,
  });

  ProgressMetrics copyWith({
    int? workoutCount,
    int? caloriesBurned,
    int? totalMinutes,
    int? streakDays,
    int? completedThisWeek,
    int? weeklyTarget,
  }) {
    return ProgressMetrics(
      workoutCount: workoutCount ?? this.workoutCount,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      streakDays: streakDays ?? this.streakDays,
      completedThisWeek: completedThisWeek ?? this.completedThisWeek,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
    );
  }
}

