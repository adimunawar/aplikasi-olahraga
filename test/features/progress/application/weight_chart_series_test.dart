import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/progress/application/weight_chart_series.dart';
import 'package:workout_app/features/progress/domain/models/weight_record.dart';

void main() {
  const series = WeightChartSeries();
  final now = DateTime(2026, 11, 20);

  WeightRecord record(String id, double kg, int daysAgo) => WeightRecord(
        id: id,
        weightKg: kg,
        recordedAt: now.subtract(Duration(days: daysAgo)),
      );

  group('WeightChartSeries', () {
    test('sorts measurements by week and maps them to chart week numbers', () {
      final points = series.build(
        [record('w8', 75.8, 2), record('w1', 73.5, 53)],
        weeks: 8,
        now: now,
      );

      expect(points.map((point) => point.weekNumber), [1, 8]);
      expect(points.map((point) => point.weightKg), [73.5, 75.8]);
    });

    test('keeps the latest measurement when a week has multiple records', () {
      final points = series.build(
        [record('older', 74.0, 10), record('newer', 74.6, 8)],
        weeks: 8,
        now: now,
      );

      expect(points, hasLength(1));
      expect(points.single.weightKg, 74.6);
    });

    test('excludes records outside the selected period and future records', () {
      final points = series.build(
        [
          record('too-old', 70, 56),
          record('inside', 75, 3),
          WeightRecord(
            id: 'future',
            weightKg: 80,
            recordedAt: now.add(const Duration(days: 1)),
          ),
        ],
        weeks: 8,
        now: now,
      );

      expect(points, hasLength(1));
      expect(points.single.weightKg, 75);
    });

    test('returns an empty series for an invalid range or empty history', () {
      expect(series.build([], weeks: 8, now: now), isEmpty);
      expect(series.build([record('w1', 70, 2)], weeks: 0, now: now), isEmpty);
    });
  });
}
