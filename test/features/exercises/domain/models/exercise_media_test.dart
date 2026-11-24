import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/utils/media_url_resolver.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';

void main() {
  group('ExerciseMedia & Exercise thumbnail_url tests', () {
    test('ExerciseMedia parses thumbnail_url correctly and resolves R2 to proxy', () {
      final json = {
        'start_pose': 'assets/images/push_up_start.png',
        'end_pose': 'assets/images/push_up_end.png',
        'video_url': 'https://pub-abc.r2.dev/videos/push_up.mp4',
        'thumbnail_url': 'https://pub-abc.r2.dev/exercises/push_up.webp',
      };

      final media = ExerciseMedia.fromJson(json);

      expect(media.startPose, 'assets/images/push_up_start.png');
      expect(media.endPose, 'assets/images/push_up_end.png');
      expect(
        media.videoUrl,
        '${MediaUrlResolver.baseUrl}/api/media/videos/push_up.mp4',
      );
      expect(
        media.thumbnailUrl,
        '${MediaUrlResolver.baseUrl}/api/media/exercises/push_up.webp',
      );
    });

    test('Exercise parses thumbnail_url from root json', () {
      final json = {
        'id': 'push_up',
        'name': {'id': 'Push Up', 'en': 'Push Up'},
        'category': 'push',
        'difficulty': 'beginner',
        'tracking_type': 'reps',
        'movement_pattern': 'horizontal_push',
        'equipments': ['none'],
        'primary_muscles': [{'id': 'Dada', 'en': 'Chest'}],
        'stabilizer_muscles': [{'id': 'Trisep', 'en': 'Triceps'}],
        'steps': {'id': ['Langkah 1'], 'en': ['Step 1']},
        'common_mistakes': {'id': ['Kesalahan 1'], 'en': ['Mistake 1']},
        'breathing': {'id': 'Tarik saat turun', 'en': 'Inhale on descent'},
        'variations': {'harder': ['diamond_push_up']},
        'media': {
          'start_pose': 'assets/images/push_up.png',
          'end_pose': '',
        },
        'video_url': 'https://pub-abc.r2.dev/videos/push_up.mp4',
        'thumbnail_url': 'https://pub-abc.r2.dev/exercises/push_up.webp',
      };

      final exercise = Exercise.fromJson(json);

      expect(
        exercise.thumbnailUrl,
        '${MediaUrlResolver.baseUrl}/api/media/exercises/push_up.webp',
      );
      expect(
        exercise.resolvedThumbnailUrl,
        '${MediaUrlResolver.baseUrl}/api/media/exercises/push_up.webp',
      );
      expect(
        exercise.resolvedImageUrl,
        '${MediaUrlResolver.baseUrl}/api/media/exercises/push_up.webp',
      );
      expect(
        exercise.media.thumbnailUrl,
        '${MediaUrlResolver.baseUrl}/api/media/exercises/push_up.webp',
      );
    });

    test('Exercise parses thumbnail_url from nested media json if root is absent', () {
      final json = {
        'id': 'squat',
        'name': {'id': 'Squat', 'en': 'Squat'},
        'category': 'legs',
        'difficulty': 'beginner',
        'tracking_type': 'reps',
        'movement_pattern': 'squat',
        'primary_muscles': [],
        'stabilizer_muscles': [],
        'steps': {'id': [], 'en': []},
        'common_mistakes': {'id': [], 'en': []},
        'breathing': {'id': '', 'en': ''},
        'variations': {},
        'media': {
          'start_pose': 'assets/images/squat.png',
          'end_pose': '',
          'video_url': 'https://pub-abc.r2.dev/videos/squat.mp4',
          'thumbnail_url': 'https://pub-abc.r2.dev/exercises/squat.webp',
        },
      };

      final exercise = Exercise.fromJson(json);

      expect(
        exercise.thumbnailUrl,
        '${MediaUrlResolver.baseUrl}/api/media/exercises/squat.webp',
      );
      expect(
        exercise.resolvedThumbnailUrl,
        '${MediaUrlResolver.baseUrl}/api/media/exercises/squat.webp',
      );
      expect(
        exercise.resolvedImageUrl,
        '${MediaUrlResolver.baseUrl}/api/media/exercises/squat.webp',
      );
    });

    test('resolvedImageUrl falls back to startPose if thumbnailUrl is empty or null', () {
      final json = {
        'id': 'plank',
        'name': {'id': 'Plank', 'en': 'Plank'},
        'category': 'core',
        'difficulty': 'beginner',
        'tracking_type': 'duration',
        'movement_pattern': 'core',
        'primary_muscles': [],
        'stabilizer_muscles': [],
        'steps': {'id': [], 'en': []},
        'common_mistakes': {'id': [], 'en': []},
        'breathing': {'id': '', 'en': ''},
        'variations': {},
        'media': {
          'start_pose': 'assets/images/plank.png',
          'end_pose': '',
        },
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.thumbnailUrl, isNull);
      expect(exercise.resolvedThumbnailUrl, isNull);
      expect(exercise.resolvedImageUrl, 'assets/images/plank.png');
    });
  });
}
