import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/workout_session_entity.dart';
import 'package:workout_app/core/database/models/workout_set_entity.dart';
import 'package:workout_app/features/workout_session/domain/models/workout_session_result.dart';
import 'package:workout_app/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:workout_app/features/workout_session/presentation/controllers/workout_session_controller.dart';

class _FakeWorkoutSessionRepository implements WorkoutSessionRepository {
  WorkoutSessionEntity? active;
  final List<WorkoutSetEntity> savedSets = [];
  final List<String> abandonedIds = [];
  final Map<String, List<WorkoutSetEntity>> setsBySession = {};
  final List<WorkoutSessionResult> completedResults = [];

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
    String? sessionId,
  }) async {
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
      container = ProviderContainer(
        overrides: [
          workoutSessionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      // Jaga provider autoDispose tetap hidup selama test.
      container.listen(workoutSessionControllerProvider, (_, _) {});
    });

    tearDown(() => container.dispose());

    WorkoutSessionController controller() =>
        container.read(workoutSessionControllerProvider.notifier);

    test('starts a new in-progress session when none exists', () async {
      final sessionId = await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a', 'b'],
      );

      expect(sessionId, isNotNull);
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
        status: WorkoutSessionStatus.inProgress,
      );
      repository.setsBySession['s1'] = [
        completedSet('a', 1),
        completedSet('a', 2),
        completedSet('a', 3),
        completedSet('b', 1),
      ];

      final sessionId = await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a', 'b'],
      );

      final state = container.read(workoutSessionControllerProvider);
      expect(sessionId, 's1');
      expect(state.currentExerciseIndex, 1);
      expect(state.currentSet, 2);
      expect(state.elapsedWorkoutSeconds, greaterThanOrEqualTo(115));
      expect(repository.abandonedIds, isEmpty);
    });

    test('abandons an in-progress session that belongs to another schedule', () async {
      repository.active = WorkoutSessionEntity(
        id: 'stale',
        programId: 'program_1',
        programDayId: 9,
        programTitle: 'Old',
        scheduledDate: today.subtract(const Duration(days: 3)),
        startedAt: today.subtract(const Duration(days: 3)),
        status: WorkoutSessionStatus.inProgress,
      );

      final sessionId = await controller().prepareSession(
        programId: 'program_1',
        dayNumber: 1,
        programTitle: 'Upper Body',
        scheduledDate: today,
        exerciseIds: const ['a'],
      );

      expect(repository.abandonedIds, contains('stale'));
      expect(sessionId, isNot('stale'));
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

      controller().recordSetPerformance(
        exerciseId: 'a',
        setNumber: 1,
        actualReps: 10,
        rir: 2,
      );
      await Future<void>.delayed(Duration.zero);

      expect(repository.savedSets, hasLength(1));
      expect(repository.savedSets.single.id, '${sessionId}_a_1');
      expect(repository.savedSets.single.sessionId, sessionId);
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
}
