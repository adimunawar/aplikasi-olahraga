import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/exercises/domain/extensions/localized_string_extension.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';
import 'package:workout_app/features/program/domain/models/program_day.dart';
import 'package:workout_app/features/workout_session/domain/models/exercise_prescription.dart';
import 'package:workout_app/features/workout_session/domain/services/workout_prescription_resolver.dart';

import '../onboarding/mock_exercise_factory.dart';

ProgramDay _day(List<WorkoutItem> items) {
  return ProgramDay(
    day: 1,
    week: 1,
    type: WorkoutTypeCode.f,
    focus: 'Full Body',
    isRest: false,
    isRetestMilestone: false,
    items: items,
  );
}

void main() {
  group('WorkoutPrescriptionResolver', () {
    test('falls back to ProgramDay.items when no explicit prescription', () {
      final exercises = [
        createMockExercise(id: 'a', name: 'A'),
        createMockExercise(id: 'b', name: 'B'),
      ];
      final resolver = WorkoutPrescriptionResolver(
        day: _day([
          WorkoutItem(
            exerciseId: 'a',
            sets: 2,
            reps: 10,
            restSeconds: 45,
            isMain: true,
          ),
          WorkoutItem(
            exerciseId: 'b',
            sets: 4,
            reps: 12,
            restSeconds: 90,
            isMain: true,
          ),
        ]),
        exercises: exercises,
      );

      final all = resolver.buildAll();
      expect(all['a']?.targetSets, 2);
      expect(all['a']?.restSeconds, 45);
      expect(all['b']?.targetSets, 4);
      expect(all['b']?.restSeconds, 90);

      final rx = resolver.forExercise('b');
      expect(rx.minReps, 12);
      expect(rx.maxReps, 12);
    });

    test('explicit prescriptions override ProgramDay.items', () {
      final resolver = WorkoutPrescriptionResolver(
        day: _day([
          WorkoutItem(
            exerciseId: 'a',
            sets: 3,
            reps: 8,
            restSeconds: 60,
            isMain: true,
          ),
        ]),
        exercises: [createMockExercise(id: 'a', name: 'A')],
        explicitPrescriptions: const {
          'a': WorkoutExercisePrescription(
            targetSets: 4,
            minReps: 10,
            maxReps: 15,
            restSeconds: 120,
          ),
        },
      );

      final rx = resolver.forExercise('a');
      expect(rx.targetSets, 4);
      expect(rx.minReps, 10);
      expect(rx.maxReps, 15);
      expect(rx.restSeconds, 120);
    });

    test('unknown exercise returns the default prescription', () {
      final resolver = WorkoutPrescriptionResolver(
        day: _day(const []),
        exercises: const [],
      );

      final rx = resolver.forExercise('unknown');
      expect(rx.targetSets, 3);
      expect(rx.minReps, 8);
      expect(rx.maxReps, 12);
      expect(rx.restSeconds, 60);
    });

    test('duration-based tracking maps reps target to duration seconds', () {
      final plank = createMockExercise(
        id: 'plank',
        name: 'Plank',
        trackingType: TrackingType.duration,
      );
      expect(plank.trackingType, TrackingType.duration);

      final resolver = WorkoutPrescriptionResolver(
        day: _day([
          WorkoutItem(
            exerciseId: 'plank',
            sets: 3,
            reps: 40,
            restSeconds: 30,
            isMain: true,
          ),
        ]),
        exercises: [plank],
      );

      final all = resolver.buildAll();
      final rx = all['plank']!;
      expect(rx.targetSets, 3);
      expect(rx.restSeconds, 30);
      expect(rx.isDuration, isTrue);
      expect(rx.targetDurationSeconds, 40);
      expect(rx.effectiveTarget, 40);
      expect(rx.minReps, 0);
      expect(rx.maxReps, 0);

      final directRx = resolver.forExercise('plank');
      expect(directRx.isDuration, isTrue);
      expect(directRx.targetDurationSeconds, 40);
      expect(directRx.effectiveTarget, 40);
      expect(directRx.minReps, 0);
      expect(directRx.maxReps, 0);
    });

    test('explicit prescription preserves targetDurationSeconds for duration tracking', () {
      final plank = createMockExercise(
        id: 'plank',
        name: 'Plank',
        trackingType: TrackingType.duration,
      );

      final resolver = WorkoutPrescriptionResolver(
        day: _day([
          WorkoutItem(
            exerciseId: 'plank',
            sets: 2,
            reps: 30,
            restSeconds: 45,
            isMain: true,
          ),
        ]),
        exercises: [plank],
        explicitPrescriptions: const {
          'plank': WorkoutExercisePrescription(
            targetSets: 4,
            minReps: 0,
            maxReps: 0,
            targetDurationSeconds: 60,
            restSeconds: 30,
          ),
        },
      );

      final rx = resolver.forExercise('plank');
      expect(rx.targetSets, 4);
      expect(rx.isDuration, isTrue);
      expect(rx.targetDurationSeconds, 60);
      expect(rx.effectiveTarget, 60);
      expect(rx.restSeconds, 30);
    });
  });

  group('LocalizedStringExtension.localized', () {
    test('uses Indonesian text for id locale', () {
      const value = LocalizedString(id: 'Tekan Dada', en: 'Chest Press');
      expect(value.localized('id'), 'Tekan Dada');
    });

    test('uses English text for en locale', () {
      const value = LocalizedString(id: 'Tekan Dada', en: 'Chest Press');
      expect(value.localized('en'), 'Chest Press');
    });

    test('falls back to the other language when preferred is empty', () {
      const onlyId = LocalizedString(id: 'Tekan Dada', en: '');
      expect(onlyId.localized('en'), 'Tekan Dada');

      const onlyEn = LocalizedString(id: '', en: 'Chest Press');
      expect(onlyEn.localized('id'), 'Chest Press');

      const bothEmpty = LocalizedString(id: '', en: '');
      expect(bothEmpty.localized('id'), '');
    });
  });
}
