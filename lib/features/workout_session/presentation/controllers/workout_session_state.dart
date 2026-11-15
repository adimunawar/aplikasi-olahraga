import '../../domain/models/workout_session_result.dart';

/// Immutable State untuk Sesi Latihan Aktif (Presentation Layer)
class WorkoutSessionState {
  final int currentExerciseIndex;
  final int currentSet;
  final int totalSetsPerExercise;
  final int remainingRestSeconds;
  final int defaultRestSeconds;
  final bool isTimerPaused;
  final int elapsedWorkoutSeconds;
  final bool isSaving;

  /// True selama persiapan sesi (buat/pulihkan record in_progress) berjalan.
  final bool isPreparing;

  /// Jumlah set yang benar-benar tercatat (dari log aktual, bukan posisi).
  final int completedSets;
  final WorkoutSessionResult? completedResult;
  final String? errorMessage;

  /// Error khusus kegagalan menyimpan satu set. Tidak mengunci kontrol
  /// workout — user tinggal mencatat ulang set yang sama.
  final String? setSaveError;

  const WorkoutSessionState({
    this.currentExerciseIndex = 0,
    this.currentSet = 1,
    this.totalSetsPerExercise = 3,
    this.remainingRestSeconds = 60,
    this.defaultRestSeconds = 60,
    this.isTimerPaused = false,
    this.elapsedWorkoutSeconds = 0,
    this.isSaving = false,
    this.isPreparing = true,
    this.completedSets = 0,
    this.completedResult,
    this.errorMessage,
    this.setSaveError,
  });

  bool get isLastExercise => false; // Diatur dinamis oleh controller

  /// Kontrol workout (timer, complete set, next) hanya aktif setelah
  /// record in_progress siap dan tidak ada error persiapan.
  bool get isSessionReady => !isPreparing && errorMessage == null;

  WorkoutSessionState copyWith({
    int? currentExerciseIndex,
    int? currentSet,
    int? totalSetsPerExercise,
    int? remainingRestSeconds,
    int? defaultRestSeconds,
    bool? isTimerPaused,
    int? elapsedWorkoutSeconds,
    bool? isSaving,
    bool? isPreparing,
    int? completedSets,
    WorkoutSessionResult? completedResult,
    String? errorMessage,
    String? setSaveError,
    bool clearError = false,
    bool clearSetSaveError = false,
  }) {
    return WorkoutSessionState(
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSet: currentSet ?? this.currentSet,
      totalSetsPerExercise: totalSetsPerExercise ?? this.totalSetsPerExercise,
      remainingRestSeconds: remainingRestSeconds ?? this.remainingRestSeconds,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      isTimerPaused: isTimerPaused ?? this.isTimerPaused,
      elapsedWorkoutSeconds: elapsedWorkoutSeconds ?? this.elapsedWorkoutSeconds,
      isSaving: isSaving ?? this.isSaving,
      isPreparing: isPreparing ?? this.isPreparing,
      completedSets: completedSets ?? this.completedSets,
      completedResult: completedResult ?? this.completedResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      setSaveError: clearSetSaveError
          ? null
          : (setSaveError ?? this.setSaveError),
    );
  }
}

/// Hasil persiapan sesi latihan.
sealed class SessionPreparationResult {
  const SessionPreparationResult();
}

/// Sesi siap dipakai (record in_progress aktif tersedia).
class SessionPrepared extends SessionPreparationResult {
  final String sessionId;
  const SessionPrepared(this.sessionId);
}

/// Ada sesi in_progress lain (jadwal/program berbeda). User harus memilih:
/// lanjutkan sesi lama atau akhiri dulu sebelum mulai yang baru.
class SessionConflict extends SessionPreparationResult {
  final String existingSessionId;
  final String existingProgramId;
  final int existingDayNumber;
  final String existingProgramTitle;
  final DateTime existingScheduledDate;

  const SessionConflict({
    required this.existingSessionId,
    required this.existingProgramId,
    required this.existingDayNumber,
    required this.existingProgramTitle,
    required this.existingScheduledDate,
  });
}

/// Persiapan gagal (mis. database error). Layar menampilkan tombol retry.
class SessionPreparationFailed extends SessionPreparationResult {
  final String message;
  const SessionPreparationFailed(this.message);
}
