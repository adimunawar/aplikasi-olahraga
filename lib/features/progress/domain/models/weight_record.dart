/// Immutable Domain Model untuk riwayat catatan timbangan berat badan
class WeightRecord {
  final String id;
  final double weightKg;
  final DateTime recordedAt;

  const WeightRecord({
    required this.id,
    required this.weightKg,
    required this.recordedAt,
  });

  WeightRecord copyWith({
    String? id,
    double? weightKg,
    DateTime? recordedAt,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}

