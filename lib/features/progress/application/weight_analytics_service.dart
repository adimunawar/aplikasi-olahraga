import '../domain/models/weight_record.dart';

/// Hasil komputasi analitik tren berat badan
class WeightAnalyticsResult {
  final double currentWeight;
  final double weightChange;
  final String startLabel;
  final String endLabel;

  const WeightAnalyticsResult({
    required this.currentWeight,
    required this.weightChange,
    required this.startLabel,
    required this.endLabel,
  });
}

/// Layanan komputasi analitik berat badan murni Dart
class WeightAnalyticsService {
  const WeightAnalyticsService();

  WeightAnalyticsResult analyze(List<WeightRecord> history, {double defaultWeight = 58.0}) {
    if (history.isEmpty) {
      return WeightAnalyticsResult(
        currentWeight: defaultWeight,
        weightChange: -1.0,
        startLabel: '60 kg\n(Oct 25)',
        endLabel: '${defaultWeight.toStringAsFixed(0)} kg\n(Nov 5)',
      );
    }

    final first = history.first;
    final last = history.last;
    final change = last.weightKg - first.weightKg;

    return WeightAnalyticsResult(
      currentWeight: last.weightKg,
      weightChange: double.parse(change.toStringAsFixed(1)),
      startLabel: '${first.weightKg.toStringAsFixed(0)} kg\n(${_formatMonthDay(first.recordedAt)})',
      endLabel: '${last.weightKg.toStringAsFixed(0)} kg\n(${_formatMonthDay(last.recordedAt)})',
    );
  }

  String _formatMonthDay(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

