import 'package:workout_app/core/config/supabase_config.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/models/day_activity.dart';
import '../../domain/models/progress_metrics.dart';
import '../../domain/models/weight_record.dart';
import '../../domain/models/workout_history_item.dart';
import '../../domain/models/movement_volume_data.dart';
import '../../domain/models/progression_milestone.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_supabase_datasource.dart';

/// Implementasi ProgressRepository (Offline-First):
/// Membaca dari cache SQLite lokal terlebih dahulu untuk kecepatan render,
/// lalu memperbarui dengan sinkronisasi dari Supabase Cloud.
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressSupabaseDatasource remoteDatasource;
  final AppDatabase localDatabase;

  const ProgressRepositoryImpl({
    this.remoteDatasource = const ProgressSupabaseDatasource(),
    required this.localDatabase,
  });

  @override
  Future<ProgressMetrics> getMetrics() async {
    var workoutCount = 0;
    var caloriesBurned = 0;
    var streakDays = 0;
    var completedThisWeek = 0;
    var weeklyTarget = 0;
    var totalMinutes = 0;

    try {
      final completed = await localDatabase.getCompletedSessionsCount();
      final calories = await localDatabase.getTotalCaloriesBurned();
      final streak = await localDatabase.getCurrentStreak();
      final thisWeek = await localDatabase.getThisWeekCompletedCount();
      final profile = await localDatabase.getUserProfile();

      workoutCount = completed;
      caloriesBurned = calories;
      streakDays = streak;
      completedThisWeek = thisWeek;
      weeklyTarget = profile.weeklyFrequency;
      final sessions = await localDatabase.getRecentWorkoutSessions(
        limit: 10000,
      );
      totalMinutes =
          sessions
              .where((session) => session.status.name == 'completed')
              .fold<int>(0, (sum, session) => sum + session.durationSeconds) ~/
          60;
    } catch (_) {}

    return ProgressMetrics(
      workoutCount: workoutCount,
      caloriesBurned: caloriesBurned,
      totalMinutes: totalMinutes,
      streakDays: streakDays,
      completedThisWeek: completedThisWeek,
      weeklyTarget: weeklyTarget,
    );
  }

  @override
  Future<List<WeightRecord>> getWeightHistory() async {
    // 1. Jika Cloud Sync aktif, coba sinkronisasi dari remote
    if (SupabaseConfig.canSyncToCloud) {
      try {
        final remoteRecords = await remoteDatasource.fetchWeightHistory();
        if (remoteRecords.isNotEmpty) {
          return remoteRecords;
        }
      } catch (_) {}
    }

    // 2. Default Local-first: baca dari SQLite lokal
    try {
      final measurements = await localDatabase.getWeightHistory();
      if (measurements.isNotEmpty) {
        return measurements
            .map(
              (m) => WeightRecord(
                id: m.id,
                weightKg: m.value,
                recordedAt: m.recordedAt,
              ),
            )
            .toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<List<WorkoutHistoryItem>> getRecentWorkouts({int limit = 5}) async {
    try {
      final localSessions = await localDatabase.getRecentWorkoutSessions(
        limit: limit,
      );
      if (localSessions.isNotEmpty) {
        return localSessions.map((s) {
          final durMin = (s.durationSeconds / 60).round();
          final dateStr =
              '${s.startedAt.day}/${s.startedAt.month}/${s.startedAt.year}';
          return WorkoutHistoryItem(
            id: s.id,
            title: s.programTitle.isNotEmpty
                ? s.programTitle
                : 'Full Body Workout',
            dateText: dateStr,
            durationText: '$durMin min',
            caloriesText: '${s.caloriesBurned} kcal',
          );
        }).toList();
      }
    } catch (_) {}

    if (SupabaseConfig.canSyncToCloud) {
      try {
        final remoteItems = await remoteDatasource.fetchRecentWorkouts(
          limit: limit,
        );
        if (remoteItems.isNotEmpty) {
          return remoteItems;
        }
      } catch (_) {}
    }

    return [];
  }

  @override
  Future<List<DayActivity>> getWeeklyActivity() async {
    try {
      final localActivity = await localDatabase.getWeeklyActivityMinutes();
      final daysOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return daysOrder
          .map((day) => DayActivity(day: day, minutes: localActivity[day] ?? 0))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<MovementVolumeData>> getMovementVolume() async {
    try {
      final rows = await localDatabase.getWeeklyMovementVolume();
      return rows.map((r) => MovementVolumeData.fromMap(r)).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<ProgressionMilestone>> getProgressionMilestones({
    int limit = 5,
  }) async {
    try {
      final decisions = await localDatabase.getRecentProgressionMilestones(
        limit: limit,
      );
      return decisions.map((d) {
        String? nextExId;
        final nextMap = d.nextPrescriptionMap;
        if (nextMap != null && nextMap.containsKey('suggested_exercise_id')) {
          nextExId = nextMap['suggested_exercise_id'] as String?;
        }
        return ProgressionMilestone(
          exerciseId: d.exerciseId,
          decision: d.decision,
          reason: d.reason,
          date: d.createdAt,
          nextExerciseId: nextExId,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> recordWeight(double weightKg) async {
    // 1. Simpan ke database lokal SQLite
    await localDatabase.recordBodyWeight(weightKg);

    // 2. Sinkronkan ke Supabase
    try {
      await remoteDatasource.recordWeight(weightKg: weightKg);
    } catch (_) {}
  }
}
