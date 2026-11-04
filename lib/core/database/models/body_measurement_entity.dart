/// Entity BodyMeasurement untuk pelacakan berat badan & metrik fisik (PRD Bagian 10.6 & 14)
class BodyMeasurementEntity {
  final String id;
  final String measurementType; // 'weight', 'chest', 'arm', 'waist'
  final double value;
  final String unit; // 'kg', 'lbs', 'cm', 'inch'
  final DateTime recordedAt;

  const BodyMeasurementEntity({
    required this.id,
    this.measurementType = 'weight',
    required this.value,
    this.unit = 'kg',
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'measurement_type': measurementType,
      'value': value,
      'unit': unit,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory BodyMeasurementEntity.fromMap(Map<String, dynamic> map) {
    return BodyMeasurementEntity(
      id: map['id']?.toString() ?? '',
      measurementType: map['measurement_type']?.toString() ?? 'weight',
      value: (map['value'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? 'kg',
      recordedAt: map['recorded_at'] != null
          ? DateTime.tryParse(map['recorded_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

