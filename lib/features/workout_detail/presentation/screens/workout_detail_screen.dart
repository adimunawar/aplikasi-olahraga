import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/data/datasources/program_local_datasource.dart';
import '../../../program/data/repositories/program_repository_impl.dart';
import '../../../program/domain/models/program_day.dart';
import '../widgets/start_workout_bottom_bar.dart';
import '../widgets/target_muscles_overview_section.dart';
import '../widgets/workout_detail_hero_banner.dart';
import '../widgets/workout_exercise_list_section.dart';

/// Layar Workout Detail (Mockup 1:1 Resolusi Tinggi):
/// - Terintegrasi dinamis dengan ProgramRepository dan ExerciseRepository
/// - Menampilkan gerakan latihan riil sesuai dayNumber dari program_30_days.json
/// - Menghitung Target Muscles dan Overview metrik secara dinamis tanpa hardcode
class WorkoutDetailScreen extends StatefulWidget {
  final int dayNumber;
  final String weekDayText;
  final String workoutTitle;
  final String targetMusclesText;
  final String durationText;
  final String levelText;
  final String description;

  const WorkoutDetailScreen({
    super.key,
    this.dayNumber = 1,
    this.weekDayText = 'Week 1 • Day 1',
    this.workoutTitle = 'Upper Body',
    this.targetMusclesText = 'Chest • Shoulders • Triceps',
    this.durationText = '45 min',
    this.levelText = 'Intermediate',
    this.description = 'Build strength and muscle mass at home.',
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final _programRepo = ProgramRepositoryImpl(ProgramLocalDatasource());
  final _exerciseRepo = ExerciseRepositoryImpl(ExerciseLocalDatasource());

  List<WorkoutDetailExerciseData> _exercises = [];
  ProgramDay? _loadedProgramDay;
  bool _isLoading = true;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    try {
      final List<WorkoutDetailExerciseData> list = [];
      final db = AppDatabase.instance;
      final activeProgram = await db.getActiveTrainingProgram('default_user');

      // 1. Coba baca dari Dynamic Training Program (Fase 2)
      if (activeProgram != null) {
        final sessions = await db.getProgramSessions(activeProgram.id);
        if (sessions.isNotEmpty) {
          final targetIndex = (widget.dayNumber - 1) % sessions.length;
          final session = sessions[targetIndex];
          final detail = await db.getProgramSessionDetail(session.id);

          if (detail != null && detail.exercises.isNotEmpty) {
            for (final item in detail.exercises) {
              final ex = item.exercise;
              final prescription = item.prescription;
              final repsStr = '${prescription.minReps} – ${prescription.maxReps} Reps';
              final restStr = '${prescription.restSeconds} sec';

              list.add(
                WorkoutDetailExerciseData(
                  title: ex.name.en.isNotEmpty ? ex.name.en : ex.name.id,
                  categoryTag: ex.primaryMuscles.isNotEmpty ? ex.primaryMuscles.first.en : 'Bodyweight',
                  thumbnailAsset: ex.media.startPose.isNotEmpty ? ex.media.startPose : 'assets/images/Detail Gerakan.png',
                  sets: prescription.targetSets,
                  reps: repsStr,
                  rest: restStr,
                  exercise: ex,
                  stage: prescription.stage,
                ),
              );
            }
          }
        }
      }

      // 2. Fallback ke program statis jika belum ada program dinamis
      if (list.isEmpty) {
        final programDay = await _programRepo.getDay(widget.dayNumber);
        final allExercises = await _exerciseRepo.getExercises();
        final exercisesMap = {for (final e in allExercises) e.id: e};

        if (programDay != null && programDay.items.isNotEmpty) {
          for (final item in programDay.items) {
            final exercise =
                exercisesMap[item.exerciseId] ??
                _buildFallbackExercise(item.exerciseId);

            final repsStr = item.durationSec != null && item.durationSec! > 0
                ? '${item.durationSec}s'
                : (item.reps != null ? '${item.reps} Reps' : '8 – 12 Reps');

            final restStr = '${item.restSeconds} sec';

            String stage = item.stage ?? 'main';
            if (item.stage == null) {
              if (exercise.category == ExerciseCategory.warmup ||
                  exercise.id.toLowerCase().contains('warmup')) {
                stage = 'warmup';
              } else if (exercise.category == ExerciseCategory.cooldown ||
                  exercise.id.toLowerCase().contains('cooldown')) {
                stage = 'cooldown';
              }
            }

            list.add(
              WorkoutDetailExerciseData(
                title: exercise.name.en.isNotEmpty
                    ? exercise.name.en
                    : exercise.name.id,
                categoryTag: exercise.primaryMuscles.isNotEmpty
                    ? exercise.primaryMuscles.first.en
                    : 'Bodyweight',
                thumbnailAsset: exercise.media.startPose.isNotEmpty
                    ? exercise.media.startPose
                    : 'assets/images/Detail Gerakan.png',
                sets: item.sets,
                reps: repsStr,
                rest: restStr,
                exercise: exercise,
                stage: stage,
              ),
            );
          }
          _loadedProgramDay = programDay;
        } else {
          final fallbackList = allExercises.take(4).toList();
          for (final exercise in fallbackList) {
            list.add(
              WorkoutDetailExerciseData(
                title: exercise.name.en.isNotEmpty
                    ? exercise.name.en
                    : exercise.name.id,
                categoryTag: exercise.primaryMuscles.isNotEmpty
                    ? exercise.primaryMuscles.first.en
                    : 'Bodyweight',
                thumbnailAsset: exercise.media.startPose.isNotEmpty
                    ? exercise.media.startPose
                    : 'assets/images/Detail Gerakan.png',
                sets: 3,
                reps: '8 – 12 Reps',
                rest: '60 sec',
                exercise: exercise,
              ),
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _exercises = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Exercise _buildFallbackExercise(String id) {
    final title = id
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');

    return Exercise(
      id: id,
      name: LocalizedString(id: title, en: title),
      category: ExerciseCategory.push,
      difficulty: ExerciseDifficulty.intermediate,
      trackingType: TrackingType.reps,
      primaryMuscles: [LocalizedString(id: 'Dada', en: 'Chest')],
      stabilizerMuscles: const [LocalizedString(id: 'Core', en: 'Core')],
      steps: const LocalizedList(
        id: ['Lakukan gerakan secara terkontrol dengan rentang penuh.'],
        en: ['Perform movement with control through full range of motion.'],
      ),
      commonMistakes: const LocalizedList(
        id: ['Menggunakan momentum alih-alih kontrol otot.'],
        en: ['Using momentum instead of muscular control.'],
      ),
      breathing: const LocalizedString(
        id: 'Tarik napas saat menurunkan, hembuskan saat mendorong.',
        en: 'Inhale while lowering, exhale while pushing.',
      ),
      variations: const ExerciseVariationGroup(),
      media: const ExerciseMedia(startPose: '', endPose: ''),
    );
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
          'Workout Detail',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF141718),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: const Color(0xFF141718),
              size: 24,
            ),
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isBookmarked
                        ? 'Workout disimpan ke bookmark.'
                        : 'Bookmark dihapus.',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Color(0xFF141718),
              size: 26,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu opsi workout.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Banner
            WorkoutDetailHeroBanner(
              weekDayText: widget.weekDayText,
              title: widget.workoutTitle,
              durationText: widget.durationText,
              levelText: widget.levelText,
              description: widget.description,
            ),
            const SizedBox(height: 18),

            // 2. Workout Overview 4 Kolom (Mockup 1:1)
            TargetMusclesOverviewSection(
              totalExercises: _exercises.length,
              setsText: '${_exercises.isNotEmpty ? _exercises.first.sets : 3}',
              repsText: _exercises.isNotEmpty
                  ? _exercises.first.reps
                  : '8 – 12',
              restText: _exercises.isNotEmpty
                  ? _exercises.first.rest
                  : '60 – 90s',
            ),
            const SizedBox(height: 22),

            // 3. Exercises List
            WorkoutExerciseListSection(
              exercises: _exercises,
              onReorder: _onReorder,
              onPreviewAll: () {
                if (_exercises.isNotEmpty) {
                  context.push(
                    AppRoutes.exerciseDetail,
                    extra: _exercises.first.exercise,
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: StartWorkoutBottomBar(
        onStartWorkout: _startActiveWorkout,
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, item);
    });
  }

  void _startActiveWorkout() {
    final calculatedWeek = (widget.dayNumber - 1) ~/ 7 + 1;
    final programDay =
        _loadedProgramDay ??
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
      ),
    );
  }
}
