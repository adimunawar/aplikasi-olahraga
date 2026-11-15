import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';
import '../controllers/workout_session_controller.dart';
import '../controllers/workout_session_state.dart';
import '../../domain/models/exercise_prescription.dart';
import '../widgets/active_workout_header.dart';
import '../widgets/active_workout_video_card.dart';
import '../widgets/active_workout_rep_counter.dart';
import '../widgets/set_completion_rir_sheet.dart';
import 'rest_timer_screen.dart';

/// Layar Active Workout (Mockup 1:1 Resolusi Tinggi):
/// - Presentation Layer murni (ConsumerStatefulWidget) dengan Riverpod 2.x
/// - Terhubung ke WorkoutSessionController untuk sinkronisasi SQLite lokal & Supabase Cloud
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

  @override
  void initState() {
    super.initState();
    // Persist waktu aktif saat aplikasi berpindah ke background/tertutup.
    WidgetsBinding.instance.addObserver(this);
    // Jaga layar tetap menyala saat latihan berlangsung
    WakelockPlus.enable();
    // Timer & kontrol workout hanya aktif SETELAH persiapan sesi selesai.
    _prepareSession();
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

  Exercise? _findExercise(String id) {
    return widget.exercises.where((e) => e.id == id).firstOrNull;
  }

  /// Preskripsi per exercise: mulai dari ProgramDay.items (sets/reps/rest),
  /// lalu timpa dengan preskripsi eksplisit dari args yang lebih akurat
  /// (punya rentang min/max reps).
  Map<String, WorkoutExercisePrescription> _buildPrescriptions() {
    final map = <String, WorkoutExercisePrescription>{
      for (final item in widget.day.items)
        item.exerciseId: WorkoutExercisePrescription.fromWorkoutItem(
          item,
          trackingType:
              _findExercise(item.exerciseId)?.trackingType ?? TrackingType.reps,
        ),
    };
    map.addAll(widget.prescriptions);
    return map;
  }

  WorkoutExercisePrescription _prescriptionFor(String exerciseId) {
    return widget.prescriptions[exerciseId] ??
        (widget.day.items
                .where((item) => item.exerciseId == exerciseId)
                .map(
                  (item) => WorkoutExercisePrescription.fromWorkoutItem(
                    item,
                    trackingType: _findExercise(item.exerciseId)?.trackingType ??
                        TrackingType.reps,
                  ),
                )
                .firstOrNull ??
            const WorkoutExercisePrescription());
  }

  /// Membuat record in_progress atau memulihkan sesi yang sudah berjalan,
  /// sehingga user tidak mengulang latihan dari awal setelah aplikasi tertutup.
  Future<void> _prepareSession() async {
    final notifier = ref.read(workoutSessionControllerProvider.notifier);

    final result = await notifier.prepareSession(
      programId: widget.programId ?? 'upper_body_strength',
      dayNumber: widget.day.day,
      programTitle: _programTitle,
      scheduledDate: widget.scheduledDate ?? DateTime.now(),
      exerciseIds: widget.exercises.map((exercise) => exercise.id).toList(),
      prescriptions: _buildPrescriptions(),
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
  }

  String get _programTitle {
    final focus = widget.day.focus;
    return focus.en.isNotEmpty
        ? focus.en
        : (focus.id.isNotEmpty ? focus.id : 'Upper Body Strength');
  }

  /// Ada sesi in_progress lain (program/jadwal berbeda). Sesi lama TIDAK
  /// otomatis di-abandon: user memilih melanjutkan atau mengakhirinya.
  Future<void> _handleConflictingSession(SessionConflict conflict) async {
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ada latihan yang belum selesai'),
        content: Text(
          'Kamu masih punya sesi "${conflict.existingProgramTitle}" '
          '(Hari ${conflict.existingDayNumber}) yang sedang berlangsung. '
          'Lanjutkan sesi itu dulu, atau akhiri untuk mulai latihan ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'resume'),
            child: const Text('Lanjutkan Sesi Lama'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'discard'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Akhiri Sesi Lama'),
          ),
        ],
      ),
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
        prescriptions: _buildPrescriptions(),
      );
      if (!mounted) return;
      if (result is SessionPrepared) {
        _startTimer();
      }
      // Gagal: state berisi error, UI menampilkan tombol retry.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(workoutSessionControllerProvider.notifier).persistElapsedNow();
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      // Hanya menghitung detik berjalan latihan (TIDAK auto-finish sesi)
      ref
          .read(workoutSessionControllerProvider.notifier)
          .tickTimer(totalExercises: _totalExercises);
    });
  }

  Future<void> _onNextPressed(int actualValue) async {
    final controller = ref.read(workoutSessionControllerProvider.notifier);
    controller.clearError();
    if (!ref.read(workoutSessionControllerProvider).isSessionReady) return;

    final state = ref.read(workoutSessionControllerProvider);
    final currentExercise = _getCurrentExercise(state.currentExerciseIndex);
    final prescription = _prescriptionFor(currentExercise.id);
    final isDuration =
        currentExercise.trackingType == TrackingType.duration ||
        prescription.isDuration;

    SetCompletionRirSheet.show(
      context: context,
      setNumber: state.currentSet,
      totalSets: state.totalSetsPerExercise,
      exerciseName: currentExercise.name.en.isNotEmpty
          ? currentExercise.name.en
          : currentExercise.name.id,
      targetReps: prescription.maxReps,
      restSeconds: prescription.restSeconds,
      isDuration: isDuration,
      targetDurationSeconds: prescription.targetDurationSeconds,
      initialValue: actualValue,
      onConfirm: ({actualReps, durationSeconds, required rir, required formScore}) async {
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
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Gagal menyimpan set. Periksa koneksi lalu coba lagi.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
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

  /// Modal Selebrasi saat semua latihan hari itu tuntas
  void _showWorkoutCompleteCelebrationModal() {
    _timer?.cancel();
    final sessionState = ref.read(workoutSessionControllerProvider);
    final durationMin = (sessionState.elapsedWorkoutSeconds / 60).ceil();
    final totalSetsDone = sessionState.completedSets;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Trophy / Medali
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F9ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 34,
                      color: Color(0xFF84CC16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Judul Selebrasi
                Text(
                  'Latihan Hari Ini Tuntas! 🎉',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.darkCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Deskripsi apresiasi
                Text(
                  'Semua set dan gerakan telah berhasil kamu selesaikan. Istirahatlah dengan baik untuk pemulihan otot.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // Ringkasan Cepat Mini
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat(
                        icon: Icons.access_time_rounded,
                        label: 'Durasi',
                        value: '$durationMin min',
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.neutral200,
                      ),
                      _buildMiniStat(
                        icon: Icons.fitness_center_rounded,
                        label: 'Gerakan',
                        value: '$_totalExercises Gerakan',
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.neutral200,
                      ),
                      _buildMiniStat(
                        icon: Icons.check_circle_rounded,
                        label: 'Total Set',
                        value: '$totalSetsDone Sets',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Tombol Lihat Ringkasan (AppButton.primary)
                AppButton.primary(
                  text: 'Lihat Ringkasan & Evaluasi ➔',
                  size: AppButtonSize.large,
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openSummaryScreen();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.greenDark),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral500,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: AppColors.darkCharcoal,
          ),
        ),
      ],
    );
  }

  int get _totalExercises =>
      widget.exercises.isNotEmpty ? widget.exercises.length : 5;

  Exercise _getCurrentExercise(int currentIndex) {
    if (widget.exercises.isNotEmpty && currentIndex < widget.exercises.length) {
      return widget.exercises[currentIndex];
    }
    return _buildFallbackExercise('Push-up', 'Chest');
  }

  Exercise? _getNextExercise(int currentIndex) {
    final nextIdx = currentIndex + 1;
    if (widget.exercises.isNotEmpty && nextIdx < widget.exercises.length) {
      return widget.exercises[nextIdx];
    }
    if (currentIndex < 4) {
      return _buildFallbackExercise('Superman Pull', 'Back');
    }
    return null;
  }

  Future<void> _openSummaryScreen({bool isEndingEarly = false}) async {
    _timer?.cancel();

    final profile = await AppDatabase.instance.getUserProfile();
    final userName = profile.displayName.isNotEmpty
        ? profile.displayName
        : 'Adi';
    final programId = widget.programId ?? 'upper_body_strength';
    final programTitle = _programTitle;

    // 1. Simpan sesi melalui Riverpod Controller (otomatis simpan SQLite & Supabase Sync)
    final result = await ref
        .read(workoutSessionControllerProvider.notifier)
        .finishWorkoutSession(
          programId: programId,
          dayNumber: widget.day.day,
          programTitle: programTitle,
          totalExercises: _totalExercises,
          isEndingEarly: isEndingEarly,
        );

    if (!mounted) return;

    final currentState = ref.read(workoutSessionControllerProvider);
    final durationText = result != null
        ? '${result.durationMinutes} min'
        : '${(currentState.elapsedWorkoutSeconds / 60).ceil()} min';
    final caloriesText = result != null
        ? '≈ ${result.caloriesBurned} kcal'
        : '≈ 0 kcal';
    final completedSetsText =
        '${result?.completedSets ?? currentState.completedSets}';

    // Hitung exercise unik yang benar-benar tercatat jika diselesaikan lebih awal
    int completedExercisesCount = _totalExercises;
    if (isEndingEarly && result != null) {
      final sets = await AppDatabase.instance.getSetsForSession(
        result.sessionId,
      );
      if (!mounted) return;
      completedExercisesCount = sets.map((s) => s.exerciseId).toSet().length;
    }

    final exercisesCountText = isEndingEarly
        ? '$completedExercisesCount / $_totalExercises'
        : '$_totalExercises / $_totalExercises';

    if (!mounted) return;
    context.pushReplacement(
      AppRoutes.workoutSummary,
      extra: WorkoutSummaryArgs(
        userName: userName,
        workoutTitle: programTitle,
        weekDayText: 'Week ${widget.day.week} • Day ${widget.day.day}',
        durationText: durationText,
        exercisesCountText: exercisesCountText,
        setsCountText: completedSetsText,
        caloriesText: caloriesText,
        progressionDecisions: result?.progressionDecisions ?? const [],
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Restart Rest Timer'),
              onTap: () {
                ref
                    .read(workoutSessionControllerProvider.notifier)
                    .resetCurrentSetTimer();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF65A30D),
              ),
              title: const Text(
                'Selesaikan Sesi Sekarang',
                style: TextStyle(
                  color: Color(0xFF65A30D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _openSummaryScreen(isEndingEarly: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
              title: const Text(
                'Keluar Tanpa Menyimpan',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await ref
                    .read(workoutSessionControllerProvider.notifier)
                    .abandonActiveSession();
                if (mounted) context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Exercise _buildFallbackExercise(String name, String muscle) {
    return Exercise(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: LocalizedString(id: name, en: name),
      category:
          muscle.toLowerCase().contains('chest') ||
              muscle.toLowerCase().contains('push')
          ? ExerciseCategory.push
          : muscle.toLowerCase().contains('leg')
          ? ExerciseCategory.legs
          : muscle.toLowerCase().contains('core')
          ? ExerciseCategory.core
          : ExerciseCategory.fullBody,
      difficulty: ExerciseDifficulty.intermediate,
      trackingType: TrackingType.reps,
      primaryMuscles: [LocalizedString(id: muscle, en: muscle)],
      stabilizerMuscles: const [LocalizedString(id: 'Core', en: 'Core')],
      steps: const LocalizedList(
        id: [
          'Posisikan tubuh dengan stabil dan rentang gerak penuh.',
          'Lakukan gerakan secara terkontrol dengan ritme teratur.',
        ],
        en: [
          'Maintain a stable posture and full range of motion.',
          'Execute the movement with controlled tempo.',
        ],
      ),
      commonMistakes: const LocalizedList(
        id: ['Menggunakan momentum alih-alih kekuatan otot.'],
        en: ['Using momentum instead of muscular control.'],
      ),
      breathing: const LocalizedString(
        id: 'Tarik napas saat menurunkan, hembuskan saat mendorong/menarik.',
        en: 'Inhale during lowering phase, exhale during exertion.',
      ),
      variations: const ExerciseVariationGroup(),
      media: const ExerciseMedia(
        startPose: 'assets/images/Detail Gerakan.png',
        endPose: 'assets/images/Detail Gerakan.png',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(workoutSessionControllerProvider);
    final exercise = _getCurrentExercise(sessionState.currentExerciseIndex);
    final prescription = _prescriptionFor(exercise.id);
    final isDuration =
        exercise.trackingType == TrackingType.duration ||
        prescription.isDuration;
    final targetValue = isDuration
        ? (prescription.targetDurationSeconds ?? 45)
        : prescription.maxReps;
    final valueLabel = isDuration ? '\${targetValue} sec' : '\${targetValue} reps';

    if (sessionState.phase == WorkoutSessionPhase.resting) {
      final nextExerciseName = exercise.name.en.isNotEmpty
          ? exercise.name.en
          : exercise.name.id;
      return RestTimerScreen(
        nextExerciseName: nextExerciseName,
        nextSet: sessionState.currentSet,
        totalSets: sessionState.totalSetsPerExercise,
        remainingSeconds: sessionState.remainingRestSeconds,
        totalSeconds: sessionState.defaultRestSeconds,
        isPaused: sessionState.isTimerPaused,
        onBack: _skipRest,
        onAdjustTime: ref
            .read(workoutSessionControllerProvider.notifier)
            .adjustRestSeconds,
        onPauseToggle: ref
            .read(workoutSessionControllerProvider.notifier)
            .togglePauseTimer,
        onSkipRest: _skipRest,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.darkCharcoal,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '\${sessionState.currentExerciseIndex + 1} of \$_totalExercises',
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
            onPressed: _showOptionsSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ActiveWorkoutHeader(
                  currentExerciseIndex: sessionState.currentExerciseIndex,
                  totalExercises: _totalExercises,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        exercise.name.en.isNotEmpty
                            ? exercise.name.en
                            : exercise.name.id,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.darkCharcoal,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Set \${sessionState.currentSet} of \${sessionState.totalSetsPerExercise} · $valueLabel',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ActiveWorkoutVideoCard(
                        imageAsset: exercise.media.startPose.isNotEmpty
                            ? exercise.media.startPose
                            : 'assets/images/Detail Gerakan.png',
                        onFullscreen: () {
                          context.push(AppRoutes.exerciseDetail, extra: exercise);
                        },
                      ),
                      const SizedBox(height: 28),
                      ActiveWorkoutRepCounter(
                        key: ValueKey(
                          '\${exercise.id}_\${sessionState.currentSet}',
                        ),
                        initialValue: targetValue,
                        isDuration: isDuration,
                        onChanged: (value) {
                          _currentSetValue = value;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildNextRestCard(sessionState.defaultRestSeconds),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (sessionState.isPreparing)
            Container(
              color: Colors.white.withValues(alpha: 0.85),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.limeAccent),
                    SizedBox(height: 14),
                    Text(
                      'Menyiapkan sesi latihan...',
                      style: TextStyle(
                        color: AppColors.darkCharcoal,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (!sessionState.isPreparing &&
              sessionState.errorMessage != null &&
              sessionState.completedResult == null)
            Container(
              color: Colors.white.withValues(alpha: 0.92),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 44,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        sessionState.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.darkCharcoal,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppButton.primary(
                        text: 'Coba Lagi',
                        onPressed: _prepareSession,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (sessionState.isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.limeAccent),
                    SizedBox(height: 14),
                    Text(
                      'Menyimpan sesi latihan...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: sessionState.isSessionReady &&
                      !sessionState.isSaving
                  ? () => _onNextPressed(_currentSetValue == 0
                      ? targetValue
                      : _currentSetValue)
                  : null,
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text(
                'Complete Set',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.limeAccent,
                foregroundColor: AppColors.darkCharcoal,
                disabledBackgroundColor: AppColors.neutral200,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _skipRest() {
    ref.read(workoutSessionControllerProvider.notifier).skipRest();
  }

  Widget _buildNextRestCard(int restSeconds) {
    final minutes = (restSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (restSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 18,
            color: AppColors.neutral600,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Next: Rest',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.darkCharcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$minutes:$seconds',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

}
