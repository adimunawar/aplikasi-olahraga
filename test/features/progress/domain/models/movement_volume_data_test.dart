import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/domain/models/movement_volume_data.dart';

void main() {
  group('MovementVolumeData', () {
    test('maps patterns to localized labelId correctly', () {
      const push = MovementVolumeData(
        pattern: 'push',
        totalSets: 10,
        totalReps: 100,
      );
      const pull = MovementVolumeData(
        pattern: 'pull',
        totalSets: 8,
        totalReps: 80,
      );
      const squat = MovementVolumeData(
        pattern: 'squat',
        totalSets: 12,
        totalReps: 120,
      );
      const hinge = MovementVolumeData(
        pattern: 'hinge',
        totalSets: 6,
        totalReps: 60,
      );
      const core = MovementVolumeData(
        pattern: 'core',
        totalSets: 5,
        totalReps: 50,
      );
      const other = MovementVolumeData(
        pattern: 'cardio',
        totalSets: 0,
        totalReps: 0,
      );

      expect(push.labelId, 'Push (Dada & Bahu)');
      expect(pull.labelId, 'Pull (Punggung & Biceps)');
      expect(squat.labelId, 'Squat (Paha Depan)');
      expect(hinge.labelId, 'Hinge (Paha Belakang & Glutes)');
      expect(core.labelId, 'Core (Perut & Pinggang)');
      expect(other.labelId, 'Lainnya');
    });

    test('creates from map with valid data', () {
      final data = MovementVolumeData.fromMap({
        'movement_pattern': 'push',
        'sets_count': 15,
        'reps_sum': 150,
      });

      expect(data.pattern, 'push');
      expect(data.totalSets, 15);
      expect(data.totalReps, 150);
    });

    test('handles missing or null map values gracefully', () {
      final data = MovementVolumeData.fromMap({});

      expect(data.pattern, 'other');
      expect(data.totalSets, 0);
      expect(data.totalReps, 0);
    });
  });
}
