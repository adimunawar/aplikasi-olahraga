import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';
import 'package:workout_app/features/workouts/domain/models/exercise_muscle_filter.dart';

void main() {
  Exercise exercise({
    String muscleEn = '',
    String muscleId = '',
    ExerciseCategory category = ExerciseCategory.push,
  }) {
    return Exercise(
      id: 'exercise',
      name: const LocalizedString(id: 'Latihan', en: 'Exercise'),
      category: category,
      difficulty: ExerciseDifficulty.intermediate,
      trackingType: TrackingType.reps,
      primaryMuscles: muscleEn.isEmpty && muscleId.isEmpty
          ? const []
          : [LocalizedString(id: muscleId, en: muscleEn)],
      stabilizerMuscles: const [],
      steps: const LocalizedList(id: [], en: []),
      commonMistakes: const LocalizedList(id: [], en: []),
      breathing: const LocalizedString(id: '', en: ''),
      variations: const ExerciseVariationGroup(),
      media: const ExerciseMedia(startPose: '', endPose: ''),
    );
  }

  group('ExerciseMuscleFilter', () {
    test('matches every muscle alias used by the exercise dataset', () {
      const cases = <ExerciseMuscleFilter, List<String>>{
        ExerciseMuscleFilter.chest: [
          'Chest',
          'Upper Chest',
          'Lower Chest',
          'Inner/Center Chest',
          'Pectoralis Major',
        ],
        ExerciseMuscleFilter.back: [
          'Lats (Latissimus Dorsi)',
          'Upper Back / Rhomboids',
          'Trapezius',
        ],
        ExerciseMuscleFilter.legs: [
          'Quadriceps',
          'Hamstrings',
          'Glutes',
          'Gluteus Maximus',
          'Calves',
          'Gastrocnemius',
          'Soleus',
          'Hip Flexors',
        ],
        ExerciseMuscleFilter.core: [
          'Core',
          'Core / Abs',
          'Lower Abs',
          'Obliques',
          'Rectus Abdominis',
          'Transverse Abdominis',
        ],
        ExerciseMuscleFilter.arms: ['Biceps', 'Triceps'],
        ExerciseMuscleFilter.shoulders: [
          'Deltoids',
          'Anterior Deltoids',
          'Shoulders',
        ],
      };

      for (final entry in cases.entries) {
        for (final muscle in entry.value) {
          expect(
            entry.key.matches(exercise(muscleEn: muscle)),
            isTrue,
            reason: '${entry.key.label} should match "$muscle"',
          );
        }
      }
    });

    test('does not match unrelated muscle groups', () {
      expect(
        ExerciseMuscleFilter.chest.matches(exercise(muscleEn: 'Triceps')),
        isFalse,
      );
      expect(
        ExerciseMuscleFilter.arms.matches(exercise(muscleEn: 'Chest')),
        isFalse,
      );
      expect(
        ExerciseMuscleFilter.core.matches(exercise(muscleEn: 'Lower Chest')),
        isFalse,
      );
      expect(
        ExerciseMuscleFilter.back.matches(exercise(muscleEn: 'Quadriceps')),
        isFalse,
      );
    });

    test('supports Indonesian muscle names', () {
      expect(
        ExerciseMuscleFilter.chest.matches(exercise(muscleId: 'Dada')),
        isTrue,
      );
      expect(
        ExerciseMuscleFilter.shoulders.matches(
          exercise(muscleId: 'Bahu depan'),
        ),
        isTrue,
      );
      expect(
        ExerciseMuscleFilter.arms.matches(exercise(muscleId: 'Lengan')),
        isTrue,
      );
      expect(
        ExerciseMuscleFilter.back.matches(exercise(muscleId: 'Punggung')),
        isTrue,
      );
      expect(
        ExerciseMuscleFilter.legs.matches(exercise(muscleId: 'Kaki')),
        isTrue,
      );
      expect(
        ExerciseMuscleFilter.core.matches(exercise(muscleId: 'Perut')),
        isTrue,
      );
    });

    test('falls back to exercise category when muscles are missing', () {
      expect(
        ExerciseMuscleFilter.legs.matches(
          exercise(category: ExerciseCategory.legs),
        ),
        isTrue,
      );
      expect(
        ExerciseMuscleFilter.core.matches(
          exercise(category: ExerciseCategory.core),
        ),
        isTrue,
      );
      expect(
        ExerciseMuscleFilter.chest.matches(
          exercise(category: ExerciseCategory.push),
        ),
        isFalse,
      );
    });

    test('all filter matches every exercise', () {
      expect(
        ExerciseMuscleFilter.all.matches(exercise(muscleEn: 'Triceps')),
        isTrue,
      );
      expect(ExerciseMuscleFilter.all.matches(exercise()), isTrue);
    });
  });
}
