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
  final WorkoutSessionResult? completedResult;
  final String? errorMessage;

  const WorkoutSessionState({
    this.currentExerciseIndex = 0,
    this.currentSet = 1,
    this.totalSetsPerExercise = 3,
    this.remainingRestSeconds = 60,
    this.defaultRestSeconds = 60,
    this.isTimerPaused = false,
    this.elapsedWorkoutSeconds = 0,
    this.isSaving = false,
    this.completedResult,
    this.errorMessage,
  });

  bool get isLastExercise => false; // Diatur dinamis oleh controller

  WorkoutSessionState copyWith({
    int? currentExerciseIndex,
    int? currentSet,
    int? totalSetsPerExercise,
    int? remainingRestSeconds,
    int? defaultRestSeconds,
    bool? isTimerPaused,
    int? elapsedWorkoutSeconds,
    bool? isSaving,
    WorkoutSessionResult? completedResult,
    String? errorMessage,
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
      completedResult: completedResult ?? this.completedResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

