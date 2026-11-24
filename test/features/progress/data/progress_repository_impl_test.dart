import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/app_database.dart';
import 'package:workout_app/core/database/models/body_measurement_entity.dart';
import 'package:workout_app/core/database/models/progression_decision_entity.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/core/database/models/workout_session_entity.dart';
import 'package:workout_app/features/progress/data/datasources/progress_supabase_datasource.dart';
import 'package:workout_app/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:workout_app/features/progress/domain/models/weight_record.dart';

class FakeAppDatabase extends Fake implements AppDatabase {
  int completedCount = 5;
  int calories = 1200;
  int streak = 4;
  int thisWeekCount = 3;
  double? recordedWeight;
  bool shouldThrow = false;

  List<BodyMeasurementEntity> weightHistory = [
    BodyMeasurementEntity(
      id: 'm1',
      value: 70.0,
      recordedAt: DateTime(2026, 3, 1),
    ),
    BodyMeasurementEntity(
      id: 'm2',
      value: 69.5,
      recordedAt: DateTime(2026, 3, 15),
    ),
  ];

  List<WorkoutSessionEntity> recentSessions = [
    WorkoutSessionEntity(
      id: 's1',
      programId: 'p1',
      programDayId: 1,
      programTitle: 'Morning Cardio',
      scheduledDate: DateTime(2026, 3, 20),
      startedAt: DateTime(2026, 3, 20, 8),
      endedAt: DateTime(2026, 3, 20, 8, 30),
      durationSeconds: 1800,
      caloriesBurned: 220,
      status: WorkoutSessionStatus.completed,
    ),
  ];

  @override
  Future<int> getCompletedSessionsCount() async {
    if (shouldThrow) throw Exception('Database error');
    return completedCount;
  }

  @override
  Future<int> getTotalCaloriesBurned() async => calories;

  @override
  Future<int> getCurrentStreak() async => streak;

  @override
  Future<int> getThisWeekCompletedCount() async => thisWeekCount;

  @override
  Future<UserProfileEntity> getUserProfile() async {
    return UserProfileEntity(
      id: 'u1',
      displayName: 'Test User',
      age: 25,
      heightCm: 175,
      currentWeightKg: 70,
      weeklyFrequency: 4,
      equipments: const [],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<List<WorkoutSessionEntity>> getRecentWorkoutSessions({
    int limit = 5,
  }) async {
    if (shouldThrow) throw Exception('Database error');
    return recentSessions;
  }

  @override
  Future<List<BodyMeasurementEntity>> getWeightHistory() async {
    if (shouldThrow) throw Exception('Database error');
    return weightHistory;
  }

  @override
  Future<Map<String, int>> getWeeklyActivityMinutes() async {
    if (shouldThrow) throw Exception('Database error');
    return {'Mon': 30, 'Wed': 45, 'Fri': 45};
  }

  @override
  Future<List<Map<String, dynamic>>> getWeeklyMovementVolume() async {
    if (shouldThrow) throw Exception('Database error');
    return [
      {'movement_pattern': 'push', 'total_sets': 8, 'total_reps': 80},
    ];
  }

  @override
  Future<List<ProgressionDecisionEntity>> getRecentProgressionMilestones({
    int limit = 5,
  }) async => [];

  @override
  Future<void> recordBodyWeight(double weightKg) async {
    recordedWeight = weightKg;
  }
}

class FakeProgressSupabaseDatasource extends Fake
    implements ProgressSupabaseDatasource {
  double? remoteRecordedWeight;
  List<WeightRecord> remoteWeightHistory = [];

  @override
  Future<List<WeightRecord>> fetchWeightHistory({String? userId}) async =>
      remoteWeightHistory;

  @override
  Future<void> recordWeight({required double weightKg, String? userId}) async {
    remoteRecordedWeight = weightKg;
  }
}

void main() {
  late FakeAppDatabase fakeDb;
  late FakeProgressSupabaseDatasource fakeRemote;
  late ProgressRepositoryImpl repository;

  setUp(() {
    fakeDb = FakeAppDatabase();
    fakeRemote = FakeProgressSupabaseDatasource();
    repository = ProgressRepositoryImpl(
      localDatabase: fakeDb,
      remoteDatasource: fakeRemote,
    );
  });

  group('ProgressRepositoryImpl (Without Mockito)', () {
    test('getMetrics reads and maps metrics from local database', () async {
      final metrics = await repository.getMetrics();

      expect(metrics.workoutCount, 5);
      expect(metrics.caloriesBurned, 1200);
      expect(metrics.streakDays, 4);
      expect(metrics.completedThisWeek, 3);
      expect(metrics.weeklyTarget, 4);
      expect(metrics.totalMinutes, 30);
    });

    test(
      'getWeightHistory reads local weight measurements correctly',
      () async {
        final history = await repository.getWeightHistory();

        expect(history.length, 2);
        expect(history.first.id, 'm1');
        expect(history.first.weightKg, 70.0);
        expect(history.last.weightKg, 69.5);
      },
    );

    test('getRecentWorkouts maps workout session entity correctly', () async {
      final workouts = await repository.getRecentWorkouts();

      expect(workouts.length, 1);
      expect(workouts.first.id, 's1');
      expect(workouts.first.title, 'Morning Cardio');
      expect(workouts.first.durationText, '30 min');
      expect(workouts.first.caloriesText, '220 kcal');
    });

    test('getWeeklyActivity returns 7 days of activity', () async {
      final activity = await repository.getWeeklyActivity();

      expect(activity.length, 7);
      expect(activity.firstWhere((a) => a.day == 'Mon').minutes, 30);
      expect(activity.firstWhere((a) => a.day == 'Tue').minutes, 0);
      expect(activity.firstWhere((a) => a.day == 'Wed').minutes, 45);
    });

    test('recordWeight persists weight to local database and remote', () async {
      await repository.recordWeight(72.5);

      expect(fakeDb.recordedWeight, 72.5);
      expect(fakeRemote.remoteRecordedWeight, 72.5);
    });

    test(
      'handles local database exceptions gracefully without crashing',
      () async {
        fakeDb.shouldThrow = true;

        final metrics = await repository.getMetrics();
        expect(metrics.workoutCount, 0);
        expect(metrics.totalMinutes, 0);

        final history = await repository.getWeightHistory();
        expect(history, isEmpty);

        final workouts = await repository.getRecentWorkouts();
        expect(workouts, isEmpty);

        final activity = await repository.getWeeklyActivity();
        expect(activity, isEmpty);
      },
    );
  });
}
