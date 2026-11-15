import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/workout_session_entity.dart';
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

  /// Batas maksimum durasi yang dipulihkan saat resume untuk record LAMA
  /// (sebelum kolom elapsed_seconds ada). Record baru memakai waktu aktif
  /// yang tersimpan, bukan selisih wall-clock.
  static const int _maxLegacyRestoredElapsedSeconds = 90 * 60;

  /// Interval persistensi waktu aktif saat sesi berjalan.
  static const int _elapsedPersistEverySeconds = 30;

  DateTime _startedAt = DateTime.now();
  String? _sessionId;

  WorkoutSessionController({required this._repository, required this._ref})
    : super(const WorkoutSessionState());

  String? get sessionId => _sessionId;

  /// Menyiapkan sesi aktif: melanjutkan record in_progress yang cocok, atau
  /// membuat record baru. Set yang sudah tercatat dipulihkan agar user tidak
  /// mengulang latihan dari awal.
  ///
  /// Jika ada sesi in_progress lain (program/jadwal berbeda), sesi itu TIDAK
  /// diubah sama sekali — user diberi pilihan lewat [SessionConflict].
  Future<SessionPreparationResult> prepareSession({
    required String programId,
    required int dayNumber,
    required String programTitle,
    required DateTime scheduledDate,
    required List<String> exerciseIds,
    String? resumeSessionId,
  }) async {
    state = state.copyWith(isPreparing: true, clearError: true);

    try {
      final existing = await _repository.getActiveInProgressSession();
      if (!mounted) return const SessionPreparationFailed('unmounted');

      final canReuse =
          existing != null &&
          (resumeSessionId == null || existing.id == resumeSessionId) &&
          existing.programId == programId &&
          existing.programDayId == dayNumber &&
          _isSameDate(existing.scheduledDate, scheduledDate);

      if (existing != null && !canReuse) {
        return SessionConflict(
          existingSessionId: existing.id,
          existingProgramId: existing.programId,
          existingDayNumber: existing.programDayId,
          existingProgramTitle: existing.programTitle,
        );
      }

      final session = canReuse
          ? existing
          : await _repository.startWorkoutSession(
              programId: programId,
              dayNumber: dayNumber,
              programTitle: programTitle,
              scheduledDate: scheduledDate,
            );

      return await _activateSession(session, exerciseIds);
    } catch (error) {
      if (!mounted) return const SessionPreparationFailed('unmounted');
      state = state.copyWith(
        isPreparing: false,
        errorMessage: 'Gagal memulai sesi latihan: $error',
      );
      return SessionPreparationFailed('$error');
    }
  }

  /// Melanjutkan sesi in_progress yang sudah ada (dipilih user saat konflik).
  Future<SessionPreparationResult> resumeExistingSession({
    required String sessionId,
    required List<String> exerciseIds,
  }) async {
    try {
      final session = await _repository.getActiveInProgressSession();
      if (!mounted) return const SessionPreparationFailed('unmounted');
      if (session == null || session.id != sessionId) {
        return const SessionPreparationFailed('Sesi tidak ditemukan');
      }
      return await _activateSession(session, exerciseIds);
    } catch (error) {
      if (!mounted) return const SessionPreparationFailed('unmounted');
      state = state.copyWith(
        isPreparing: false,
        errorMessage: 'Gagal melanjutkan sesi latihan: $error',
      );
      return SessionPreparationFailed('$error');
    }
  }

  /// Mengakhiri sesi in_progress yang konflik, lalu membuat sesi baru untuk
  /// jadwal saat ini (dipilih user saat konflik).
  Future<SessionPreparationResult> discardConflictingAndStart({
    required String conflictingSessionId,
    required String programId,
    required int dayNumber,
    required String programTitle,
    required DateTime scheduledDate,
    required List<String> exerciseIds,
  }) async {
    try {
      await _repository.abandonSession(conflictingSessionId);
      final session = await _repository.startWorkoutSession(
        programId: programId,
        dayNumber: dayNumber,
        programTitle: programTitle,
        scheduledDate: scheduledDate,
      );
      return await _activateSession(session, exerciseIds);
    } catch (error) {
      if (!mounted) return const SessionPreparationFailed('unmounted');
      state = state.copyWith(
        isPreparing: false,
        errorMessage: 'Gagal memulai sesi latihan: $error',
      );
      return SessionPreparationFailed('$error');
    }
  }

  /// Mengaktifkan sesi: pulihkan posisi, set tercatat, dan waktu aktif.
  Future<SessionPreparationResult> _activateSession(
    WorkoutSessionEntity session,
    List<String> exerciseIds,
  ) async {
    _sessionId = session.id;
    _startedAt = session.startedAt;

    final sets = await _repository.getSetsForSession(session.id);
    if (!mounted) return SessionPrepared(session.id);

    _recordedSets
      ..clear()
      ..addAll(sets.where((set) => set.status == WorkoutSetStatus.completed));

    // Waktu aktif tersimpan lebih diutamakan; wall-clock hanya fallback
    // untuk record lama yang belum punya kolom elapsed_seconds.
    final wallClockSeconds = DateTime.now()
        .difference(session.startedAt)
        .inSeconds
        .clamp(0, _maxLegacyRestoredElapsedSeconds);
    final restoredElapsed = session.elapsedSeconds > 0
        ? session.elapsedSeconds
        : wallClockSeconds;

    state = state.copyWith(
      elapsedWorkoutSeconds: restoredElapsed,
      completedSets: _recordedSets.length,
      isPreparing: false,
      clearError: true,
    );
    _restorePosition(exerciseIds);

    return SessionPrepared(session.id);
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
  /// Set langsung disimpan ke database (di-await) supaya sesi bisa
  /// dilanjutkan tanpa kehilangan set terakhir. Dipanggil hanya setelah
  /// persiapan sesi selesai; tanpa sessionId set TIDAK dicatat.
  Future<void> recordSetPerformance({
    required String exerciseId,
    required int setNumber,
    required int actualReps,
    int? targetReps,
    required int rir,
    double formScore = 1.0,
  }) async {
    final sessionId = _sessionId;
    if (sessionId == null) return;

    final set = WorkoutSetEntity(
      id: '${sessionId}_${exerciseId}_$setNumber',
      sessionId: sessionId,
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

    state = state.copyWith(completedSets: _recordedSets.length);

    try {
      await _repository.saveSetLog(set);
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          errorMessage: 'Gagal menyimpan set latihan: $error',
        );
      }
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
    if (!state.isSessionReady || state.isTimerPaused) return false;

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

    // Persist waktu aktif berkala agar resume menghitung durasi dari
    // progres nyata, bukan selisih wall-clock sejak sesi dibuat.
    final id = _sessionId;
    if (id != null && newElapsed % _elapsedPersistEverySeconds == 0) {
      unawaited(
        _repository.updateSessionProgress(id, elapsedSeconds: newElapsed),
      );
    }
    return false;
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
      // Hitung dari catatan aktual, bukan posisi exercise/set saat ini.
      final totalCompletedSets = _recordedSets.length;
      final duration = state.elapsedWorkoutSeconds;

      final result = await _repository.completeWorkoutSession(
        programId: programId,
        dayNumber: dayNumber,
        programTitle: programTitle,
        durationSeconds: duration,
        completedSets: totalCompletedSets,
        totalExercises: totalExercises,
        startedAt: _startedAt,
        setLogs: List<WorkoutSetEntity>.from(_recordedSets),
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
