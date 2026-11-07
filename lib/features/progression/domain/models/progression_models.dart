import 'dart:convert';

/// Aksi keputusan adaptasi latihan dari Progression Engine (Otak Coach Adi)
enum ProgressionAction {
  progress, // Naik ke variasi gerakan baru / naik rentang repetisi
  maintain, // Pertahankan target resep saat ini untuk mematangkan kestabilan
  regress,  // Turun ke variasi lebih ringan jika repetisi gagal berulang kali
  recover,  // Deload / kurangi volume latihan karena kelelahan atau nyeri sendi
  reassess, // Sesi uji ulang karena data tidak lengkap / belum cukup bukti
  ;

  String toDbString() => name;

  static ProgressionAction fromDbString(String val) {
    return ProgressionAction.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase().trim(),
      orElse: () => ProgressionAction.maintain,
    );
  }

  String get labelId {
    switch (this) {
      case ProgressionAction.progress:
        return 'Tingkatkan Beban / Variasi';
      case ProgressionAction.maintain:
        return 'Pertahankan & Matangkan';
      case ProgressionAction.regress:
        return 'Sesuaikan Gerakan Lebih Ringan';
      case ProgressionAction.recover:
        return 'Pemulihan & Deload';
      case ProgressionAction.reassess:
        return 'Evaluasi Ulang';
    }
  }
}

/// Resep target latihan saat ini maupun selanjutnya
class ExercisePrescription {
  final int targetSets;
  final int minReps;
  final int maxReps;
  final int targetRir;
  final double? targetLoadKg;

  const ExercisePrescription({
    required this.targetSets,
    required this.minReps,
    required this.maxReps,
    this.targetRir = 2,
    this.targetLoadKg,
  });

  Map<String, dynamic> toMap() {
    return {
      'target_sets': targetSets,
      'min_reps': minReps,
      'max_reps': maxReps,
      'target_rir': targetRir,
      if (targetLoadKg != null) 'target_load_kg': targetLoadKg,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory ExercisePrescription.fromMap(Map<String, dynamic> map) {
    return ExercisePrescription(
      targetSets: map['target_sets'] as int? ?? 3,
      minReps: map['min_reps'] as int? ?? 8,
      maxReps: map['max_reps'] as int? ?? 12,
      targetRir: map['target_rir'] as int? ?? 2,
      targetLoadKg: (map['target_load_kg'] as num?)?.toDouble(),
    );
  }

  ExercisePrescription copyWith({
    int? targetSets,
    int? minReps,
    int? maxReps,
    int? targetRir,
    double? targetLoadKg,
  }) {
    return ExercisePrescription(
      targetSets: targetSets ?? this.targetSets,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      targetRir: targetRir ?? this.targetRir,
      targetLoadKg: targetLoadKg ?? this.targetLoadKg,
    );
  }
}

/// Log aktual performa 1 set latihan
class SetPerformanceLog {
  final int setNumber;
  final int reps;
  final int? rir; // 0, 1, 2, 3, 4+
  final double formScore; // 0.0 - 1.0 (default 1.0)
  final double? weightKg;

  const SetPerformanceLog({
    required this.setNumber,
    required this.reps,
    this.rir,
    this.formScore = 1.0,
    this.weightKg,
  });
}

/// Feedback pemulihan & kondisi fisik user
class RecoveryFeedback {
  final bool hasPainOrInjury;
  final int fatigueLevel; // 1 (sangat segar) s/d 5 (kelelahan ekstrem)
  final int sorenessLevel; // 1 (tidak ada) s/d 5 (nyeri otot berat)
  final String? painLocation;
  final String? notes;

  const RecoveryFeedback({
    this.hasPainOrInjury = false,
    this.fatigueLevel = 2,
    this.sorenessLevel = 2,
    this.painLocation,
    this.notes,
  });
}

/// Input lengkap untuk Progression Engine
class ProgressionInput {
  final String exerciseId;
  final ExercisePrescription prescription;
  final List<SetPerformanceLog> completedSets;
  final RecoveryFeedback recoveryFeedback;
  final int consecutiveMaxRepsSessions; // Jumlah sesi berturut-turut mencapai max_reps
  final int recentUnderperformingSessions; // Jumlah sesi berturut-turut gagal min_reps
  final String? nextExerciseId; // Variasi berikutnya di tangga progresi
  final String? previousExerciseId; // Variasi sebelumnya di tangga progresi

  const ProgressionInput({
    required this.exerciseId,
    required this.prescription,
    required this.completedSets,
    this.recoveryFeedback = const RecoveryFeedback(),
    this.consecutiveMaxRepsSessions = 0,
    this.recentUnderperformingSessions = 0,
    this.nextExerciseId,
    this.previousExerciseId,
  });
}

/// Output keputusan resmi dari Progression Engine
class ProgressionDecision {
  final String exerciseId;
  final ProgressionAction action;
  final String reason;
  final ExercisePrescription nextPrescription;
  final String? suggestedExerciseId; // Jika naik variasi atau turun variasi

  const ProgressionDecision({
    required this.exerciseId,
    required this.action,
    required this.reason,
    required this.nextPrescription,
    this.suggestedExerciseId,
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'decision': action.name,
      'reason': reason,
      'next_prescription': nextPrescription.toMap(),
      if (suggestedExerciseId != null) 'suggested_exercise_id': suggestedExerciseId,
    };
  }
}

