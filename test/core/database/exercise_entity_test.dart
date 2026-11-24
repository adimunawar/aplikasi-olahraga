import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/database/models/exercise_entity.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';

void main() {
  group('ExerciseEntity thumbnailUrl mapping tests', () {
    test('toMap and fromMap preserve thumbnailUrl', () {
      final now = DateTime.now();
      final entity = ExerciseEntity(
        id: 'push_up',
        nameId: 'Push Up',
        nameEn: 'Push Up',
        category: 'push',
        primaryMusclesJson: '[]',
        stabilizerMusclesJson: '[]',
        stepsIdJson: '[]',
        stepsEnJson: '[]',
        videoUrl: 'https://example.com/push_up.mp4',
        thumbnailUrl: 'https://example.com/push_up.webp',
        createdAt: now,
        updatedAt: now,
      );

      final map = entity.toMap();
      expect(map['thumbnail_url'], 'https://example.com/push_up.webp');

      final fromMap = ExerciseEntity.fromMap(map);
      expect(fromMap.thumbnailUrl, 'https://example.com/push_up.webp');
      expect(fromMap.videoUrl, 'https://example.com/push_up.mp4');
    });

    test('fromDomain and toDomain roundtrip preserves thumbnailUrl', () {
      final exercise = Exercise(
        id: 'push_up',
        name: const LocalizedString(id: 'Push Up', en: 'Push Up'),
        category: ExerciseCategory.push,
        difficulty: ExerciseDifficulty.beginner,
        trackingType: TrackingType.reps,
        primaryMuscles: const [],
        stabilizerMuscles: const [],
        steps: const LocalizedList(id: [], en: []),
        commonMistakes: const LocalizedList(id: [], en: []),
        breathing: const LocalizedString(id: '', en: ''),
        variations: const ExerciseVariationGroup(),
        media: const ExerciseMedia(
          startPose: 'assets/images/push_up.png',
          endPose: '',
          videoUrl: 'https://example.com/push_up.mp4',
          thumbnailUrl: 'https://example.com/push_up.webp',
        ),
        videoUrl: 'https://example.com/push_up.mp4',
        thumbnailUrl: 'https://example.com/push_up.webp',
      );

      final entity = ExerciseEntity.fromDomain(exercise);
      expect(entity.thumbnailUrl, 'https://example.com/push_up.webp');

      final domain = entity.toDomain();
      expect(domain.thumbnailUrl, 'https://example.com/push_up.webp');
      expect(domain.media.thumbnailUrl, 'https://example.com/push_up.webp');
      expect(domain.resolvedThumbnailUrl, 'https://example.com/push_up.webp');
      expect(domain.resolvedImageUrl, 'https://example.com/push_up.webp');
    });
  });
}
