import 'dart:async';

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
  final List<WorkoutSetEntity> _recordedSets = [];

  /// Batas maksimum durasi yang dipulihkan saat resume, agar sesi yang
  /// tertinggal berhari-hari tidak menghasilkan durasi tidak masuk akal.
  static const int _maxRestoredElapsedSeconds = 4 * 60 * 60;

  DateTime _startedAt = DateTime.now();
  String? _sessionId;

  WorkoutSessionController({required this._repository, required this._ref})
    : super(const WorkoutSessionState());

  String? get sessionId => _sessionId;

  /// Menyiapkan sesi aktif: melanjutkan record in_progress yang cocok, atau
  /// membuat record baru. Set yang sudah tercatat dipulihkan agar user tidak
  /// mengulang latihan dari awal.
  Future<String?> prepareSession({
    required String programId,
    required int dayNumber,
    required String programTitle,
    required DateTime scheduledDate,
    required List<String> exerciseIds,
    String? resumeSessionId,
  }) async {
    try {
      var session = await _repository.getActiveInProgressSession();
      if (!mounted) return null;

      final canResume =
          session != null &&
          (resumeSessionId == null || session.id == resumeSessionId) &&
          session.programId == programId &&
          session.programDayId == dayNumber &&
          _isSameDate(session.scheduledDate, scheduledDate);

      if (!canResume) {
        // Sesi lama untuk jadwal lain tidak boleh menggantung sebagai
        // in_progress selamanya.
        if (session != null) {
          await _repository.abandonSession(session.id);
        }
        session = await _repository.startWorkoutSession(
          programId: programId,
          dayNumber: dayNumber,
          programTitle: programTitle,
          scheduledDate: scheduledDate,
        );
      }

      _sessionId = session.id;
      _startedAt = session.startedAt;

      final sets = await _repository.getSetsForSession(session.id);
      if (!mounted) return session.id;

      _recordedSets
        ..clear()
        ..addAll(
          sets.where((set) => set.status == WorkoutSetStatus.completed),
        );

      final elapsed = DateTime.now().difference(session.startedAt).inSeconds;
      state = state.copyWith(
        elapsedWorkoutSeconds: elapsed.clamp(0, _maxRestoredElapsedSeconds),
      );
      _restorePosition(exerciseIds);

      return session.id;
    } catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        errorMessage: 'Gagal memulai sesi latihan: $error',
      );
      return null;
    }
  }

  /// Menentukan posisi exercise/set terakhir berdasarkan log yang tersimpan.
  void _restorePosition(List<String> exerciseIds) {
    if (exerciseIds.isEmpty) return;

    final completedPerExercise = <String, int>{};
    for (final set in _recordedSets) {
      completedPerExercise.update(
        set.exerciseId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    var index = 0;
    var currentSet = 1;
    var found = false;
    for (var i = 0; i < exerciseIds.length; i++) {
      final done = completedPerExercise[exerciseIds[i]] ?? 0;
      if (done >= state.totalSetsPerExercise) continue;
      index = i;
      currentSet = done + 1;
      found = true;
      break;
    }

    // Semua set sudah tercatat (mis. aplikasi tertutup tepat sebelum sesi
    // disimpan tuntas): tampilkan posisi terakhir tanpa melewati batas.
    if (!found) {
      index = exerciseIds.length - 1;
      currentSet = state.totalSetsPerExercise;
    }

    state = state.copyWith(
      currentExerciseIndex: index,
      currentSet: currentSet,
    );
  }

  /// Mencatat hasil set aktual & RIR (Fase 3: Set-by-Set Tracking).
  ///
  /// Set langsung disimpan ke database supaya sesi bisa dilanjutkan.
  void recordSetPerformance({
    required String exerciseId,
    required int setNumber,
    required int actualReps,
    int? targetReps,
    required int rir,
    double formScore = 1.0,
  }) {
    final sessionId = _sessionId;
    final set = WorkoutSetEntity(
      id: sessionId != null
          ? '${sessionId}_${exerciseId}_$setNumber'
          : 'pending_${exerciseId}_$setNumber',
      sessionId: sessionId ?? '',
      exerciseId: exerciseId,
      setNumber: setNumber,
      targetReps: targetReps,
      actualReps: actualReps,
      rir: rir,
      formScore: formScore,
      status: WorkoutSetStatus.completed,
    );

    _recordedSets
      ..removeWhere(
        (existing) =>
            existing.exerciseId == exerciseId &&
            existing.setNumber == setNumber,
      )
      ..add(set);

    if (sessionId != null) {
      unawaited(_repository.saveSetLog(set));
    }
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
        sessionId: _sessionId,
      );

      // Record in_progress sudah di-update menjadi completed; jangan update
      // ulang record yang sama pada sesi berikutnya.
      _sessionId = null;
      _recordedSets.clear();
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

  /// Menandai sesi aktif sebagai abandoned saat user keluar tanpa menyimpan.
  Future<void> abandonActiveSession() async {
    final id = _sessionId;
    _sessionId = null;
    if (id == null) return;
    await _repository.abandonSession(id);
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
