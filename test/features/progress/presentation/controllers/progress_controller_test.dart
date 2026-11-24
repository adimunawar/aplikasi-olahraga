import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/app_database.dart';
import 'package:workout_app/core/database/models/dynamic_program_entity.dart';
import 'package:workout_app/core/database/models/user_profile_entity.dart';
import 'package:workout_app/features/progress/application/bmi_calculator_service.dart';
import 'package:workout_app/features/progress/application/weight_analytics_service.dart';
import 'package:workout_app/features/progress/domain/models/day_activity.dart';
import 'package:workout_app/features/progress/domain/models/movement_volume_data.dart';
import 'package:workout_app/features/progress/domain/models/progress_metrics.dart';
import 'package:workout_app/features/progress/domain/models/progression_milestone.dart';
import 'package:workout_app/features/progress/domain/models/weight_record.dart';
import 'package:workout_app/features/progress/domain/models/workout_history_item.dart';
import 'package:workout_app/features/progress/domain/repositories/progress_repository.dart';
import 'package:workout_app/features/progress/presentation/controllers/progress_controller.dart';

class FakeProgressRepo extends Fake implements ProgressRepository {
  ProgressMetrics metrics = const ProgressMetrics(
    workoutCount: 8,
    caloriesBurned: 1600,
    totalMinutes: 180,
    streakDays: 4,
    completedThisWeek: 3,
    weeklyTarget: 4,
  );

  List<WeightRecord> weightRecords = [
    WeightRecord(id: 'w1', weightKg: 70.0, recordedAt: DateTime(2026, 3, 1)),
    WeightRecord(id: 'w2', weightKg: 71.0, recordedAt: DateTime(2026, 3, 15)),
  ];

  List<WorkoutHistoryItem> recentWorkouts = [
    const WorkoutHistoryItem(
      id: 'h1',
      title: 'Full Body Push',
      dateText: 'Yesterday',
      durationText: '35 min',
      caloriesText: '250 kcal',
    ),
  ];

  double? recordedWeight;
  bool shouldThrow = false;

  @override
  Future<ProgressMetrics> getMetrics() async {
    if (shouldThrow) throw Exception('Network error');
    return metrics;
  }

  @override
  Future<List<WeightRecord>> getWeightHistory() async => weightRecords;

  @override
  Future<List<WorkoutHistoryItem>> getRecentWorkouts({int limit = 5}) async =>
      recentWorkouts;

  @override
  Future<List<DayActivity>> getWeeklyActivity() async => [
    const DayActivity(day: 'Mon', minutes: 35),
  ];

  @override
  Future<List<MovementVolumeData>> getMovementVolume() async => const [];

  @override
  Future<List<ProgressionMilestone>> getProgressionMilestones({
    int limit = 5,
  }) async => const [];

  @override
  Future<void> recordWeight(double weightKg) async {
    if (shouldThrow) throw Exception('Write error');
    recordedWeight = weightKg;
    weightRecords.add(
      WeightRecord(id: 'w_new', weightKg: weightKg, recordedAt: DateTime.now()),
    );
  }
}

class FakeDbForController extends Fake implements AppDatabase {
  UserProfileEntity profile = UserProfileEntity(
    id: 'u1',
    displayName: 'Athlete',
    age: 26,
    heightCm: 175,
    currentWeightKg: 70,
    weeklyFrequency: 4,
    equipments: const [],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  TrainingProgramEntity? program = TrainingProgramEntity(
    id: 'p1',
    userId: 'u1',
    name: 'Strength Foundation',
    status: 'active',
    startDate: DateTime(2026, 3, 1),
    endDate: DateTime(2026, 3, 1).add(const Duration(days: 56)),
    weeklyFrequency: 4,
    targetDurationMinutes: 45,
    createdAt: DateTime(2026, 3, 1),
    updatedAt: DateTime(2026, 3, 1),
  );

  @override
  Future<UserProfileEntity> getUserProfile() async => profile;

  @override
  Future<void> recordBodyWeight(double weightKg) async {}

  @override
  Future<TrainingProgramEntity?> getActiveTrainingProgram(
    String userId,
  ) async => program;
}

void main() {
  late FakeProgressRepo fakeRepo;
  late FakeDbForController fakeDb;
  late ProgressController controller;

  setUp(() {
    fakeRepo = FakeProgressRepo();
    fakeDb = FakeDbForController();
    controller = ProgressController(
      repository: fakeRepo,
      database: fakeDb,
      bmiCalculator: const BmiCalculatorService(),
      weightAnalytics: const WeightAnalyticsService(),
    );
  });

  group('ProgressController', () {
    test('initializes and automatically loads progress successfully', () async {
      // Tunggu loadProgress selesai
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = controller.state;
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.metrics.workoutCount, 8);
      expect(state.currentWeight, 71.0);
      expect(state.heightCm, 175.0);
      expect(state.bmiValue, greaterThan(20));
      expect(state.bmiStatus, 'Healthy');
      expect(state.hasActiveProgram, true);
      expect(state.activeProgramTitle, 'Strength Foundation');
      expect(state.recentWorkouts.length, 1);
    });

    test('recordWeight updates weight and triggers progress reload', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await controller.recordWeight(72.0);

      expect(fakeRepo.recordedWeight, 72.0);
      expect(controller.state.currentWeight, 72.0);
      expect(controller.state.errorMessage, isNull);
    });

    test(
      'loadProgress handles repository failure with user-safe error message',
      () async {
        fakeRepo.shouldThrow = true;

        await controller.loadProgress();

        expect(controller.state.isLoading, false);
        expect(controller.state.errorMessage, contains('Gagal memuat progres'));
      },
    );
  });
}
