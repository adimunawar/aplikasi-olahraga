import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/workout_session_entity.dart';
import '../../../../core/database/models/workout_set_entity.dart';
import '../../../plans/presentation/controllers/plans_controller.dart';
import '../../../progress/presentation/controllers/progress_controller.dart';
import '../../data/repositories/workout_session_repository_impl.dart';
import '../../domain/models/exercise_prescription.dart';
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

  /// Batas wall-clock fallback: hanya dipercaya untuk sesi yang baru saja
  /// dibuka (mis. aplikasi tewas beberapa detik setelah mulai). Sesi yang
  /// sudah lama berhenti tidak boleh dihitung dari selisih wall-clock.
  static const int _maxRecentSessionFallbackSeconds = 5 * 60;

  /// Interval persistensi waktu aktif saat sesi berjalan.
  static const int _elapsedPersistEverySeconds = 30;

  static const WorkoutExercisePrescription _defaultPrescription = WorkoutExercisePrescription();

  DateTime _startedAt = DateTime.now();
  String? _sessionId;

  /// Urutan exercise sesi ini; kunci untuk preskripsi per exercise.
  List<String> _exerciseIds = const [];

  /// Preskripsi per exerciseId (target set, reps, rest).
  Map<String, WorkoutExercisePrescription> _prescriptions = const {};

  WorkoutSessionController({required this._repository, required this._ref})
    : super(const WorkoutSessionState());

  String? get sessionId => _sessionId;

  WorkoutExercisePrescription _prescriptionFor(String? exerciseId) {
    if (exerciseId == null) return _defaultPrescription;
    return _prescriptions[exerciseId] ?? _defaultPrescription;
  }

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
    Map<String, WorkoutExercisePrescription> prescriptions = const {},
    String? resumeSessionId,
  }) async {
    state = state.copyWith(isPreparing: true, clearError: true);
    _exerciseIds = List.unmodifiable(exerciseIds);
    _prescriptions = prescriptions;

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
          existingScheduledDate: existing.scheduledDate,
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
    Map<String, WorkoutExercisePrescription> prescriptions = const {},
  }) async {
    try {
      final session = await _repository.getActiveInProgressSession();
      if (!mounted) return const SessionPreparationFailed('unmounted');
      if (session == null || session.id != sessionId) {
        return const SessionPreparationFailed('Sesi tidak ditemukan');
      }
      _exerciseIds = List.unmodifiable(exerciseIds);
      _prescriptions = prescriptions;
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
    Map<String, WorkoutExercisePrescription> prescriptions = const {},
  }) async {
    try {
      _exerciseIds = List.unmodifiable(exerciseIds);
      _prescriptions = prescriptions;
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

    // Waktu aktif tersimpan lebih diutamakan. Wall-clock hanya fallback untuk
    // sesi yang baru saja dibuat/dihentikan (dalam batas beberapa menit);
    // sesi yang sudah lama berhenti mulai dari 0 agar waktu aplikasi
    // tertutup tidak ikut terhitung.
    final wallClockSeconds = DateTime.now()
        .difference(session.startedAt)
        .inSeconds;
    final restoredElapsed = session.elapsedSeconds > 0
        ? session.elapsedSeconds
        : (wallClockSeconds >= 0 &&
              wallClockSeconds <= _maxRecentSessionFallbackSeconds
              ? wallClockSeconds
              : 0);

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
  /// Set total set & rest juga mengikuti preskripsi exercise aktif.
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
    var totalSets = _prescriptionFor(exerciseIds.first).targetSets;
    var found = false;
    for (var i = 0; i < exerciseIds.length; i++) {
      final rx = _prescriptionFor(exerciseIds[i]);
      final done = completedPerExercise[exerciseIds[i]] ?? 0;
      if (done >= rx.targetSets) continue;
      index = i;
      currentSet = done + 1;
      totalSets = rx.targetSets;
      found = true;
      break;
    }

    // Semua set sudah tercatat (mis. aplikasi tertutup tepat sebelum sesi
    // disimpan tuntas): tampilkan posisi terakhir tanpa melewati batas.
    if (!found) {
      index = exerciseIds.length - 1;
      totalSets = _prescriptionFor(exerciseIds[index]).targetSets;
      currentSet = totalSets;
    }

    final rx = _prescriptionFor(exerciseIds[index]);
    state = state.copyWith(
      currentExerciseIndex: index,
      currentSet: currentSet,
      totalSetsPerExercise: totalSets,
      defaultRestSeconds: rx.restSeconds,
    );
  }

  /// Mencatat hasil set aktual & RIR (Fase 3: Set-by-Set Tracking).
  ///
  /// Set langsung disimpan ke database (di-await) supaya sesi bisa
  /// dilanjutkan tanpa kehilangan set terakhir. Mengembalikan `false` jika
  /// penyimpanan gagal — pemanggil TIDAK boleh memajukan posisi set.
  /// Dipanggil hanya setelah persiapan sesi selesai; tanpa sessionId set
  /// TIDAK dicatat.
  Future<bool> recordSetPerformance({
    required String exerciseId,
    required int setNumber,
    int? actualReps,
    int? targetReps,
    int? durationSeconds,
    required int rir,
    double formScore = 1.0,
  }) async {
    final sessionId = _sessionId;
    if (sessionId == null) return false;

    final set = WorkoutSetEntity(
      id: '${sessionId}_${exerciseId}_$setNumber',
      sessionId: sessionId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      targetReps: targetReps,
      actualReps: actualReps,
      durationSeconds: durationSeconds,
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

      // Piggyback: persist waktu aktif bersama set supaya sesi pendek
      // (kurang dari interval 30 detik) juga tercatat untuk resume.
      unawaited(
        _repository.updateSessionProgress(
          sessionId,
          elapsedSeconds: state.elapsedWorkoutSeconds,
        ),
      );

      if (mounted) {
        state = state.copyWith(clearError: true, clearSetSaveError: true);
      }
      return true;
    } catch (error) {
      // Rollback: set yang gagal tersimpan tidak dihitung selesai, dan
      // pemanggil tidak boleh memajukan posisi.
      _recordedSets.remove(set);
      if (mounted) {
        state = state.copyWith(
          completedSets: _recordedSets.length,
          setSaveError: 'Gagal menyimpan set latihan: $error',
        );
      }
      return false;
    }
  }

  /// Menyimpan akumulasi waktu aktif terkini ke database.
  /// Dipanggil saat lifecycle aplikasi berubah (pause/hidden) dan saat
  /// timer dijeda, agar sesi pendek tidak kehilangan durasinya.
  Future<void> persistElapsedNow() async {
    final id = _sessionId;
    if (id == null) return;
    try {
      await _repository.updateSessionProgress(
        id,
        elapsedSeconds: state.elapsedWorkoutSeconds,
      );
    } catch (_) {
      // Persist waktu aktif best-effort; jangan ganggu sesi.
    }
  }

  /// Membersihkan error pencatatan set agar user bisa mencoba lagi.
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Jeda atau lanjutkan timer
  void togglePauseTimer() {
    final nowPaused = !state.isTimerPaused;
    state = state.copyWith(isTimerPaused: nowPaused);
    // Saat user jeda, simpan waktu aktif terkini segera.
    if (nowPaused) {
      unawaited(persistElapsedNow());
    }
  }

  /// Reset countdown while the session is in its rest phase.
  void resetCurrentSetTimer() {
    state = state.copyWith(
      phase: WorkoutSessionPhase.resting,
      remainingRestSeconds: state.defaultRestSeconds,
      isTimerPaused: false,
    );
  }

  /// Start the rest phase after the set has been saved and the next position
  /// has been selected.
  void startRest() {
    final seconds = state.defaultRestSeconds.clamp(0, 600);
    state = state.copyWith(
      phase: seconds == 0
          ? WorkoutSessionPhase.active
          : WorkoutSessionPhase.resting,
      remainingRestSeconds: seconds,
      isTimerPaused: false,
    );
  }

  /// Return to the active exercise immediately.
  void skipRest() {
    state = state.copyWith(
      phase: WorkoutSessionPhase.active,
      remainingRestSeconds: 0,
      isTimerPaused: false,
    );
  }

  /// Add or subtract rest time without affecting elapsed workout time.
  void adjustRestSeconds(int delta) {
    if (state.phase != WorkoutSessionPhase.resting) return;
    final adjusted = (state.remainingRestSeconds + delta).clamp(0, 600).toInt();
    state = state.copyWith(
      remainingRestSeconds: adjusted,
      phase: adjusted == 0
          ? WorkoutSessionPhase.active
          : WorkoutSessionPhase.resting,
      isTimerPaused: adjusted == 0 ? false : state.isTimerPaused,
    );
  }

  /// Berpindah ke set berikutnya atau gerakan berikutnya.
  /// Rest & total set mengikuti preskripsi exercise yang aktif.
  /// Mengembalikan `true` jika sesi latihan telah selesai seluruhnya
  bool nextPressed({required int totalExercises}) {
    final ids = _exerciseIds;
    final total = ids.isNotEmpty ? ids.length : totalExercises;

    if (state.currentSet < state.totalSetsPerExercise) {
      state = state.copyWith(
        currentSet: state.currentSet + 1,
        remainingRestSeconds: state.defaultRestSeconds,
        isTimerPaused: false,
      );
      return false;
    } else {
      // Pindah ke gerakan berikutnya
      final nextIndex = state.currentExerciseIndex + 1;
      if (state.currentExerciseIndex < total - 1) {
        final nextRx = _prescriptionFor(
          ids.isNotEmpty ? ids[nextIndex] : null,
        );
        state = state.copyWith(
          currentExerciseIndex: nextIndex,
          currentSet: 1,
          totalSetsPerExercise: nextRx.targetSets,
          defaultRestSeconds: nextRx.restSeconds,
          remainingRestSeconds: nextRx.restSeconds,
          isTimerPaused: false,
        );
        return false;
      } else {
        // Selesai seluruh latihan
        return true;
      }
    }
  }

  /// Advance active workout time. The rest countdown only advances while
  /// the session is explicitly in the resting phase.
  bool tickTimer({required int totalExercises}) {
    if (!state.isSessionReady || state.isTimerPaused) return false;

    final newElapsed = state.elapsedWorkoutSeconds + 1;
    if (state.phase == WorkoutSessionPhase.resting) {
      final remaining = (state.remainingRestSeconds - 1).clamp(0, 600);
      state = state.copyWith(
        remainingRestSeconds: remaining,
        elapsedWorkoutSeconds: newElapsed,
        phase: remaining == 0
            ? WorkoutSessionPhase.active
            : WorkoutSessionPhase.resting,
        isTimerPaused: remaining == 0 ? false : state.isTimerPaused,
      );
    } else {
      state = state.copyWith(elapsedWorkoutSeconds: newElapsed);
    }

    // Persist elapsed workout time (including deliberate rest intervals).
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
    bool isEndingEarly = false,
  }) async {
    state = state.copyWith(isSaving: true);
    try {
      // Hitung dari catatan aktual, bukan posisi exercise/set saat ini.
      final totalCompletedSets = _recordedSets.length;
      final duration = state.elapsedWorkoutSeconds;

      final targetSetsPerExercise = <String, int>{
        for (final entry in _prescriptions.entries)
          entry.key: entry.value.targetSets,
      };

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
        isEndingEarly: isEndingEarly,
        targetSetsPerExercise: targetSetsPerExercise,
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
