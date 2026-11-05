import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../plans/presentation/controllers/plans_controller.dart';
import '../../../progress/presentation/controllers/progress_controller.dart';
import '../../data/repositories/workout_session_repository_impl.dart';
import '../../domain/models/workout_session_result.dart';
import '../../domain/repositories/workout_session_repository.dart';
import 'workout_session_state.dart';

final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository>((ref) {
  return WorkoutSessionRepositoryImpl(
    localDatabase: AppDatabase.instance,
  );
});

final workoutSessionControllerProvider =
    StateNotifierProvider.autoDispose<WorkoutSessionController, WorkoutSessionState>((ref) {
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

  WorkoutSessionController({
    required this._repository,
    required this._ref,
  })  : super(const WorkoutSessionState());

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

  /// Menghitung detik berjalan untuk timer dan durasi latihan
  bool tickTimer({required int totalExercises}) {
    if (state.isTimerPaused) return false;

    final newElapsed = state.elapsedWorkoutSeconds + 1;

    if (state.remainingRestSeconds > 0) {
      state = state.copyWith(
        remainingRestSeconds: state.remainingRestSeconds - 1,
        elapsedWorkoutSeconds: newElapsed,
      );
      return false;
    } else {
      // Timer rest habis -> otomatis next
      return nextPressed(totalExercises: totalExercises);
    }
  }

  /// Menyelesaikan sesi latihan, menyimpan ke SQLite lokal & sync ke Supabase Cloud
  Future<WorkoutSessionResult?> finishWorkoutSession({
    required String programId,
    required int dayNumber,
    required String programTitle,
    required int totalExercises,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      final totalCompletedSets = (state.currentExerciseIndex * state.totalSetsPerExercise) + state.currentSet;
      final duration = state.elapsedWorkoutSeconds > 60 ? state.elapsedWorkoutSeconds : 25 * 60;

      final result = await _repository.completeWorkoutSession(
        programId: programId,
        dayNumber: dayNumber,
        programTitle: programTitle,
        durationSeconds: duration,
        completedSets: totalCompletedSets,
        totalExercises: totalExercises,
        startedAt: _startedAt,
      );

      state = state.copyWith(
        isSaving: false,
        completedResult: result,
      );

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
