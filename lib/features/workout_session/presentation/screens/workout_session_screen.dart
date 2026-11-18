import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../i18n/strings.g.dart';
import '../../../exercises/domain/extensions/localized_string_extension.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../program/domain/models/program_day.dart';
import '../controllers/workout_session_controller.dart';
import '../controllers/workout_session_state.dart';
import '../../domain/models/exercise_prescription.dart';
import '../../domain/services/workout_prescription_resolver.dart';
import '../widgets/active_workout_content.dart';
import '../widgets/conflict_session_dialog.dart';
import '../widgets/set_completion_rir_sheet.dart';
import '../widgets/workout_complete_celebration.dart';
import '../widgets/workout_options_sheet.dart';
import '../widgets/workout_session_empty_state.dart';
import '../widgets/workout_session_overlay.dart';
import 'rest_timer_screen.dart';

/// Layar Active Workout (Mockup 1:1 Resolusi Tinggi):
/// - Presentation Layer murni (ConsumerStatefulWidget) dengan Riverpod 2.x
/// - Terhubung ke WorkoutSessionController untuk sinkronisasi SQLite lokal & Supabase Cloud
/// - Komposisi UI dipecah ke widgets/ (overlay, selebrasi, opsi, dialog konflik)
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final ProgramDay day;
  final List<Exercise> exercises;
  final String? programId;

  /// Tanggal jadwal sesi (bukan selalu hari ini).
  final DateTime? scheduledDate;

  /// Sesi in_progress yang harus dilanjutkan.
  final String? activeSessionId;

  /// Preskripsi per exerciseId (target set, reps, rest).
  final Map<String, WorkoutExercisePrescription> prescriptions;

  const WorkoutSessionScreen({
    super.key,
    required this.day,
    required this.exercises,
    this.programId,
    this.scheduledDate,
    this.activeSessionId,
    this.prescriptions = const {},
  });

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _currentSetValue = 0;
  bool _pendingFinishIsEndingEarly = false;
  bool _isFinishingSession = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercises.isEmpty) return;

    // Persist waktu aktif saat aplikasi berpindah ke background/tertutup.
    WidgetsBinding.instance.addObserver(this);
    // Jaga layar tetap menyala saat latihan berlangsung
    WakelockPlus.enable();
    // Timer & kontrol workout hanya aktif SETELAH persiapan sesi selesai.
    // Menjalankan di postFrameCallback memastikan build() sudah memanggil
    // ref.watch sehingga controller autoDispose tidak di-dispose prematur,
    // serta context navigator siap untuk menampilkan dialog jika ada konflik.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _prepareSession();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Simpan akumulasi waktu aktif sebelum sesi "hilang" dari latar depan.
      ref.read(workoutSessionControllerProvider.notifier).persistElapsedNow();
    }
  }

  @override
  void dispose() {
    if (widget.exercises.isNotEmpty) {
      WidgetsBinding.instance.removeObserver(this);
      ref.read(workoutSessionControllerProvider.notifier).persistElapsedNow();
      _timer?.cancel();
      WakelockPlus.disable();
    }
    super.dispose();
  }

  /// Resolver preskripsi per exercise (pure logic, bisa di-subclass di test).
  WorkoutPrescriptionResolver get _resolver => WorkoutPrescriptionResolver(
    day: widget.day,
    exercises: widget.exercises,
    explicitPrescriptions: widget.prescriptions,
  );

  /// Nama exercise sesuai bahasa aktif, dengan fallback bila terjemahan kosong.
  String _exerciseName(Exercise exercise) =>
      exercise.name.localized(LocaleSettings.currentLocale.languageCode);

  String get _programTitle {
    final title = widget.day.focus.localized(
      LocaleSettings.currentLocale.languageCode,
    );
    if (title.isNotEmpty) return title;
    return LocaleSettings.currentLocale.languageCode.startsWith('id')
        ? 'Latihan Kekuatan'
        : 'Upper Body Strength';
  }

  int get _totalExercises => widget.exercises.length;

  Exercise _getCurrentExercise(int currentIndex) {
    if (widget.exercises.isEmpty) {
      throw StateError('Cannot get exercise from an empty exercise list.');
    }
    final clampedIndex = currentIndex.clamp(0, widget.exercises.length - 1);
    return widget.exercises[clampedIndex];
  }

  /// Membuat record in_progress atau memulihkan sesi yang sudah berjalan,
  /// sehingga user tidak mengulang latihan dari awal setelah aplikasi tertutup.
  Future<void> _prepareSession() async {
    if (widget.exercises.isEmpty) return;
    try {
      final notifier = ref.read(workoutSessionControllerProvider.notifier);

      final result = await notifier.prepareSession(
        programId: widget.programId ?? 'upper_body_strength',
        dayNumber: widget.day.day,
        programTitle: _programTitle,
        scheduledDate: widget.scheduledDate ?? DateTime.now(),
        exerciseIds: widget.exercises.map((exercise) => exercise.id).toList(),
        prescriptions: _resolver.buildAll(),
        resumeSessionId: widget.activeSessionId,
      );

      if (!mounted) return;

      switch (result) {
        case SessionPrepared():
          _startTimer();
        case SessionConflict():
          await _handleConflictingSession(result);
        case SessionPreparationFailed():
          break; // State sudah berisi error; UI menampilkan tombol retry.
      }
    } catch (e, stack) {
      debugPrint('[WorkoutSessionScreen] Error in _prepareSession: $e\n$stack');
    }
  }

  /// Ada sesi in_progress lain (program/jadwal berbeda). Sesi lama TIDAK
  /// otomatis di-abandon: user memilih melanjutkan atau mengakhirinya.
  Future<void> _handleConflictingSession(SessionConflict conflict) async {
    final choice = await ConflictSessionDialog.show(
      context,
      programTitle: conflict.existingProgramTitle,
      dayNumber: conflict.existingDayNumber,
    );

    if (!mounted) return;
    final notifier = ref.read(workoutSessionControllerProvider.notifier);

    if (choice == 'resume') {
      // Ganti layar ini dengan detail sesi LAMA: tombolnya jadi "Lanjutkan
      // Latihan" (activeSessionId) sehingga sesi lama benar-benar dilanjutkan,
      // bukan sekadar menutup layar.
      context.pushReplacement(
        AppRoutes.workoutDetail,
        extra: WorkoutDetailArgs(
          dayNumber: conflict.existingDayNumber,
          programId: conflict.existingProgramId,
          weekDayText: 'Hari ${conflict.existingDayNumber}',
          workoutTitle: conflict.existingProgramTitle,
          targetMusclesText: conflict.existingProgramTitle,
          scheduledDate: conflict.existingScheduledDate,
          activeSessionId: conflict.existingSessionId,
        ),
      );
      return;
    }

    if (choice == 'discard') {
      final result = await notifier.discardConflictingAndStart(
        conflictingSessionId: conflict.existingSessionId,
        programId: widget.programId ?? 'upper_body_strength',
        dayNumber: widget.day.day,
        programTitle: _programTitle,
        scheduledDate: widget.scheduledDate ?? DateTime.now(),
        exerciseIds: widget.exercises.map((exercise) => exercise.id).toList(),
        prescriptions: _resolver.buildAll(),
      );
      if (!mounted) return;
      if (result is SessionPrepared) {
        _startTimer();
      }
      return;
    }

    // Jika user menutup dialog tanpa memilih opsi (misal back button Android),
    // kembali ke halaman sebelumnya agar tidak stuck di loading overlay.
    context.pop();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      // Menghitung durasi sesi; countdown hanya berjalan pada fase Rest.
      ref
          .read(workoutSessionControllerProvider.notifier)
          .tickTimer(totalExercises: _totalExercises);
    });
  }

  Future<void> _onNextPressed(int actualValue) async {
    final t = Translations.of(context);
    final controller = ref.read(workoutSessionControllerProvider.notifier);
    final currentState = ref.read(workoutSessionControllerProvider);
    if (_isFinishingSession || currentState.isSaving) return;
    controller.clearError();
    if (!currentState.isSessionReady) return;

    final state = ref.read(workoutSessionControllerProvider);
    final currentExercise = _getCurrentExercise(state.currentExerciseIndex);
    final prescription = _resolver.forExercise(currentExercise.id);
    final isDuration =
        currentExercise.trackingType == TrackingType.duration ||
        prescription.isDuration;

    SetCompletionRirSheet.show(
      context: context,
      setNumber: state.currentSet,
      totalSets: state.totalSetsPerExercise,
      exerciseName: _exerciseName(currentExercise),
      targetReps: prescription.maxReps,
      restSeconds: prescription.restSeconds,
      isDuration: isDuration,
      targetDurationSeconds: prescription.targetDurationSeconds,
      initialValue: actualValue,
      onConfirm:
          ({
            actualReps,
            durationSeconds,
            required rir,
            required formScore,
          }) async {
            final saved = await controller.recordSetPerformance(
              exerciseId: currentExercise.id,
              setNumber: state.currentSet,
              actualReps: isDuration ? null : actualReps,
              targetReps: isDuration ? null : prescription.maxReps,
              durationSeconds: isDuration ? durationSeconds : null,
              rir: rir,
              formScore: formScore,
            );
            if (!mounted) return;

            if (!saved) {
              AppSnackBar.showError(context, t.workoutSession.saveSetFailed);
              return;
            }

            final isFinished = controller.nextPressed(
              totalExercises: _totalExercises,
            );

            if (isFinished) {
              _timer?.cancel();
              _showWorkoutCompleteCelebrationModal();
            } else {
              controller.startRest();
            }
          },
    );
  }

  /// Modal Selebrasi saat semua latihan hari itu tuntas.
  void _showWorkoutCompleteCelebrationModal() {
    _timer?.cancel();
    final sessionState = ref.read(workoutSessionControllerProvider);
    WorkoutCompleteCelebration.show(
      context,
      durationMinutes: (sessionState.elapsedWorkoutSeconds / 60).ceil(),
      totalSetsDone: sessionState.completedSets,
      totalExercises: _totalExercises,
      onViewSummary: () {
        if (!mounted) return;
        _openSummaryScreen();
      },
    );
  }

  Future<String> _loadSummaryUserName() async {
    try {
      final profile = await ref
          .read(userProfileRepositoryProvider)
          .getUserProfile();
      final displayName = profile.displayName.trim();
      return displayName.isNotEmpty ? displayName : 'athlete';
    } catch (_, stackTrace) {
      // Profile data is optional for a completed workout; keep the summary
      // available with a generic greeting when the profile cannot be loaded.
      debugPrintStack(
        label: '[WorkoutSessionScreen] Profile unavailable for summary greeting',
        stackTrace: stackTrace,
      );
      return 'athlete';
    }
  }

  Future<void> _openSummaryScreen({bool isEndingEarly = false}) async {
    final sessionState = ref.read(workoutSessionControllerProvider);
    if (sessionState.isSaving ||
        sessionState.completedResult != null ||
        _isFinishingSession) {
      return;
    }

    setState(() => _isFinishingSession = true);
    _pendingFinishIsEndingEarly = isEndingEarly;
    _timer?.cancel();

    try {
      final controller = ref.read(workoutSessionControllerProvider.notifier);
      // Snapshot from the already-restored in-memory set log. Never query the
      // repository after completion, when the active session is already closed.
      final completedExercisesCount = controller.completedExerciseCount;
      final programTitle = _programTitle;

      // Complete the workout before attempting any optional profile read.
      final result = await controller.finishWorkoutSession(
        programId: widget.programId ?? 'upper_body_strength',
        dayNumber: widget.day.day,
        programTitle: programTitle,
        totalExercises: _totalExercises,
        isEndingEarly: isEndingEarly,
      );

      if (!mounted) return;
      if (result == null) {
        // Finalization failed and the session is still active. Resume elapsed
        // time while the user decides to retry or leave the workout.
        _startTimer();
        return;
      }

      // Profile is presentation-only. Bound the optional local/cloud lookup
      // so it cannot hold the user on a completed workout indefinitely.
      final userName = await _loadSummaryUserName().timeout(
        const Duration(seconds: 2),
        onTimeout: () => 'athlete',
      );
      if (!mounted) return;

      final exercisesCountText = isEndingEarly
          ? '$completedExercisesCount / $_totalExercises'
          : '$_totalExercises / $_totalExercises';

      context.pushReplacement(
        AppRoutes.workoutSummary,
        extra: WorkoutSummaryArgs(
          userName: userName,
          workoutTitle: programTitle,
          weekDayText: 'Week ${widget.day.week} • Day ${widget.day.day}',
          durationText: '${result.durationMinutes} min',
          exercisesCountText: exercisesCountText,
          setsCountText: '${result.completedSets}',
          caloriesText: '≈ ${result.caloriesBurned} kcal',
          progressionDecisions: result.progressionDecisions,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isFinishingSession = false);
      }
    }
  }

  void _showOptionsSheet() {
    final sessionState = ref.read(workoutSessionControllerProvider);
    if (_isFinishingSession ||
        sessionState.isSaving ||
        sessionState.completedResult != null) {
      return;
    }

    final notifier = ref.read(workoutSessionControllerProvider.notifier);
    WorkoutOptionsSheet.show(
      context,
      onRestartRestTimer: notifier.resetCurrentSetTimer,
      onFinishNow: () => _openSummaryScreen(isEndingEarly: true),
      onExit: () async {
        final currentState = ref.read(workoutSessionControllerProvider);
        if (_isFinishingSession ||
            currentState.isSaving ||
            currentState.completedResult != null) {
          return;
        }
        await notifier.abandonActiveSession();
        if (mounted) context.pop();
      },
    );
  }

  void _skipRest() {
    ref.read(workoutSessionControllerProvider.notifier).skipRest();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exercises.isEmpty) {
      return WorkoutSessionEmptyState(programTitle: _programTitle);
    }

    final t = Translations.of(context);
    final sessionState = ref.watch(workoutSessionControllerProvider);
    final isFinishingSession = sessionState.isSaving || _isFinishingSession;
    final canCompleteSet = sessionState.isSessionReady && !isFinishingSession;
    final exercise = _getCurrentExercise(sessionState.currentExerciseIndex);
    final prescription = _resolver.forExercise(exercise.id);
    final isDuration =
        exercise.trackingType == TrackingType.duration ||
        prescription.isDuration;
    final targetValue = isDuration
        ? (prescription.targetDurationSeconds ?? 45)
        : prescription.maxReps;

    if (sessionState.phase == WorkoutSessionPhase.resting) {
      return PopScope<Object?>(
        canPop: !isFinishingSession,
        child: RestTimerScreen(
          nextExerciseName: _exerciseName(exercise),
          nextSet: sessionState.currentSet,
          totalSets: sessionState.totalSetsPerExercise,
          remainingSeconds: sessionState.remainingRestSeconds,
          totalSeconds: sessionState.restDurationSeconds,
          isPaused: sessionState.isTimerPaused,
          // Back arrow KELUAR dari layar sesi (sesi tetap in_progress dan bisa
          // dilanjutkan), bukan skip rest — itu tugas tombol Skip Rest.
          onExitSession: () {
            if (!isFinishingSession) context.pop();
          },
          onAdjustTime: ref
              .read(workoutSessionControllerProvider.notifier)
              .adjustRestSeconds,
          onPauseToggle: ref
              .read(workoutSessionControllerProvider.notifier)
              .togglePauseTimer,
          onSkipRest: _skipRest,
        ),
      );
    }

    return PopScope<Object?>(
      canPop: !isFinishingSession,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.darkCharcoal,
              size: 24,
            ),
            onPressed: isFinishingSession ? null : () => context.pop(),
          ),
          title: Text(
            t.workoutSession.exerciseProgress(
              current: sessionState.currentExerciseIndex + 1,
              total: _totalExercises,
            ),
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.darkCharcoal,
                size: 26,
              ),
              onPressed: isFinishingSession ? null : _showOptionsSheet,
            ),
          ],
        ),
        body: Stack(
          children: [
            ActiveWorkoutContent(
              sessionState: sessionState,
              exercise: exercise,
              prescription: prescription,
              totalExercises: _totalExercises,
              onRepCounterChanged: (value) => _currentSetValue = value,
              onFullscreen: () {
                if (!isFinishingSession) {
                  context.push(AppRoutes.exerciseDetail, extra: exercise);
                }
              },
            ),

            // Overlay persiapan / error / simpan (menutup kontrol sampai siap).
            if (sessionState.isPreparing)
              WorkoutSessionOverlay(
                phase: WorkoutSessionOverlayPhase.preparing,
                errorMessage: '',
                onRetry: _prepareSession,
              )
            else if (sessionState.errorMessage != null &&
                sessionState.completedResult == null)
              WorkoutSessionOverlay(
                phase: WorkoutSessionOverlayPhase.error,
                errorMessage: sessionState.errorMessage!,
                onRetry: _prepareSession,
              )
            else if (isFinishingSession)
              WorkoutSessionOverlay(
                phase: WorkoutSessionOverlayPhase.saving,
                errorMessage: '',
                onRetry: _prepareSession,
              ),
          ],
        ),
        bottomNavigationBar: sessionState.completionError != null
            ? _buildFinishFailureActions(sessionState)
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                  child: AppButton.primary(
                    text: t.workoutSession.completeSet,
                    icon: Icons.check_rounded,
                    isLoading: isFinishingSession,
                    onPressed: canCompleteSet
                        ? () => _onNextPressed(
                            _currentSetValue == 0 ? targetValue : _currentSetValue,
                          )
                        : null,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFinishFailureActions(WorkoutSessionState sessionState) {
    final t = Translations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.workoutSession.finishSessionFailed,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkCharcoal,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppButton.primary(
              text: t.workoutSession.retry,
              isLoading: sessionState.isSaving || _isFinishingSession,
              onPressed: sessionState.isSaving || _isFinishingSession
                  ? null
                  : () => _openSummaryScreen(
                      isEndingEarly: _pendingFinishIsEndingEarly,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
