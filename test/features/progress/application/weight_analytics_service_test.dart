import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/application/weight_analytics_service.dart';
import 'package:workout_app/features/progress/domain/models/weight_record.dart';

void main() {
  const service = WeightAnalyticsService();

  group('WeightAnalyticsService', () {
    test('analyzes empty weight history with default zeros', () {
      final result = service.analyze(const <WeightRecord>[]);

      expect(result.currentWeight, 0);
      expect(result.weightChange, 0);
      expect(result.startLabel, isEmpty);
      expect(result.endLabel, isEmpty);
    });

    test('analyzes empty weight history with provided defaultWeight', () {
      final result = service.analyze(
        const <WeightRecord>[],
        defaultWeight: 68.5,
      );

      expect(result.currentWeight, 68.5);
      expect(result.weightChange, 0);
      expect(result.startLabel, isEmpty);
      expect(result.endLabel, isEmpty);
    });

    test('analyzes single measurement with zero change', () {
      final history = [
        WeightRecord(
          id: 'w1',
          weightKg: 70.0,
          recordedAt: DateTime(2026, 1, 15),
        ),
      ];

      final result = service.analyze(history);

      expect(result.currentWeight, 70.0);
      expect(result.weightChange, 0.0);
      expect(result.startLabel, '70 kg\n(Jan 15)');
      expect(result.endLabel, '70 kg\n(Jan 15)');
    });

    test('calculates positive weight change correctly', () {
      final history = [
        WeightRecord(
          id: 'w1',
          weightKg: 70.0,
          recordedAt: DateTime(2026, 3, 1),
        ),
        WeightRecord(
          id: 'w2',
          weightKg: 71.2,
          recordedAt: DateTime(2026, 3, 15),
        ),
        WeightRecord(
          id: 'w3',
          weightKg: 72.5,
          recordedAt: DateTime(2026, 3, 30),
        ),
      ];

      final result = service.analyze(history);

      expect(result.currentWeight, 72.5);
      expect(result.weightChange, 2.5);
      expect(result.startLabel, '70 kg\n(Mar 1)');
      expect(result.endLabel, '73 kg\n(Mar 30)');
    });

    test('calculates negative weight change correctly', () {
      final history = [
        WeightRecord(
          id: 'w1',
          weightKg: 80.0,
          recordedAt: DateTime(2026, 6, 1),
        ),
        WeightRecord(
          id: 'w2',
          weightKg: 78.5,
          recordedAt: DateTime(2026, 6, 15),
        ),
        WeightRecord(
          id: 'w3',
          weightKg: 77.2,
          recordedAt: DateTime(2026, 6, 30),
        ),
      ];

      final result = service.analyze(history);

      expect(result.currentWeight, 77.2);
      expect(result.weightChange, -2.8);
      expect(result.startLabel, '80 kg\n(Jun 1)');
      expect(result.endLabel, '77 kg\n(Jun 30)');
    });

    test('formats months correctly across different months', () {
      final history = [
        WeightRecord(
          id: 'w1',
          weightKg: 65.4,
          recordedAt: DateTime(2026, 10, 5),
        ),
        WeightRecord(
          id: 'w2',
          weightKg: 66.1,
          recordedAt: DateTime(2026, 12, 25),
        ),
      ];

      final result = service.analyze(history);

      expect(result.startLabel, '65 kg\n(Oct 5)');
      expect(result.endLabel, '66 kg\n(Dec 25)');
    });
  });
}
