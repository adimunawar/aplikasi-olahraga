import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/app_database.dart';
import 'package:workout_app/core/database/models/workout_session_entity.dart';
import 'package:workout_app/core/database/models/workout_set_entity.dart';
import 'package:workout_app/features/plans/presentation/controllers/plans_controller.dart';
import 'package:workout_app/features/program/data/repositories/programs_repository_impl.dart';
import 'package:workout_app/features/profile/data/datasources/user_supabase_datasource.dart';
import 'package:workout_app/features/progress/application/bmi_calculator_service.dart';
import 'package:workout_app/features/progress/application/weight_analytics_service.dart';
import 'package:workout_app/features/progress/data/datasources/progress_supabase_datasource.dart';
import 'package:workout_app/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:workout_app/features/progress/presentation/controllers/progress_controller.dart';
import 'package:workout_app/features/workout_session/domain/models/exercise_prescription.dart';
import 'package:workout_app/features/workout_session/domain/models/workout_session_result.dart';
import 'package:workout_app/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:workout_app/features/workout_session/presentation/controllers/workout_session_controller.dart';
import 'package:workout_app/features/workout_session/presentation/controllers/workout_session_state.dart';

/// Stub supaya test tidak menyentuh database/remote asli saat controller
/// me-refresh Plans & Progress setelah sesi selesai.
class _StubPlansController extends PlansController {
  _StubPlansController()
    : super(
        programsRepo: ProgramsRepositoryImpl(database: AppDatabase.instance),
        userDatasource: const UserSupabaseDatasource(),
        database: AppDatabase.instance,
      );

  @override
  Future<void> loadPrograms() async {}
}

class _StubProgressController extends ProgressController {
  _StubProgressController()
    : super(
        repository: ProgressRepositoryImpl(
          remoteDatasource: const ProgressSupabaseDatasource(),
          localDatabase: AppDatabase.instance,
        ),
        bmiCalculator: const BmiCalculatorService(),
        weightAnalytics: const WeightAnalyticsService(),
        userDatasource: const UserSupabaseDatasource(),
        programsRepo: ProgramsRepositoryImpl(database: AppDatabase.instance),
      );

  @override
  Future<void> loadProgress() async {}
}

List<Override> _containerOverrides(_FakeWorkoutSessionRepository repository) {
  return [
    workoutSessionRepositoryProvider.overrideWithValue(repository),
    plansControllerProvider.overrideWith((ref) => _StubPlansController()),
    progressControllerProvider.overrideWith((ref) => _StubProgressController()),
  ];
}

class _FakeWorkoutSessionRepository implements WorkoutSessionRepository {
  WorkoutSessionEntity? active;
  final List<WorkoutSetEntity> savedSets = [];
  final List<String> abandonedIds = [];
  final Map<String, List<WorkoutSetEntity>> setsBySession = {};
  final List<WorkoutSessionResult> completedResults = [];
  final List<int> progressUpdates = [];

  /// Simulasi kegagalan database saat menyimpan set atau sesi.
  bool failSaveSet = false;
  bool failFinishSession = false;
  final List<String?> completionAttemptSessionIds = [];

  int _idCounter = 0;

  @override
  Future<WorkoutSessionEntity?> getActiveInProgressSession() async {
    final session = active;
    if (session == null) return null;
    return session.status == WorkoutSessionStatus.inProgress ? session : null;
  }

  @override
  Future<WorkoutSessionEntity> startWorkoutSession({
    required String programId,
    required int dayNumber,
    required String programTitle,
    required DateTime scheduledDate,
  }) async {
    final session = WorkoutSessionEntity(
      id: 'session_${++_idCounter}',
      programId: programId,
      programDayId: dayNumber,
      programTitle: programTitle,
      scheduledDate: scheduledDate,
      startedAt: DateTime.now(),
      status: WorkoutSessionStatus.inProgress,
    );
    active = session;
    return session;
  }

  @override
  Future<void> saveSetLog(WorkoutSetEntity set) async {
    if (failSaveSet) {
      throw Exception('database unavailable');
    }
    savedSets.add(set);
  }

  @override
  Future<void> abandonSession(String sessionId) async {
    abandonedIds.add(sessionId);
    if (active?.id == sessionId) {
      active = active!.copyWith(
        status: WorkoutSessionStatus.abandoned,
        endedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updateSessionProgress(
    String sessionId, {
    required int elapsedSeconds,
  }) async {
    progressUpdates.add(elapsedSeconds);
    if (active?.id == sessionId) {
      active = active!.copyWith(elapsedSeconds: elapsedSeconds);
    }
  }

  @override
  Future<List<WorkoutSetEntity>> getSetsForSession(String sessionId) async {
    return setsBySession[sessionId] ?? const [];
  }

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
    bool isEndingEarly = false,
    Map<String, int>? targetSetsPerExercise,
    String? sessionId,
  }) async {
    completionAttemptSessionIds.add(sessionId);
    if (failFinishSession) {
      throw StateError('simulated session persistence failure');
    }

    final result = WorkoutSessionResult(
      sessionId: sessionId ?? 'session_completed',
      programId: programId,
      dayNumber: dayNumber,
      programTitle: programTitle,
      durationSeconds: durationSeconds,
      caloriesBurned: 100,
      completedSets: completedSets,
      totalExercises: totalExercises,
      startedAt: startedAt,
      endedAt: DateTime.now(),
    );
    completedResults.add(result);
    return result;
  }
}

void main() {
  final today = DateTime(2026, 11, 15);

  WorkoutSetEntity completedSet(String exerciseId, int setNumber) {
    return WorkoutSetEntity(
      id: 's1_${exerciseId}_$setNumber',
      sessionId: 's1',
      exerciseId: exerciseId,
      setNumber: setNumber,
      actualReps: 10,
      rir: 2,
      status: WorkoutSetStatus.completed,
    );
  }

  group('WorkoutSessionController resume', () {
    late _FakeWorkoutSessionRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _FakeWorkoutSessionRepository();
      container = ProviderContainer(overrides: _containerOverrides(repository));
      // Jaga provider autoDispose tetap hidup selama test.
      container.listen(workoutSessionControllerProvider, (_, _) {});
    });

    tearDown(() => container.dispose());

    WorkoutSessionController controller() =>
        container.read(workoutSessionControllerProvider.notifier);

    test('starts a new in-progress session when none exists', () async {
      final result = await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a', 'b'],
      );

      expect(result, isA<SessionPrepared>());
      expect(controller().sessionId, isNotNull);
      expect(repository.active?.status, WorkoutSessionStatus.inProgress);
      expect(repository.active?.programDayId, 1);
      expect(repository.abandonedIds, isEmpty);
    });

    test('resumes a matching session and restores exercise position', () async {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 2));
      repository.active = WorkoutSessionEntity(
        id: 's1',
        programId: 'program_1',
        programDayId: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        startedAt: startedAt,
        elapsedSeconds: 120,
        status: WorkoutSessionStatus.inProgress,
      );
      repository.setsBySession['s1'] = [
        completedSet('a', 1),
        completedSet('a', 2),
        completedSet('a', 3),
        completedSet('b', 1),
      ];

      final result = await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a', 'b'],
      );

      final state = container.read(workoutSessionControllerProvider);
      expect(result, isA<SessionPrepared>());
      expect(controller().sessionId, 's1');
      expect(state.currentExerciseIndex, 1);
      expect(state.currentSet, 2);
      // Waktu aktif dipulihkan dari catatan tersimpan, bukan wall-clock.
      expect(state.elapsedWorkoutSeconds, 120);
      expect(state.completedSets, 4);
      expect(repository.abandonedIds, isEmpty);
    });

    test('persists every recorded set for later resume', () async {
      await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
      );
      final sessionId = controller().sessionId;

      await controller().recordSetPerformance(
        exerciseId: 'a',
        setNumber: 1,
        actualReps: 10,
        rir: 2,
      );

      expect(repository.savedSets, hasLength(1));
      expect(repository.savedSets.single.id, '${sessionId}_a_1');
      expect(repository.savedSets.single.sessionId, sessionId);
      expect(
        container.read(workoutSessionControllerProvider).completedSets,
        1,
      );
    });

    test('abandonActiveSession marks the running session as abandoned', () async {
      await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
      );
      final sessionId = controller().sessionId;

      await controller().abandonActiveSession();

      expect(repository.abandonedIds, contains(sessionId));
      expect(repository.active?.status, WorkoutSessionStatus.abandoned);
      expect(controller().sessionId, isNull);
    });
  });

  group('WorkoutSessionController conflict handling', () {
    late _FakeWorkoutSessionRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _FakeWorkoutSessionRepository();
      container = ProviderContainer(overrides: _containerOverrides(repository));
      container.listen(workoutSessionControllerProvider, (_, _) {});
    });

    tearDown(() => container.dispose());

    WorkoutSessionController controller() =>
        container.read(workoutSessionControllerProvider.notifier);

    WorkoutSessionEntity sessionFor({
      required String programId,
      required int dayNumber,
      DateTime? scheduledDate,
    }) {
      return WorkoutSessionEntity(
        id: 'session_conflict',
        programId: programId,
        programDayId: dayNumber,
        programTitle: 'Existing',
        scheduledDate: scheduledDate ?? today,
        startedAt: today,
        status: WorkoutSessionStatus.inProgress,
      );
    }

    test('P1: reports a conflict for another program on the same day & date', () async {
      // Program berbeda, Day 1, tanggal sama persis.
      repository.active = sessionFor(programId: 'program_old', dayNumber: 1);

      final result = await controller().prepareSession(
        programId: 'program_new',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
      );

      expect(result, isA<SessionConflict>());
      expect(
        (result as SessionConflict).existingProgramId,
        'program_old',
      );
      // Sesi lama TIDAK boleh di-abandon secara otomatis.
      expect(repository.abandonedIds, isEmpty);
      expect(repository.active?.status, WorkoutSessionStatus.inProgress);
    });

    test('P1: reports a conflict for another day of the same program', () async {
      repository.active = sessionFor(programId: 'program_1', dayNumber: 2);

      final result = await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 3,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
      );

      expect(result, isA<SessionConflict>());
      expect(repository.abandonedIds, isEmpty);
    });

    test('P1: resuming the conflicting session keeps it intact', () async {
      repository.active = sessionFor(programId: 'program_old', dayNumber: 1);

      await controller().resumeExistingSession(
        sessionId: 'session_conflict',
        exerciseIds: const ['a'],
      );

      expect(controller().sessionId, 'session_conflict');
      expect(repository.abandonedIds, isEmpty);
      expect(repository.active?.status, WorkoutSessionStatus.inProgress);
    });

    test('P1: discard option abandons the old session then starts a new one', () async {
      repository.active = sessionFor(programId: 'program_old', dayNumber: 1);

      final result = await controller().discardConflictingAndStart(
        conflictingSessionId: 'session_conflict',
        programId: 'program_new',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
      );

      expect(result, isA<SessionPrepared>());
      expect(repository.abandonedIds, contains('session_conflict'));
      expect(repository.active?.programId, 'program_new');
      expect(repository.active?.status, WorkoutSessionStatus.inProgress);
      expect(controller().sessionId, isNot('session_conflict'));
    });

    test('P1: recording a set before preparation finishes is ignored', () async {
      // Simulasi: user sempat menekan Complete Set sebelum prepareSession
      // selesai (sessionId belum ada). Tidak boleh ada set yatim.
      await controller().recordSetPerformance(
        exerciseId: 'a',
        setNumber: 1,
        actualReps: 10,
        rir: 2,
      );

      expect(repository.savedSets, isEmpty);
      expect(
        container.read(workoutSessionControllerProvider).completedSets,
        0,
      );

      // Setelah siap, pencatatan normal kembali bekerja.
      await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
      );
      await controller().recordSetPerformance(
        exerciseId: 'a',
        setNumber: 1,
        actualReps: 10,
        rir: 2,
      );

      expect(repository.savedSets, hasLength(1));
      expect(
        container.read(workoutSessionControllerProvider).completedSets,
        1,
      );
    });

    test('finish computes completed sets from actual logs, not position', () async {
      await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a', 'b'],
      );
      final controller0 = controller();
      // Exercise 1 tuntas (3 set), exercise 2 baru 1 set; posisi berada di
      // exercise 2 set 2 — rumus posisi lama akan menghasilkan 5.
      for (var i = 1; i <= 3; i++) {
        await controller0.recordSetPerformance(
          exerciseId: 'a',
          setNumber: i,
          actualReps: 10,
          rir: 2,
        );
      }
      await controller0.recordSetPerformance(
        exerciseId: 'b',
        setNumber: 1,
        actualReps: 8,
        rir: 3,
      );
      controller0.nextPressed(totalExercises: 2); // pindah ke set b/2

      final result = await controller0.finishWorkoutSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        totalExercises: 2,
      );

      expect(result?.completedSets, 4);
      expect(result?.progressionDecisions, isEmpty);
      // Tidak ada lagi baseline set palsu.
      expect(repository.completedResults.single.completedSets, 4);
      expect(
        container.read(workoutSessionControllerProvider).errorMessage,
        isNull,
      );
    });

    test(
      'failed session completion keeps the session and can be retried',
      () async {
        await controller().prepareSession(
          programId: 'program_1',
          dayNumber: 1,
          programTitle: 'Upper Body',
          scheduledDate: today,
          exerciseIds: const ['a'],
        );
        final controller0 = controller();
        final sessionId = controller0.sessionId;

        await controller0.recordSetPerformance(
          exerciseId: 'a',
          setNumber: 1,
          actualReps: 10,
          rir: 2,
        );

        repository.failFinishSession = true;
        final failedResult = await controller0.finishWorkoutSession(
          programId: 'program_1',
          dayNumber: 1,
          programTitle: 'Upper Body',
          totalExercises: 1,
        );

        final failedState = container.read(workoutSessionControllerProvider);
        expect(failedResult, isNull);
        expect(failedState.isSaving, isFalse);
        expect(failedState.completionError, isNotNull);
        expect(failedState.errorMessage, isNull);
        expect(failedState.completedResult, isNull);
        expect(failedState.completedSets, 1);
        expect(controller0.sessionId, sessionId);

        repository.failFinishSession = false;
        final retriedResult = await controller0.finishWorkoutSession(
          programId: 'program_1',
          dayNumber: 1,
          programTitle: 'Upper Body',
          totalExercises: 1,
        );

        final retriedState = container.read(workoutSessionControllerProvider);
        expect(retriedResult, isNotNull);
        expect(repository.completionAttemptSessionIds, [sessionId, sessionId]);
        expect(controller0.sessionId, isNull);
        expect(retriedState.completionError, isNull);
        expect(retriedState.completedResult, same(retriedResult));
        expect(retriedState.isSaving, isFalse);
      },
    );


    test('active phase does not consume the rest countdown', () async {
      await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
        prescriptions: const {
          'a': WorkoutExercisePrescription(restSeconds: 45),
        },
      );

      controller().tickTimer(totalExercises: 1);

      final state = container.read(workoutSessionControllerProvider);
      expect(state.phase, WorkoutSessionPhase.active);
      expect(state.elapsedWorkoutSeconds, 1);
      expect(state.remainingRestSeconds, 45);
    });

    test('rest phase counts down and returns to active at zero', () async {
      await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
        prescriptions: const {
          'a': WorkoutExercisePrescription(restSeconds: 2),
        },
      );

      controller().startRest();
      expect(
        container.read(workoutSessionControllerProvider).phase,
        WorkoutSessionPhase.resting,
      );

      controller().tickTimer(totalExercises: 1);
      expect(
        container.read(workoutSessionControllerProvider).remainingRestSeconds,
        1,
      );
      expect(
        container.read(workoutSessionControllerProvider).phase,
        WorkoutSessionPhase.resting,
      );

      controller().tickTimer(totalExercises: 1);
      final state = container.read(workoutSessionControllerProvider);
      expect(state.phase, WorkoutSessionPhase.active);
      expect(state.remainingRestSeconds, 0);
      expect(state.elapsedWorkoutSeconds, 2);
    });

    test('rest controls adjust time and skip back to active workout', () async {
      await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
        prescriptions: const {
          'a': WorkoutExercisePrescription(restSeconds: 20),
        },
      );

      controller().startRest();
      controller().adjustRestSeconds(-10);
      expect(
        container.read(workoutSessionControllerProvider).remainingRestSeconds,
        10,
      );
      expect(
        container.read(workoutSessionControllerProvider).restDurationSeconds,
        10,
      );

      controller().adjustRestSeconds(10);
      expect(
        container.read(workoutSessionControllerProvider).remainingRestSeconds,
        20,
      );
      expect(
        container.read(workoutSessionControllerProvider).restDurationSeconds,
        20,
      );

      controller().skipRest();
      final state = container.read(workoutSessionControllerProvider);
      expect(state.phase, WorkoutSessionPhase.active);
      expect(state.remainingRestSeconds, 0);
    });

    test('elapsed time persists periodically via repository', () async {
      await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
      );
      final controller0 = controller();
      // 30 tick pertama memicu persist pertama.
      for (var i = 0; i < 30; i++) {
        controller0.tickTimer(totalExercises: 1);
      }

      expect(repository.progressUpdates, contains(30));
      expect(repository.active?.elapsedSeconds, 30);
    });

    test('P1: prescriptions drive total sets, rest, and resume position', () async {
      repository.active = WorkoutSessionEntity(
        id: 's1',
        programId: 'program_1',
        programDayId: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        startedAt: today,
        elapsedSeconds: 100,
        status: WorkoutSessionStatus.inProgress,
      );
      // Exercise 'a' hanya 2 set; 'b' 4 set dengan rest 90s.
      repository.setsBySession['s1'] = [
        completedSet('a', 1),
        completedSet('a', 2),
        completedSet('b', 1),
      ];

      final result = await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a', 'b'],
        prescriptions: const {
          'a': WorkoutExercisePrescription(
            targetSets: 2,
            minReps: 8,
            maxReps: 12,
            restSeconds: 60,
          ),
          'b': WorkoutExercisePrescription(
            targetSets: 4,
            minReps: 10,
            maxReps: 15,
            restSeconds: 90,
          ),
        },
      );

      final state = container.read(workoutSessionControllerProvider);
      expect(result, isA<SessionPrepared>());
      // Posisi resume mengikuti target set per exercise, bukan asumsi 3.
      expect(state.currentExerciseIndex, 1);
      expect(state.currentSet, 2);
      expect(state.totalSetsPerExercise, 4);
      expect(state.defaultRestSeconds, 90);

      // Maju ke exercise berikutnya memakai preskripsi exercise itu.
      controller().nextPressed(totalExercises: 2);
      final after = container.read(workoutSessionControllerProvider);
      expect(after.currentExerciseIndex, 1);
      expect(after.remainingRestSeconds, 90);
    });

    test('P2: failed set save returns false and rolls the set back', () async {
      await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a', 'b'],
      );
      final controller0 = controller();
      await controller0.recordSetPerformance(
        exerciseId: 'a',
        setNumber: 1,
        actualReps: 10,
        rir: 2,
      );
      expect(
        container.read(workoutSessionControllerProvider).completedSets,
        1,
      );

      repository.failSaveSet = true;
      final saved = await controller0.recordSetPerformance(
        exerciseId: 'a',
        setNumber: 2,
        actualReps: 8,
        rir: 2,
      );

      // Penyimpanan gagal: caller tidak boleh memajukan posisi.
      expect(saved, isFalse);
      expect(repository.savedSets, hasLength(1));
      expect(
        container.read(workoutSessionControllerProvider).completedSets,
        1,
      );
      // Error set disimpan terpisah supaya kontrol workout tidak terkunci.
      expect(
        container.read(workoutSessionControllerProvider).setSaveError,
        isNotNull,
      );
      expect(
        container.read(workoutSessionControllerProvider).isSessionReady,
        isTrue,
      );

      // Retry setelah database normal kembali berhasil & error terhapus.
      repository.failSaveSet = false;
      controller0.clearError();
      final retried = await controller0.recordSetPerformance(
        exerciseId: 'a',
        setNumber: 2,
        actualReps: 8,
        rir: 2,
      );

      expect(retried, isTrue);
      expect(repository.savedSets, hasLength(2));
      expect(
        container.read(workoutSessionControllerProvider).completedSets,
        2,
      );
      expect(
        container.read(workoutSessionControllerProvider).setSaveError,
        isNull,
      );
    });

    test('P2: short-lived sessions no longer inherit closed-app wall time', () async {
      // Sesi dibuat 2 jam lalu tanpa waktu aktif tersimpan (mis. aplikasi
      // tewas beberapa detik setelah mulai). Resume TIDAK boleh menghitung
      // 2 jam sebagai durasi latihan.
      repository.active = WorkoutSessionEntity(
        id: 's_short',
        programId: 'program_1',
        programDayId: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        startedAt: DateTime.now().subtract(const Duration(hours: 2)),
        elapsedSeconds: 0,
        status: WorkoutSessionStatus.inProgress,
      );

      await controller().resumeExistingSession(
        sessionId: 's_short',
        exerciseIds: const ['a'],
      );

      expect(
        container.read(workoutSessionControllerProvider).elapsedWorkoutSeconds,
        0,
      );
    });

    test('P2: recently-interrupted session keeps its wall-clock estimate', () async {
      // Sesi baru dibuat 20 detik lalu lalu aplikasi tewas: wall-clock masih
      // akurat sebagai estimasi waktu aktif.
      repository.active = WorkoutSessionEntity(
        id: 's_recent',
        programId: 'program_1',
        programDayId: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        startedAt: DateTime.now().subtract(const Duration(seconds: 20)),
        elapsedSeconds: 0,
        status: WorkoutSessionStatus.inProgress,
      );

      await controller().resumeExistingSession(
        sessionId: 's_recent',
        exerciseIds: const ['a'],
      );

      expect(
        container.read(workoutSessionControllerProvider).elapsedWorkoutSeconds,
        inExclusiveRange(15, 40),
      );
    });

    test('P1: conflict carries the old session schedule for navigation', () async {
      final oldDate = today.subtract(const Duration(days: 2));
      repository.active = WorkoutSessionEntity(
        id: 'session_conflict',
        programId: 'program_old',
        programDayId: 1,
        programTitle: 'Old Program',
        scheduledDate: oldDate,
        startedAt: oldDate,
        status: WorkoutSessionStatus.inProgress,
      );

      final result = await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
      );

      final conflict = result as SessionConflict;
      expect(conflict.existingSessionId, 'session_conflict');
      expect(conflict.existingScheduledDate, oldDate);
    });
  });
}
