import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progression/domain/models/progression_models.dart';
import 'package:workout_app/features/progression/domain/services/progression_engine.dart';

void main() {
  late ProgressionEngine engine;
  const defaultPrescription = ExercisePrescription(
    targetSets: 3,
    minReps: 8,
    maxReps: 12,
    targetRir: 2,
  );

  setUp(() {
    engine = const ProgressionEngine();
  });

  group('ProgressionEngine - Safety Guards', () {
    test('Safety Guard 0: Returns reassess when completedSets is empty', () {
      final input = ProgressionInput(
        exerciseId: 'knee_push_up',
        prescription: defaultPrescription,
        completedSets: [],
      );

      final decision = engine.evaluate(input);
      expect(decision.action, ProgressionAction.reassess);
      expect(decision.reason, contains('Belum ada data set'));
    });

    test('Safety Guard 0: Returns reassess when all completedSets have 0 reps', () {
      final input = ProgressionInput(
        exerciseId: 'knee_push_up',
        prescription: defaultPrescription,
        completedSets: [
          const SetPerformanceLog(setNumber: 1, reps: 0),
          const SetPerformanceLog(setNumber: 2, reps: 0),
        ],
      );

      final decision = engine.evaluate(input);
      expect(decision.action, ProgressionAction.reassess);
      expect(decision.reason, contains('Repetisi tercatat 0'));
    });

    test('Safety Guard 1: Returns recover when pain or injury is reported', () {
      final input = ProgressionInput(
        exerciseId: 'knee_push_up',
        prescription: defaultPrescription,
        completedSets: [
          const SetPerformanceLog(setNumber: 1, reps: 12, rir: 2),
          const SetPerformanceLog(setNumber: 2, reps: 12, rir: 2),
          const SetPerformanceLog(setNumber: 3, reps: 12, rir: 2),
        ],
        recoveryFeedback: const RecoveryFeedback(
          hasPainOrInjury: true,
          painLocation: 'bahu kanan',
        ),
      );

      final decision = engine.evaluate(input);
      expect(decision.action, ProgressionAction.recover);
      expect(decision.reason, contains('rasa sakit atau keluhan sendi'));
      expect(decision.nextPrescription.targetSets, lessThan(defaultPrescription.targetSets));
      expect(decision.nextPrescription.targetRir, equals(3));
    });

    test('Safety Guard 2: Returns recover when fatigue level is severe (>= 4)', () {
      final input = ProgressionInput(
        exerciseId: 'knee_push_up',
        prescription: defaultPrescription,
        completedSets: [
          const SetPerformanceLog(setNumber: 1, reps: 10, rir: 1),
          const SetPerformanceLog(setNumber: 2, reps: 9, rir: 1),
          const SetPerformanceLog(setNumber: 3, reps: 8, rir: 1),
        ],
        recoveryFeedback: const RecoveryFeedback(
          fatigueLevel: 5,
        ),
      );

      final decision = engine.evaluate(input);
      expect(decision.action, ProgressionAction.recover);
      expect(decision.reason, contains('Tingkat kelelahan'));
    });
  });

  group('ProgressionEngine - Double Progression Rules', () {
    test('Rule 5 (Maintain In-Range): Returns maintain when reps are within min..max', () {
      final input = ProgressionInput(
        exerciseId: 'knee_push_up',
        prescription: defaultPrescription,
        completedSets: [
          const SetPerformanceLog(setNumber: 1, reps: 10, rir: 2),
          const SetPerformanceLog(setNumber: 2, reps: 9, rir: 2),
          const SetPerformanceLog(setNumber: 3, reps: 8, rir: 1),
        ],
      );

      final decision = engine.evaluate(input);
      expect(decision.action, ProgressionAction.maintain);
      expect(decision.reason, contains('rentang 8-12'));
    });

    test('Rule 4 (First Max Reps Session): Returns maintain requiring 1 more confirmation session', () {
      final input = ProgressionInput(
        exerciseId: 'knee_push_up',
        prescription: defaultPrescription,
        completedSets: [
          const SetPerformanceLog(setNumber: 1, reps: 12, rir: 2),
          const SetPerformanceLog(setNumber: 2, reps: 12, rir: 2),
          const SetPerformanceLog(setNumber: 3, reps: 12, rir: 2),
        ],
        consecutiveMaxRepsSessions: 0, // First time hitting max reps
      );

      final decision = engine.evaluate(input);
      expect(decision.action, ProgressionAction.maintain);
      expect(decision.reason, contains('Selesaikan 1 sesi lagi'));
    });

    test('Rule 4 (Confirmed Mastery): Progresses to next exercise variation after 2 consecutive max sessions', () {
      final input = ProgressionInput(
        exerciseId: 'knee_push_up',
        prescription: defaultPrescription,
        completedSets: [
          const SetPerformanceLog(setNumber: 1, reps: 12, rir: 2),
          const SetPerformanceLog(setNumber: 2, reps: 12, rir: 2),
          const SetPerformanceLog(setNumber: 3, reps: 12, rir: 2),
        ],
        consecutiveMaxRepsSessions: 1, // Sesi kedua!
        nextExerciseId: 'push_up',
      );

      final decision = engine.evaluate(input);
      expect(decision.action, ProgressionAction.progress);
      expect(decision.suggestedExerciseId, 'push_up');
      expect(decision.reason, contains('naik kelas ke variasi gerakan baru'));
    });

    test('Rule 4 (Ladder Apex): Increases rep range if no further exercise variation exists', () {
      final input = ProgressionInput(
        exerciseId: 'diamond_push_up',
        prescription: defaultPrescription,
        completedSets: [
          const SetPerformanceLog(setNumber: 1, reps: 12, rir: 2),
          const SetPerformanceLog(setNumber: 2, reps: 12, rir: 2),
          const SetPerformanceLog(setNumber: 3, reps: 12, rir: 2),
        ],
        consecutiveMaxRepsSessions: 1,
        nextExerciseId: null, // Puncak tangga
      );

      final decision = engine.evaluate(input);
      expect(decision.action, ProgressionAction.progress);
      expect(decision.suggestedExerciseId, isNull);
      expect(decision.nextPrescription.minReps, equals(10));
      expect(decision.nextPrescription.maxReps, equals(14));
    });
  });

  group('ProgressionEngine - Regression & Underperformance', () {
    test('Rule 3 (Single Underperformance): Returns maintain with encouragement', () {
      final input = ProgressionInput(
        exerciseId: 'push_up',
        prescription: defaultPrescription,
        completedSets: [
          const SetPerformanceLog(setNumber: 1, reps: 6, rir: 0),
          const SetPerformanceLog(setNumber: 2, reps: 5, rir: 0),
          const SetPerformanceLog(setNumber: 3, reps: 4, rir: 0),
        ],
        recentUnderperformingSessions: 0, // First struggle
        previousExerciseId: 'knee_push_up',
      );

      final decision = engine.evaluate(input);
      expect(decision.action, ProgressionAction.maintain);
      expect(decision.reason, contains('cukup menantang'));
    });

    test('Rule 3 (Repeated Failure): Suggests regression to previous exercise after 2 failed sessions', () {
      final input = ProgressionInput(
        exerciseId: 'push_up',
        prescription: defaultPrescription,
        completedSets: [
          const SetPerformanceLog(setNumber: 1, reps: 6, rir: 0),
          const SetPerformanceLog(setNumber: 2, reps: 5, rir: 0),
          const SetPerformanceLog(setNumber: 3, reps: 4, rir: 0),
        ],
        recentUnderperformingSessions: 1, // Sesi kedua gagal
        previousExerciseId: 'knee_push_up',
      );

      final decision = engine.evaluate(input);
      expect(decision.action, ProgressionAction.regress);
      expect(decision.suggestedExerciseId, 'knee_push_up');
      expect(decision.reason, contains('mundur 1 tingkat'));
    });
  });
}
