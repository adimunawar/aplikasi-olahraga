import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_app/core/database/models/dynamic_program_entity.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../workout_session/domain/models/exercise_prescription.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../widgets/start_workout_bottom_bar.dart';
import '../widgets/workout_exercise_list_section.dart';

/// Workout Detail screen:
/// - Menampilkan hero exercise, ringkasan program, dan daftar gerakan
/// - Mengambil jadwal hanya dari Dynamic Program yang aktif
/// - Menjaga kontrak navigasi ke Active Workout
class WorkoutDetailScreen extends StatefulWidget {
  final int dayNumber;
  final int? weekNumber;
  final String? programId;
  final String weekDayText;
  final String workoutTitle;
  final String targetMusclesText;
  final String durationText;
  final String levelText;
  final String description;

  /// Tanggal jadwal sesi ini, dipakai untuk memulai/melanjutkan sesi.
  final DateTime? scheduledDate;

  /// Jika true, layar hanya menampilkan pratinjau tanpa tombol mulai.
  final bool readOnly;

  /// Sesi in_progress yang bisa dilanjutkan.
  final String? activeSessionId;

  const WorkoutDetailScreen({
    super.key,
    this.dayNumber = 1,
    this.weekNumber,
    this.programId,
    this.weekDayText = 'Week 1 • Day 1',
    this.workoutTitle = 'Upper Body',
    this.targetMusclesText = 'Chest • Shoulders • Triceps',
    this.durationText = '45 min',
    this.levelText = 'Intermediate',
    this.description = 'Build strength and muscle mass at home.',
    this.scheduledDate,
    this.readOnly = false,
    this.activeSessionId,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final _exerciseRepo = ExerciseRepositoryImpl(ExerciseLocalDatasource());

  List<WorkoutDetailExerciseData> _exercises = [];
  ProgramDay? _loadedProgramDay;
  String? _resolvedProgramId;
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    try {
      // Ambil data exercise langsung dari Supabase
      await _exerciseRepo.getExercises();

      final List<WorkoutDetailExerciseData> list = [];
      final db = AppDatabase.instance;
      final profile = await db.getUserProfile();
      final userId = profile.id.isNotEmpty ? profile.id : 'default_user';

      // 1. Read the selected session from the dynamic program.
      // If widget.programId is provided (e.g. resuming an old/archived program session,
      // or opening a specific program), load sessions directly from that programId.
      List<ProgramSessionEntity> sessions = [];
      String? targetProgramId = widget.programId;

      if (targetProgramId != null && targetProgramId.isNotEmpty) {
        sessions = await db.getProgramSessions(targetProgramId);
      }

      if (sessions.isEmpty) {
        var activeProgram = await db.getActiveTrainingProgram(userId);
        activeProgram ??= await db.getActiveTrainingProgram('default_user');
        if (activeProgram != null) {
          targetProgramId = activeProgram.id;
          sessions = await db.getProgramSessions(activeProgram.id);
        }
      }

      if (sessions.isNotEmpty) {
        _resolvedProgramId = targetProgramId;
        final sessionIndex = sessions.indexWhere(
          (session) => session.dayNumber == widget.dayNumber,
        );

        if (sessionIndex >= 0) {
          final session = sessions[sessionIndex];
          final detail = await db.getProgramSessionDetail(session.id);

          if (detail != null && detail.exercises.isNotEmpty) {
            _loadedProgramDay = ProgramDay(
              day: session.dayNumber,
              week: widget.weekNumber ?? 1,
              type: WorkoutTypeCode.f,
              focus: LocalizedString(
                id: session.focusLabel,
                en: session.focusLabel,
              ),
              isRest: false,
              isRetestMilestone: false,
              items: detail.exercises.map((item) {
                final prescription = item.prescription;
                final isDuration =
                    item.exercise.trackingType == TrackingType.duration;
                return WorkoutItem(
                  exerciseId: item.exercise.id,
                  sets: prescription.targetSets,
                  reps: isDuration
                      ? prescription.maxReps
                      : prescription.minReps,
                  durationSec: isDuration ? prescription.maxReps : null,
                  restSeconds: prescription.restSeconds,
                  isMain: prescription.stage == 'main',
                  stage: prescription.stage,
                );
              }).toList(),
            );

            for (final item in detail.exercises) {
              final ex = item.exercise;
              final prescription = item.prescription;
              final isDuration = ex.trackingType == TrackingType.duration;
              final repsStr = isDuration
                  ? '${prescription.minReps} – ${prescription.maxReps} sec'
                  : '${prescription.minReps} – ${prescription.maxReps} Reps';
              final restStr = '${prescription.restSeconds} sec';

              list.add(
                WorkoutDetailExerciseData(
                  title: ex.name.en.isNotEmpty ? ex.name.en : ex.name.id,
                  categoryTag: ex.primaryMuscles.isNotEmpty
                      ? ex.primaryMuscles.first.en
                      : 'Bodyweight',
                  thumbnailAsset: ex.media.startPose.isNotEmpty
                      ? ex.media.startPose
                      : 'assets/images/Detail Gerakan.png',
                  sets: prescription.targetSets,
                  reps: repsStr,
                  rest: restStr,
                  exercise: ex,
                  stage: prescription.stage,
                  prescription: WorkoutExercisePrescription.fromProgramExercise(
                    prescription,
                    trackingType: ex.trackingType,
                  ),
                ),
              );
            }
          }
        }
      }

      // Dynamic Program is the single source of workout schedules.
      // When a day has no session details, keep the empty state instead of
      // silently substituting an unrelated 30-day static workout.

      if (mounted) {
        setState(() {
          _exercises = list;
          _isLoading = false;
          _hasLoadError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.limeAccent),
        ),
      );
    }

    if (_hasLoadError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF1F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      size: 30,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Workout detail could not be loaded',
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check your connection and try again.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _hasLoadError = false;
                      });
                      _loadWorkoutData();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.limeAccent,
                      foregroundColor: AppColors.darkCharcoal,
                    ),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final descriptionText = widget.description.trim().isNotEmpty
        ? widget.description
        : 'Build strength and stability with a focused mix of bodyweight exercises.';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWorkoutHero(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.readOnly) ...[
                            _buildReadOnlyNotice(Translations.of(context)),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            widget.workoutTitle,
                            style: AppTypography.headlineLarge.copyWith(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkCharcoal,
                              letterSpacing: -0.55,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            runSpacing: 9,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _buildWorkoutMeta(
                                icon: Icons.access_time_rounded,
                                label: widget.durationText,
                              ),
                              _buildWorkoutMeta(
                                icon: Icons.fitness_center_rounded,
                                label: '${_exercises.length} exercises',
                              ),
                              _buildWorkoutMeta(
                                icon: Icons.signal_cellular_alt_rounded,
                                label: widget.levelText,
                              ),
                            ],
                          ),
                          if (descriptionText.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              descriptionText,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.neutral600,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          if (_exercises.isEmpty)
                            _buildEmptyExercisesState()
                          else
                            WorkoutExerciseListSection(exercises: _exercises),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: widget.readOnly || _exercises.isEmpty
            ? null
            : StartWorkoutBottomBar(
                label: widget.activeSessionId != null
                    ? Translations.of(context).workouts.workoutDetail.resume
                    : 'Start Workout',
                icon: widget.activeSessionId != null
                    ? Icons.play_circle_fill_rounded
                    : Icons.play_arrow_rounded,
                onStartWorkout: _startActiveWorkout,
              ),
      ),
    );
  }

  Widget _buildWorkoutHero() {
    final topInset = MediaQuery.of(context).padding.top;
    final imagePath = _exercises.isNotEmpty
        ? _exercises.first.thumbnailAsset
        : '';

    return SizedBox(
      width: double.infinity,
      height: 218 + topInset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath.isNotEmpty)
            AppSmartImage(
              imagePathOrUrl: imagePath,
              fit: BoxFit.cover,
              errorWidget: _buildHeroFallback(),
            )
          else
            _buildHeroFallback(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Color(0x08000000),
                  Color(0x22000000),
                ],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          Positioned(
            top: topInset + 8,
            left: 16,
            child: _buildHeroAction(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onPressed: () => context.pop(),
            ),
          ),
          Positioned(
            top: topInset + 8,
            right: 66,
            child: _buildHeroAction(
              icon: Icons.ios_share_rounded,
              tooltip: 'Copy workout details',
              onPressed: _copyWorkoutDetails,
            ),
          ),
          Positioned(
            top: topInset + 8,
            right: 16,
            child: _buildHeroAction(
              icon: _isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              tooltip: _isBookmarked ? 'Remove bookmark' : 'Bookmark workout',
              onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyWorkoutDetails() async {
    final description = widget.description.trim().isNotEmpty
        ? widget.description.trim()
        : 'Build strength and stability with a focused mix of bodyweight exercises.';
    final details = [
      widget.workoutTitle,
      '${widget.durationText} • ${_exercises.length} exercises • ${widget.levelText}',
      description,
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: details));
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Workout details copied.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  Widget _buildHeroFallback() {
    return Container(
      color: AppColors.neutral100,
      alignment: Alignment.center,
      child: const Icon(
        Icons.fitness_center_rounded,
        size: 54,
        color: AppColors.neutral400,
      ),
    );
  }

  Widget _buildHeroAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0x66000000),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 21),
        constraints: const BoxConstraints.tightFor(width: 42, height: 42),
      ),
    );
  }

  Widget _buildWorkoutMeta({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.neutral600),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyExercisesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.fitness_center_rounded,
            size: 30,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: 10),
          Text(
            'No exercises available',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'There are no exercises assigned to this workout yet.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyNotice(Translations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.visibility_rounded,
            size: 18,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.workouts.workoutDetail.readOnlyTitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.workouts.workoutDetail.readOnlyNotice,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startActiveWorkout() {
    final calculatedWeek =
        widget.weekNumber ?? ((widget.dayNumber - 1) ~/ 7 + 1);
    final programDay =
        _loadedProgramDay?.copyWith(week: calculatedWeek) ??
        ProgramDay(
          day: widget.dayNumber,
          week: calculatedWeek,
          type: WorkoutTypeCode.p,
          focus: LocalizedString(
            id: widget.workoutTitle,
            en: widget.workoutTitle,
          ),
          isRest: false,
          isRetestMilestone: false,
          items: _exercises.map((e) {
            return WorkoutItem(
              exerciseId: e.exercise.id,
              sets: e.sets,
              reps: 10,
              restSeconds: 60,
              isMain: e.stage == 'main',
              stage: e.stage,
            );
          }).toList(),
        );

    context.push(
      AppRoutes.workoutSession,
      extra: WorkoutSessionArgs(
        day: programDay,
        exercises: _exercises.map((e) => e.exercise).toList(),
        programId: _resolvedProgramId ?? widget.programId,
        scheduledDate: widget.scheduledDate,
        activeSessionId: widget.activeSessionId,
        prescriptions: {
          for (final data in _exercises)
            if (data.prescription != null) data.exercise.id: data.prescription!,
        },
      ),
    );
  }
}
