import '../models/progression_models.dart';

/// Pure Domain Service: ProgressionEngine (Otak Coach Adi)
/// Bertanggung jawab atas evaluasi performa objektif dan penentuan adaptasi beban/variasi
/// berdasarkan prinsip Double Progression dan Safety Guards ketat (PRD v2 & Roadmap Fase 4).
class ProgressionEngine {
  const ProgressionEngine();

  /// Ambang batas minimal sesi berturut-turut mencapai max_reps sebelum boleh naik variasi / beban
  static const int minSuccessSessionsForProgression = 2;

  /// Ambang batas minimal sesi berturut-turut di bawah target sebelum disarankan regresi
  static const int minFailedSessionsForRegression = 2;

  /// Evaluasi input performa dan kembalikan keputusan adaptasi yang deterministik & transparan
  ProgressionDecision evaluate(ProgressionInput input) {
    // ----------------------------------------------------
    // SAFETY GUARD 0: Ketersediaan & Validitas Data
    // "Engine tidak boleh melakukan progression apabila data penting tidak tersedia atau tidak cukup dapat dipercaya"
    // ----------------------------------------------------
    if (input.completedSets.isEmpty) {
      return ProgressionDecision(
        exerciseId: input.exerciseId,
        action: ProgressionAction.reassess,
        reason: 'Belum ada data set yang diselesaikan pada sesi ini. Coach Adi mempertahankan target saat ini untuk dievaluasi pada sesi latihan berikutnya.',
        nextPrescription: input.prescription,
      );
    }

    final validSets = input.completedSets.where((s) => s.reps > 0).toList();
    if (validSets.isEmpty) {
      return ProgressionDecision(
        exerciseId: input.exerciseId,
        action: ProgressionAction.reassess,
        reason: 'Repetisi tercatat 0 pada seluruh set. Coach Adi membutuhkan data repetisi aktual sebelum dapat memberikan rekomendasi perubahan.',
        nextPrescription: input.prescription,
      );
    }

    // ----------------------------------------------------
    // SAFETY GUARD 1: Indikasi Nyeri / Sakit Sendi (Injury Prevention)
    // ----------------------------------------------------
    if (input.recoveryFeedback.hasPainOrInjury) {
      final reducedSets = (input.prescription.targetSets > 1)
          ? input.prescription.targetSets - 1
          : 1;
      return ProgressionDecision(
        exerciseId: input.exerciseId,
        action: ProgressionAction.recover,
        reason: 'Terdeteksi indikasi rasa sakit atau keluhan sendi. Keselamatan dan umur panjang sendi adalah prioritas nomor satu. Coach Adi merekomendasikan fase pemulihan: kurangi volume latihan sebesar 30% dan hindari beban berlebih.',
        nextPrescription: input.prescription.copyWith(
          targetSets: reducedSets,
          targetRir: 3, // Cadangan tenaga lebih banyak
        ),
      );
    }

    // ----------------------------------------------------
    // SAFETY GUARD 2: Kelelahan Ekstrem / Nyeri Otot Berat (Deload Trigger)
    // ----------------------------------------------------
    if (input.recoveryFeedback.fatigueLevel >= 4 || input.recoveryFeedback.sorenessLevel >= 5) {
      return ProgressionDecision(
        exerciseId: input.exerciseId,
        action: ProgressionAction.recover,
        reason: 'Tingkat kelelahan atau nyeri ototmu sedang sangat tinggi. Otot tumbuh saat pemulihan, bukan saat dipaksa ketika lelah. Coach Adi menyarankan deload aktif dengan intensitas santai agar tubuh kembali segar.',
        nextPrescription: input.prescription.copyWith(
          targetRir: 3,
        ),
      );
    }

    // ----------------------------------------------------
    // ANALISIS PERFORMA SESI SAAT INI
    // ----------------------------------------------------
    final prescription = input.prescription;
    final totalCompletedReps = validSets.fold<int>(0, (sum, s) => sum + s.reps);
    final avgReps = totalCompletedReps / validSets.length;

    // Hitung rata-rata RIR jika diisi
    final setsWithRir = validSets.where((s) => s.rir != null).toList();
    final avgRir = setsWithRir.isNotEmpty
        ? setsWithRir.fold<int>(0, (sum, s) => sum + s.rir!) / setsWithRir.length
        : 2.0;

    // Apakah semua set mencapai target repetisi maksimal?
    final allHitMaxReps = validSets.length >= prescription.targetSets &&
        validSets.every((s) => s.reps >= prescription.maxReps);

    // Apakah performa di bawah rentang minimum?
    final severelyUnderperformed = validSets.any((s) => s.reps < prescription.minReps) ||
        (avgReps < prescription.minReps);

    // ----------------------------------------------------
    // ATURAN 3: REGRESI (Kegagalan Berulang atau Terlalu Berat)
    // ----------------------------------------------------
    if (severelyUnderperformed) {
      final totalUnderperformingSessions = input.recentUnderperformingSessions + 1;
      if (totalUnderperformingSessions >= minFailedSessionsForRegression) {
        if (input.previousExerciseId != null) {
          return ProgressionDecision(
            exerciseId: input.exerciseId,
            action: ProgressionAction.regress,
            reason: 'Variasi gerakan ini tampak masih terlalu berat untuk menjaga postur tubuh yang prima ($totalUnderperformingSessions sesi di bawah target minimum). Coach Adi menyarankan mundur 1 tingkat ke variasi yang lebih bersahabat untuk mematangkan fondasi kekuatan.',
            nextPrescription: prescription.copyWith(
              minReps: 8,
              maxReps: 12,
              targetRir: 2,
            ),
            suggestedExerciseId: input.previousExerciseId,
          );
        } else {
          // Tidak ada gerakan lebih ringan di tangga, turunkan target reps
          final newMinReps = (prescription.minReps > 5) ? prescription.minReps - 2 : prescription.minReps;
          final newMaxReps = (prescription.maxReps > 8) ? prescription.maxReps - 2 : prescription.maxReps;
          return ProgressionDecision(
            exerciseId: input.exerciseId,
            action: ProgressionAction.regress,
            reason: 'Target repetisi terasa sedikit terlalu tinggi. Coach Adi menyesuaikan target menjadi $newMinReps-$newMaxReps repetisi agar kamu bisa berlatih dengan bentuk gerakan yang rapi tanpa memaksakan diri.',
            nextPrescription: prescription.copyWith(
              minReps: newMinReps,
              maxReps: newMaxReps,
              targetRir: 2,
            ),
          );
        }
      } else {
        // Baru 1 sesi di bawah target: Pertahankan & dorong istirahat cukup
        return ProgressionDecision(
          exerciseId: input.exerciseId,
          action: ProgressionAction.maintain,
          reason: 'Sesi ini cukup menantang dan berada di batas kemampuanmu saat ini. Jangan berkecil hati, ini bagian wajar dari adaptasi tubuh! Coach Adi menyarankan pertahankan target repetisi ini di sesi berikutnya.',
          nextPrescription: prescription,
        );
      }
    }

    // ----------------------------------------------------
    // ATURAN 4: DOUBLE PROGRESSION - TAHAP 2: PROGRESSION (Kenaikan Beban / Variasi)
    // Syarat: Mencapai max_reps pada SEMUA set dengan RIR aman (>= 1) selama minimal 2 sesi berturut-turut.
    // ----------------------------------------------------
    if (allHitMaxReps && avgRir >= 1.0) {
      final totalConsecutiveMaxSessions = input.consecutiveMaxRepsSessions + 1;

      if (totalConsecutiveMaxSessions >= minSuccessSessionsForProgression) {
        // SUKSES TERVALIDASI 2 SESI BERTURUT-TURUT -> PICU KENAIKAN
        if (input.nextExerciseId != null) {
          // Ada variasi gerakan selanjutnya pada ladder (misal: Knee Push-up -> Full Push-up)
          return ProgressionDecision(
            exerciseId: input.exerciseId,
            action: ProgressionAction.progress,
            reason: 'Luar biasa! Kamu konsisten menguasai ${prescription.maxReps} repetisi selama $totalConsecutiveMaxSessions sesi dengan cadangan tenaga aman. Saatnya naik kelas ke variasi gerakan baru yang lebih menantang!',
            nextPrescription: prescription.copyWith(
              minReps: 6,
              maxReps: 10,
              targetRir: 2,
            ),
            suggestedExerciseId: input.nextExerciseId,
          );
        } else {
          // Sudah gerakan paling tinggi pada ladder, naikkan repetisi atau set
          final newMinReps = prescription.minReps + 2;
          final newMaxReps = prescription.maxReps + 2;
          return ProgressionDecision(
            exerciseId: input.exerciseId,
            action: ProgressionAction.progress,
            reason: 'Performa istimewa! Kamu konsisten menuntaskan ${prescription.maxReps} repetisi dengan prima. Coach Adi menaikkan target repetisi menjadi $newMinReps-$newMaxReps repetisi untuk memacu pertumbuhan massa otot baru.',
            nextPrescription: prescription.copyWith(
              minReps: newMinReps,
              maxReps: newMaxReps,
              targetRir: 2,
            ),
          );
        }
      } else {
        // Baru 1 sesi mencapai max_reps: Butuh konfirmasi 1 sesi lagi agar adaptasi paten (Double Progression rule)
        return ProgressionDecision(
          exerciseId: input.exerciseId,
          action: ProgressionAction.maintain,
          reason: 'Hebat! Kamu berhasil mencapai target maksimal ${prescription.maxReps} repetisi pada seluruh set. Selesaikan 1 sesi lagi pada target ini untuk memastikan otot dan persendianmu benar-benar siap naik kelas!',
          nextPrescription: prescription,
        );
      }
    }

    // ----------------------------------------------------
    // ATURAN 5: DOUBLE PROGRESSION - TAHAP 1: MAINTAIN & IN-RANGE ADAPTATION
    // User berhasil di dalam rentang min_reps..max_reps
    // ----------------------------------------------------
    return ProgressionDecision(
      exerciseId: input.exerciseId,
      action: ProgressionAction.maintain,
      reason: 'Kerja keras yang solid! Kamu berada di jalur yang tepat dalam rentang ${prescription.minReps}-${prescription.maxReps} repetisi. Pertahankan ritme ini dan usahakan menambah 1 repetisi per set pada sesi latihan mendatang.',
      nextPrescription: prescription,
    );
  }
}

