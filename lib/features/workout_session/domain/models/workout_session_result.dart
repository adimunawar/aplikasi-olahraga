import 'package:flutter/foundation.dart';

/// Model hasil akhir sesi latihan (Domain Layer murni & immutable)
@immutable
class WorkoutSessionResult {
  final String sessionId;
  final String programId;
  final int dayNumber;
  final String programTitle;
  final int durationSeconds;
  final int caloriesBurned;
  final int completedSets;
  final int totalExercises;
  final DateTime startedAt;
  final DateTime endedAt;

  const WorkoutSessionResult({
    required this.sessionId,
    required this.programId,
    required this.dayNumber,
    required this.programTitle,
    required this.durationSeconds,
    required this.caloriesBurned,
    required this.completedSets,
    required this.totalExercises,
    required this.startedAt,
    required this.endedAt,
  });

  int get durationMinutes => (durationSeconds / 60).round();
}

