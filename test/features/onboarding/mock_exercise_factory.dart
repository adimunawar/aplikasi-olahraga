import 'package:workout_app/features/exercises/domain/models/exercise.dart';

Exercise createMockExercise({
  required String id,
  required String name,
  ExerciseCategory category = ExerciseCategory.core,
  ExerciseDifficulty difficulty = ExerciseDifficulty.beginner,
  String movementPattern = 'horizontal_push',
  List<String> equipments = const ['none', 'bodyweight'],
}) {
  return Exercise(
    id: id,
    name: LocalizedString(id: name, en: name),
    category: category,
    difficulty: difficulty,
    trackingType: TrackingType.reps,
    movementPattern: movementPattern,
    equipments: equipments,
    primaryMuscles: [LocalizedString(id: 'Dada', en: 'Chest')],
    stabilizerMuscles: [LocalizedString(id: 'Core', en: 'Core')],
    steps: LocalizedList(id: ['Langkah 1'], en: ['Step 1']),
    commonMistakes: LocalizedList(id: ['Kesalahan 1'], en: ['Mistake 1']),
    breathing: const LocalizedString(id: 'Tarik nafas', en: 'Inhale'),
    variations: const ExerciseVariationGroup(),
    media: const ExerciseMedia(startPose: '', endPose: ''),
  );
}

List<Exercise> getStandardMockCatalog() {
  return [
    createMockExercise(
      id: 'knee_push_up',
      name: 'Knee Push Up',
      movementPattern: 'horizontal_push',
    ),
    createMockExercise(
      id: 'push_up',
      name: 'Push Up',
      movementPattern: 'horizontal_push',
      difficulty: ExerciseDifficulty.intermediate,
    ),
    createMockExercise(
      id: 'diamond_push_up',
      name: 'Diamond Push Up',
      movementPattern: 'horizontal_push',
      difficulty: ExerciseDifficulty.advanced,
    ),
    createMockExercise(
      id: 'incline_push_up',
      name: 'Incline Push Up',
      movementPattern: 'horizontal_push',
    ),
    createMockExercise(
      id: 'squat',
      name: 'Bodyweight Squat',
      movementPattern: 'squat',
    ),
    createMockExercise(
      id: 'split_squat',
      name: 'Split Squat',
      movementPattern: 'squat',
    ),
    createMockExercise(id: 'lunges', name: 'Lunges', movementPattern: 'lunge'),
    createMockExercise(
      id: 'glute_bridge',
      name: 'Glute Bridge',
      movementPattern: 'hinge',
    ),
    createMockExercise(
      id: 'inverted_row',
      name: 'Inverted Row',
      movementPattern: 'horizontal_pull',
    ),
    createMockExercise(
      id: 'doorframe_row',
      name: 'Doorframe Row',
      movementPattern: 'horizontal_pull',
    ),
    createMockExercise(
      id: 'table_row',
      name: 'Table Row',
      movementPattern: 'horizontal_pull',
    ),
    createMockExercise(
      id: 'plank',
      name: 'Plank',
      movementPattern: 'core_static',
    ),
    createMockExercise(
      id: 'dead_bug',
      name: 'Dead Bug',
      movementPattern: 'core_dynamic',
    ),
    createMockExercise(
      id: 'bird_dog',
      name: 'Bird Dog',
      movementPattern: 'core_static',
    ),
    createMockExercise(
      id: 'superman',
      name: 'Superman',
      movementPattern: 'back_extension',
    ),
    createMockExercise(
      id: 'calf_raises',
      name: 'Calf Raises',
      movementPattern: 'isolation',
    ),
  ];
}
