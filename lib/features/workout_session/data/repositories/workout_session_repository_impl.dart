import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../application/calorie_calculator_service.dart';
import '../../domain/models/workout_session_result.dart';
import '../../domain/repositories/workout_session_repository.dart';
import '../datasources/workout_session_supabase_datasource.dart';

/// Implementasi Repositori Sesi Latihan Offline-First (Data Layer)
class WorkoutSessionRepositoryImpl implements WorkoutSessionRepository {
  final AppDatabase localDatabase;
  final WorkoutSessionSupabaseDatasource remoteDatasource;
  final CalorieCalculatorService calorieCalculator;

  const WorkoutSessionRepositoryImpl({
    required this.localDatabase,
    this.remoteDatasource = const WorkoutSessionSupabaseDatasource(),
    this.calorieCalculator = const CalorieCalculatorService(),
  });

  @override
  Future<WorkoutSessionResult> completeWorkoutSession({
    required String programId,
    required int dayNumber,
    required String programTitle,
    required int durationSeconds,
    required int completedSets,
    required int totalExercises,
    required DateTime startedAt,
  }) async {
    final endedAt = DateTime.now();

    // 1. Ambil data berat badan user terkini untuk hitung kalori akurat
    final latestWeight = await localDatabase.getLatestWeight();
    final calories = calorieCalculator.calculateCaloriesBurned(
      durationSeconds: durationSeconds,
      completedSets: completedSets,
      userWeightKg: latestWeight,
    );

    // 2. Buat entity dan simpan ke SQLite lokal terlebih dahulu (Offline-First)
    final sessionEntity = WorkoutSessionEntity(
      id: 'session_${endedAt.millisecondsSinceEpoch}',
      programId: programId,
      programDayId: dayNumber,
      programTitle: programTitle,
      scheduledDate: startedAt,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      caloriesBurned: calories,
      status: WorkoutSessionStatus.completed,
    );

    await localDatabase.saveWorkoutSession(sessionEntity);

    // 3. Sinkronkan secara asinkron ke Supabase Cloud
    await remoteDatasource.syncCompletedSession(sessionEntity);

    return WorkoutSessionResult(
      sessionId: sessionEntity.id,
      programId: programId,
      dayNumber: dayNumber,
      programTitle: programTitle,
      durationSeconds: durationSeconds,
      caloriesBurned: calories,
      completedSets: completedSets,
      totalExercises: totalExercises,
      startedAt: startedAt,
      endedAt: endedAt,
    );
  }

  @override
  Future<WorkoutSessionEntity?> getActiveInProgressSession() async {
    return await localDatabase.getActiveSession();
  }
}

