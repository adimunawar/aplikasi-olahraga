import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
      final isFinished = ref
          .read(workoutSessionControllerProvider.notifier)
          .tickTimer(totalExercises: _totalExercises);

      if (isFinished) {
        _timer?.cancel();
        _openSummaryScreen();
      }
    });
  }

  void _onNextPressed() {
    final isFinished = ref
        .read(workoutSessionControllerProvider.notifier)
        .nextPressed(totalExercises: _totalExercises);

    if (isFinished) {
      _timer?.cancel();
      _openSummaryScreen();
    }
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
    final result = await ref
        .read(workoutSessionControllerProvider.notifier)
        .finishWorkoutSession(
          programId: programId,
          dayNumber: widget.day.day,
          programTitle: programTitle,
          totalExercises: _totalExercises,
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
                const SizedBox(height: 24),

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
