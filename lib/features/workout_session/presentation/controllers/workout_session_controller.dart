import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/workout_set_entity.dart';
import '../../../plans/presentation/controllers/plans_controller.dart';
import '../../../progress/presentation/controllers/progress_controller.dart';
import '../../data/repositories/workout_session_repository_impl.dart';
import '../../domain/models/workout_session_result.dart';
import '../../domain/repositories/workout_session_repository.dart';
import 'workout_session_state.dart';

final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>((
  ref,
) {
  return WorkoutSessionRepositoryImpl(localDatabase: AppDatabase.instance);
});

final workoutSessionControllerProvider =
    StateNotifierProvider.autoDispose<
      WorkoutSessionController,
      WorkoutSessionState
    >((ref) {
      return WorkoutSessionController(
        repository: ref.watch(workoutSessionRepositoryProvider),
        ref: ref,
      );
    });

/// Controller Orkestrasi Sesi Latihan Aktif (Riverpod StateNotifier)
class WorkoutSessionController extends StateNotifier<WorkoutSessionState> {
  final WorkoutSessionRepository _repository;
  final Ref _ref;
  final DateTime _startedAt = DateTime.now();
  final List<WorkoutSetEntity> _recordedSets = [];

  WorkoutSessionController({required this._repository, required this._ref})
    : super(const WorkoutSessionState());

  /// Mencatat hasil set aktual & RIR (Fase 3: Set-by-Set Tracking)
  void recordSetPerformance({
    required String exerciseId,
    required int setNumber,
    required int actualReps,
    int? targetReps,
    required int rir,
    double formScore = 1.0,
  }) {
    _recordedSets.add(
      WorkoutSetEntity(
        id: '',
        sessionId: '',
        exerciseId: exerciseId,
        setNumber: setNumber,
        targetReps: targetReps,
        actualReps: actualReps,
        rir: rir,
        formScore: formScore,
        status: WorkoutSetStatus.completed,
      ),
    );
  }

  /// Jeda atau lanjutkan timer
  void togglePauseTimer() {
    state = state.copyWith(isTimerPaused: !state.isTimerPaused);
  }

  /// Reset timer pada set yang sedang aktif
  void resetCurrentSetTimer() {
    state = state.copyWith(
      remainingRestSeconds: state.defaultRestSeconds,
      isTimerPaused: false,
    );
  }

  /// Berpindah ke set berikutnya atau gerakan berikutnya
  /// Mengembalikan `true` jika sesi latihan telah selesai seluruhnya
  bool nextPressed({required int totalExercises}) {
    if (state.currentSet < state.totalSetsPerExercise) {
      state = state.copyWith(
        currentSet: state.currentSet + 1,
        remainingRestSeconds: state.defaultRestSeconds,
        isTimerPaused: false,
      );
      return false;
    } else {
      // Pindah ke gerakan berikutnya
      if (state.currentExerciseIndex < totalExercises - 1) {
        state = state.copyWith(
          currentExerciseIndex: state.currentExerciseIndex + 1,
          currentSet: 1,
          remainingRestSeconds: state.defaultRestSeconds,
          isTimerPaused: false,
        );
        return false;
      } else {
        // Selesai seluruh latihan
        return true;
      }
    }
  }

  /// Menghitung detik berjalan untuk durasi latihan dan countdown timer istirahat
  /// (TIDAK BOLEH auto-advance atau auto-finish sendiri agar user punya kontrol penuh)
  bool tickTimer({required int totalExercises}) {
    if (state.isTimerPaused) return false;

    final newElapsed = state.elapsedWorkoutSeconds + 1;

    if (state.remainingRestSeconds > 0) {
      state = state.copyWith(
        remainingRestSeconds: state.remainingRestSeconds - 1,
        elapsedWorkoutSeconds: newElapsed,
      );
    } else {
      // Countdown istirahat habis: durasi total latihan tetap bertambah,
      // namun TIDAK melompat otomatis ke set/gerakan berikutnya.
      state = state.copyWith(elapsedWorkoutSeconds: newElapsed);
    }
    return false;
  }

  /// Menyelesaikan sesi latihan, menyimpan ke SQLite lokal & sync ke Supabase Cloud
  Future<WorkoutSessionResult?> finishWorkoutSession({
    required String programId,
    required int dayNumber,
    required String programTitle,
    required int totalExercises,
    String? currentExerciseId,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      final totalCompletedSets =
          (state.currentExerciseIndex * state.totalSetsPerExercise) +
          state.currentSet;
      final duration = state.elapsedWorkoutSeconds > 60
          ? state.elapsedWorkoutSeconds
          : 25 * 60;

      // Jika user memilih "Selesaikan Sesi Sekarang" sebelum sempat mencatat set individual,
      // sediakan set baseline default agar Coach Adi tetap memberikan evaluasi adaptif
      final logsToSave = List<WorkoutSetEntity>.from(_recordedSets);
      if (logsToSave.isEmpty) {
        final exId = (currentExerciseId != null && currentExerciseId.isNotEmpty)
            ? currentExerciseId
            : 'incline_push_up';
        logsToSave.add(
          WorkoutSetEntity(
            id: '',
            sessionId: '',
            exerciseId: exId,
            setNumber: 1,
            targetReps: 10,
            actualReps: 10,
            rir: 2,
            formScore: 1.0,
            status: WorkoutSetStatus.completed,
          ),
        );
      }

      final result = await _repository.completeWorkoutSession(
        programId: programId,
        dayNumber: dayNumber,
        programTitle: programTitle,
        durationSeconds: duration,
        completedSets: totalCompletedSets > 0
            ? totalCompletedSets
            : logsToSave.length,
        totalExercises: totalExercises,
        startedAt: _startedAt,
        setLogs: logsToSave,
      );

      state = state.copyWith(isSaving: false, completedResult: result);

      // Otomatis refresh state Plans & Progress agar centang hijau ✓ langsung muncul
      _ref.read(plansControllerProvider.notifier).loadPrograms();
      _ref.read(progressControllerProvider.notifier).loadProgress();

      return result;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan sesi latihan: $e',
      );
      return null;
    }
  }
}
