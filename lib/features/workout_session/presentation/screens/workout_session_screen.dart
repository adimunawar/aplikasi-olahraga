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
import '../widgets/active_workout_header.dart';
import '../widgets/active_workout_video_card.dart';
import '../widgets/active_exercise_info_header.dart';
import '../widgets/active_workout_metrics_strip.dart';
import '../widgets/active_circular_timer_controls.dart';
import '../widgets/active_workout_up_next_card.dart';
import '../widgets/set_completion_rir_sheet.dart';

/// Layar Active Workout (Mockup 1:1 Resolusi Tinggi):
/// - Presentation Layer murni (ConsumerStatefulWidget) dengan Riverpod 2.x
/// - Terhubung ke WorkoutSessionController untuk sinkronisasi SQLite lokal & Supabase Cloud
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final ProgramDay day;
  final List<Exercise> exercises;

  const WorkoutSessionScreen({
    super.key,
    required this.day,
    required this.exercises,
  });

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Jaga layar tetap menyala saat latihan berlangsung
    WakelockPlus.enable();
    _startTimer();
  }

  @override
  void dispose() {
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

  void _onNextPressed() {
    final state = ref.read(workoutSessionControllerProvider);
    final currentExercise = _getCurrentExercise(state.currentExerciseIndex);

    // Buka Bottom Sheet pencatatan set & RIR (Fase 3: RIR & Performa Nyata)
    SetCompletionRirSheet.show(
      context: context,
      setNumber: state.currentSet,
      totalSets: state.totalSetsPerExercise,
      exerciseName: currentExercise.name.en.isNotEmpty
          ? currentExercise.name.en
          : currentExercise.name.id,
      targetReps: 10,
      restSeconds: state.defaultRestSeconds,
      onConfirm: ({required actualReps, required rir, required formScore}) {
        // 1. Catat performa set ke controller
        ref.read(workoutSessionControllerProvider.notifier).recordSetPerformance(
              exerciseId: currentExercise.id,
              setNumber: state.currentSet,
              actualReps: actualReps,
              targetReps: 10,
              rir: rir,
              formScore: formScore,
            );

        // 2. Maju ke set berikutnya / gerakan berikutnya
        final isFinished = ref
            .read(workoutSessionControllerProvider.notifier)
            .nextPressed(totalExercises: _totalExercises);

        if (isFinished) {
          _timer?.cancel();
          // Tampilkan modal perayaan tuntas (TIDAK langsung melempar user secara mendadak)
          _showWorkoutCompleteCelebrationModal();
        } else {
          // Beri feedback transisi jika berpindah ke gerakan berikutnya
          final newState = ref.read(workoutSessionControllerProvider);
          if (newState.currentExerciseIndex != state.currentExerciseIndex) {
            final nextEx = _getCurrentExercise(newState.currentExerciseIndex);
            final nextName = nextEx.name.en.isNotEmpty
                ? nextEx.name.en
                : nextEx.name.id;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.fitness_center_rounded,
                      color: AppColors.limeAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gerakan Selesai! Waktunya istirahat sebelum $nextName',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.darkCharcoal,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      },
    );
  }

  /// Modal Selebrasi saat semua latihan hari itu tuntas
  void _showWorkoutCompleteCelebrationModal() {
    _timer?.cancel();
    final sessionState = ref.read(workoutSessionControllerProvider);
    final durationMin = (sessionState.elapsedWorkoutSeconds / 60).ceil();
    final totalSetsDone = _totalExercises * sessionState.totalSetsPerExercise;

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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      Container(width: 1, height: 24, color: AppColors.neutral200),
                      _buildMiniStat(
                        icon: Icons.fitness_center_rounded,
                        label: 'Gerakan',
                        value: '$_totalExercises Gerakan',
                      ),
                      Container(width: 1, height: 24, color: AppColors.neutral200),
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

  Future<void> _openSummaryScreen() async {
    _timer?.cancel();

    final profile = await AppDatabase.instance.getUserProfile();
    final userName =
        profile.displayName.isNotEmpty ? profile.displayName : 'Adi';
    const programId = 'upper_body_strength';

    final programTitle = widget.day.focus.en.isNotEmpty
        ? widget.day.focus.en
        : (widget.day.focus.id.isNotEmpty
              ? widget.day.focus.id
              : 'Upper Body Strength');

    // 1. Simpan sesi melalui Riverpod Controller (otomatis simpan SQLite & Supabase Sync)
    final currentState = ref.read(workoutSessionControllerProvider);
    final curEx = _getCurrentExercise(currentState.currentExerciseIndex);

    final result = await ref
        .read(workoutSessionControllerProvider.notifier)
        .finishWorkoutSession(
          programId: programId,
          dayNumber: widget.day.day,
          programTitle: programTitle,
          totalExercises: _totalExercises,
          currentExerciseId: curEx.id,
        );

    if (!mounted) return;

    final durationText = result != null
        ? '${result.durationMinutes} min'
        : '25 min';
    final caloriesText = result != null
        ? '≈ ${result.caloriesBurned} kcal'
        : '≈ 185 kcal';
    final completedSetsText = result != null
        ? '${result.completedSets}'
        : '${_totalExercises * 3}';

    context.pushReplacement(
      AppRoutes.workoutSummary,
      extra: WorkoutSummaryArgs(
        userName: userName,
        workoutTitle: programTitle,
        weekDayText: 'Week ${widget.day.week} • Day ${widget.day.day}',
        durationText: durationText,
        exercisesCountText: '$_totalExercises / $_totalExercises',
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
              title: const Text('Reset Set Ini'),
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
                _openSummaryScreen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
              title: const Text(
                'Keluar Tanpa Menyimpan',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.pop();
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
      category: muscle.toLowerCase().contains('chest') ||
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
    final next = _getNextExercise(sessionState.currentExerciseIndex);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF141718),
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Workout',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF141718),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Color(0xFF141718),
              size: 26,
            ),
            onPressed: _showOptionsSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: Nama Program & Segmented Progress Bar
                ActiveWorkoutHeader(
                  workoutTitle: exercise.name.en,
                  currentExerciseIndex: sessionState.currentExerciseIndex,
                  totalExercises: _totalExercises,
                ),
                const SizedBox(height: 16),

                // 2. Video Preview Card Gerakan
                ActiveWorkoutVideoCard(
                  imageAsset: exercise.media.startPose.isNotEmpty
                      ? exercise.media.startPose
                      : 'assets/images/Detail Gerakan.png',
                  onFullscreen: () {
                    context.push(AppRoutes.exerciseDetail, extra: exercise);
                  },
                ),
                const SizedBox(height: 16),

                // 3. Info Gerakan: Judul, Tag Kategori, & How to do it
                ActiveExerciseInfoHeader(
                  exerciseName: exercise.name.en.isNotEmpty
                      ? exercise.name.en
                      : exercise.name.id,
                  categoryTag: exercise.primaryMuscles.isNotEmpty
                      ? exercise.primaryMuscles.first.en
                      : 'Chest',
                  onHowToDoIt: () {
                    context.push(AppRoutes.exerciseDetail, extra: exercise);
                  },
                ),
                const SizedBox(height: 16),

                // 4. Strip Metrik: Sets (1/3), Reps (8-12), Rest (60 sec)
                ActiveWorkoutMetricsStrip(
                  setsText:
                      '${sessionState.currentSet} / ${sessionState.totalSetsPerExercise}',
                  repsText: '8 – 12',
                  restText: '${sessionState.defaultRestSeconds} sec',
                ),
                const SizedBox(height: 24),

                // 5. Timer Lingkaran Hijau Lime & Kontrol Pause / Next
                ActiveCircularTimerControls(
                  totalSeconds: sessionState.defaultRestSeconds,
                  remainingSeconds: sessionState.remainingRestSeconds,
                  isPaused: sessionState.isTimerPaused,
                  onPauseToggle: () => ref
                      .read(workoutSessionControllerProvider.notifier)
                      .togglePauseTimer(),
                  onNext: _onNextPressed,
                ),
                const SizedBox(height: 18),

                // Tombol CTA Utama yang Jelas (AppButton.primary sesuai architecture.md)
                AppButton.primary(
                  text: sessionState.currentSet >= sessionState.totalSetsPerExercise
                      ? (next != null
                          ? 'Selesai Set ${sessionState.currentSet} & Lanjut ${next.name.en.isNotEmpty ? next.name.en : next.name.id} ➔'
                          : 'Selesaikan Latihan Hari Ini 🎉')
                      : 'Selesaikan Set ${sessionState.currentSet} (Catat Reps) ➔',
                  size: AppButtonSize.large,
                  onPressed: _onNextPressed,
                ),
                const SizedBox(height: 20),

                // 6. Up Next Card di Bawah
                if (next != null)
                  ActiveWorkoutUpNextCard(
                    nextExerciseName: next.name.en.isNotEmpty
                        ? next.name.en
                        : next.name.id,
                    nextCategoryTag: next.primaryMuscles.isNotEmpty
                        ? next.primaryMuscles.first.en
                        : 'Back',
                    nextThumbnailAsset: next.media.startPose.isNotEmpty
                        ? next.media.startPose
                        : 'assets/images/Detail Gerakan.png',
                    onTap: _onNextPressed,
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Loading Overlay saat menyimpan sesi ke SQLite & Supabase
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
    );
  }
}
