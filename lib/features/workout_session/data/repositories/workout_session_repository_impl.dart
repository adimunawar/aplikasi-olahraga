import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/database/models/workout_set_entity.dart';
import '../../../../core/database/models/progression_decision_entity.dart';
import '../../../progression/domain/models/progression_models.dart';
import '../../../progression/domain/services/progression_engine.dart';
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
    List<WorkoutSetEntity> setLogs = const [],
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

    // 2b. Simpan set-by-set detail log (Fase 3: RIR & Performa Nyata)
    List<WorkoutSetEntity> formattedSetLogs = [];
    if (setLogs.isNotEmpty) {
      formattedSetLogs = setLogs.map((s) => WorkoutSetEntity(
        id: '${sessionEntity.id}_${s.exerciseId}_${s.setNumber}',
        sessionId: sessionEntity.id,
        exerciseId: s.exerciseId,
        setNumber: s.setNumber,
        targetReps: s.targetReps,
        actualReps: s.actualReps,
        targetLoadKg: s.targetLoadKg,
        actualLoadKg: s.actualLoadKg,
        durationSeconds: s.durationSeconds,
        rir: s.rir,
        isWarmup: s.isWarmup,
        formScore: s.formScore,
        dataSource: s.dataSource,
        status: s.status,
      )).toList();

      await localDatabase.saveWorkoutSets(formattedSetLogs);
    }

    // 2c. Evaluasi Progresi Otomatis oleh Otak Coach Adi (Fase 4: Progression Engine)
    final decisions = <ProgressionDecision>[];
    final savedDecisionEntities = <ProgressionDecisionEntity>[];
    if (setLogs.isNotEmpty) {
      const engine = ProgressionEngine();
      final setsByExercise = <String, List<WorkoutSetEntity>>{};
      for (final s in setLogs) {
        setsByExercise.putIfAbsent(s.exerciseId, () => []).add(s);
      }

      for (final entry in setsByExercise.entries) {
        final exerciseId = entry.key;
        final exSets = entry.value;

        final nextExId = await localDatabase.getNextExerciseInProgression(exerciseId);
        final prevExId = await localDatabase.getPreviousExerciseInProgression(exerciseId);

        final history = await localDatabase.getProgressionHistory(exerciseId, limit: 3);
        int consecutiveMax = 0;
        int underperforming = 0;
        for (final h in history) {
          if (h.decision == 'progress' || (h.decision == 'maintain' && h.reason.contains('target maksimal'))) {
            consecutiveMax++;
          } else if (h.decision == 'regress' || (h.decision == 'maintain' && h.reason.contains('menantang'))) {
            underperforming++;
          }
        }

        final firstSet = exSets.first;
        final targetSets = exSets.length;
        final targetReps = firstSet.targetReps ?? 10;
        final prescription = ExercisePrescription(
          targetSets: targetSets,
          minReps: (targetReps > 3) ? targetReps - 2 : targetReps,
          maxReps: targetReps + 2,
          targetRir: 2,
        );

        final performanceLogs = exSets.map((s) => SetPerformanceLog(
          setNumber: s.setNumber,
          reps: s.actualReps ?? 0,
          rir: s.rir,
          formScore: s.formScore,
          weightKg: s.actualLoadKg,
        )).toList();

        final input = ProgressionInput(
          exerciseId: exerciseId,
          prescription: prescription,
          completedSets: performanceLogs,
          consecutiveMaxRepsSessions: consecutiveMax,
          recentUnderperformingSessions: underperforming,
          nextExerciseId: nextExId,
          previousExerciseId: prevExId,
        );

        final decision = engine.evaluate(input);
        decisions.add(decision);

        final decisionEntity = ProgressionDecisionEntity(
          id: 'prog_${endedAt.millisecondsSinceEpoch}_$exerciseId',
          userId: 'default_user',
          exerciseId: exerciseId,
          decision: decision.action.name,
          previousPrescription: prescription.toJson(),
          nextPrescription: decision.nextPrescription.toJson(),
          reason: decision.reason,
          createdAt: endedAt,
        );
        await localDatabase.saveProgressionDecision(decisionEntity);
        savedDecisionEntities.add(decisionEntity);
      }
    }

    // 3. Sinkronkan secara asinkron ke Supabase Cloud (Dual Database Sync - Fase 5)
    await remoteDatasource.syncCompletedSession(sessionEntity);
    if (formattedSetLogs.isNotEmpty) {
      await remoteDatasource.syncCompletedSets(formattedSetLogs);
    }
    if (savedDecisionEntities.isNotEmpty) {
      await remoteDatasource.syncProgressionDecisions(savedDecisionEntities);
    }

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
      progressionDecisions: decisions,
    );
  }

  @override
  Future<WorkoutSessionEntity?> getActiveInProgressSession() async {
    return await localDatabase.getActiveSession();
  }
}

