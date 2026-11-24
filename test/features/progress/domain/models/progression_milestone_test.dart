import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/domain/models/progression_milestone.dart';

void main() {
  group('ProgressionMilestone', () {
    test('formats exerciseId into Title Case', () {
      final milestone = ProgressionMilestone(
        exerciseId: 'diamond_push_up',
        decision: 'progress',
        reason: 'Consistently hitting 15 reps',
        date: DateTime.parse('2026-11-20'),
      );

      expect(milestone.exerciseNameFormatted, 'Diamond Push Up');
    });

    test('formats nextExerciseId into Title Case when present', () {
      final milestone = ProgressionMilestone(
        exerciseId: 'standard_push_up',
        nextExerciseId: 'decline_push_up',
        decision: 'progress',
        reason: 'Mastered standard form',
        date: DateTime.parse('2026-11-20'),
      );

      expect(milestone.nextExerciseNameFormatted, 'Decline Push Up');
    });

    test(
      'returns null for nextExerciseNameFormatted when nextExerciseId is null',
      () {
        final milestone = ProgressionMilestone(
          exerciseId: 'pull_up',
          nextExerciseId: null,
          decision: 'maintain',
          reason: 'Form check pending',
          date: DateTime.parse('2026-11-20'),
        );

        expect(milestone.nextExerciseNameFormatted, isNull);
      },
    );
  });
}
