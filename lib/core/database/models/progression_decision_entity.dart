import 'dart:convert';

/// Keputusan dari Progression Engine (Otak Coach Adi)
/// Menyimpan audit log rekomendasi adaptasi latihan
class ProgressionDecisionEntity {
  final String id;
  final String userId;
  final String exerciseId;
  final String decision; // 'progress', 'maintain', 'regress', 'recover', 'reassess'
  final String? previousPrescription; // JSON string
  final String? nextPrescription;     // JSON string
  final String reason;               // Penjelasan transparan dari Coach Adi
  final DateTime createdAt;

  const ProgressionDecisionEntity({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.decision,
    this.previousPrescription,
    this.nextPrescription,
    required this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'decision': decision,
      'previous_prescription': previousPrescription,
      'next_prescription': nextPrescription,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ProgressionDecisionEntity.fromMap(Map<String, dynamic> map) {
    return ProgressionDecisionEntity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      exerciseId: map['exercise_id'] as String,
      decision: map['decision'] as String,
      previousPrescription: map['previous_prescription'] as String?,
      nextPrescription: map['next_prescription'] as String?,
      reason: map['reason'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic>? get previousPrescriptionMap {
    if (previousPrescription == null) return null;
    try {
      return jsonDecode(previousPrescription!) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? get nextPrescriptionMap {
    if (nextPrescription == null) return null;
    try {
      return jsonDecode(nextPrescription!) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

