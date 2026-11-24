import '../domain/models/weight_record.dart';

/// A recorded weight positioned on a week in the selected chart window.
class WeightChartPoint {
  final int weekNumber;
  final double weightKg;

  const WeightChartPoint({required this.weekNumber, required this.weightKg});
}

class WeightChartSeries {
  const WeightChartSeries();

  /// Returns at most one point per week, keeping the latest measurement.
  /// Weeks are numbered from 1 (oldest) to [weeks] (current week).
  List<WeightChartPoint> build(
    List<WeightRecord> history, {
    required int weeks,
    required DateTime now,
  }) {
    if (weeks <= 0) return const [];

    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: weeks * 7 - 1));
    final byWeek = <int, WeightRecord>{};

    for (final record in history) {
      final date = DateTime(
        record.recordedAt.year,
        record.recordedAt.month,
        record.recordedAt.day,
      );
      if (date.isBefore(start) || date.isAfter(now)) continue;

      final dayOffset = date.difference(start).inDays;
      final week = (dayOffset ~/ 7) + 1;
      if (week < 1 || week > weeks) continue;

      final previous = byWeek[week];
      if (previous == null || record.recordedAt.isAfter(previous.recordedAt)) {
        byWeek[week] = record;
      }
    }

    final result = byWeek.entries
        .map((entry) => WeightChartPoint(
              weekNumber: entry.key,
              weightKg: entry.value.weightKg,
            ))
        .toList()
      ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
    return result;
  }
}
