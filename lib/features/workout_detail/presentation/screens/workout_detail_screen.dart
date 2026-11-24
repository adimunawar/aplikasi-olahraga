import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/features/program/domain/models/program_day.dart';
import 'package:workout_app/i18n/strings.g.dart';

import '../controllers/workout_detail_data_loader.dart';
import '../widgets/workout_detail_widgets.dart';

/// Workout Detail screen:
/// Pure composition screen displaying workout hero, header metadata, exercises list, and CTA.
/// Adheres strictly to AGENTS.md: pure composition (<200 lines), theme fidelity, and i18n support.
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
  final DateTime? scheduledDate;
  final bool readOnly;
  final String? activeSessionId;
  final WorkoutDetailDataLoader dataLoader;

  WorkoutDetailScreen({
    super.key,
    this.dayNumber = 1,
    this.weekNumber,
    this.programId,
    this.weekDayText = '',
    this.workoutTitle = '',
    this.targetMusclesText = '',
    this.durationText = '',
    this.levelText = '',
    this.description = '',
    this.scheduledDate,
    this.readOnly = false,
    this.activeSessionId,
    WorkoutDetailDataLoader? dataLoader,
  }) : dataLoader = dataLoader ?? WorkoutDetailDataLoader.live();

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  List<WorkoutDetailExerciseData> _exercises = [];
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
      final list = await widget.dataLoader.load(
        programId: widget.programId,
        dayNumber: widget.dayNumber,
      );
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

    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    if (_hasLoadError) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: WorkoutDetailErrorView(
          onRetry: () {
            setState(() {
              _isLoading = true;
              _hasLoadError = false;
            });
            _loadWorkoutData();
          },
        ),
      );
    }

    final resolvedTitle = widget.workoutTitle.isNotEmpty
        ? widget.workoutTitle
        : t.workouts.title;
    final resolvedDuration = widget.durationText.isNotEmpty
        ? widget.durationText
        : t.workouts.session.min(min: 30);
    final resolvedLevel = widget.levelText.isNotEmpty
        ? widget.levelText
        : t.onboarding.experience.options.first.title;
    final resolvedDescription = widget.description.trim().isNotEmpty
        ? widget.description.trim()
        : t.workouts.workoutDetail.defaultDescription;

    final heroImage =
        _exercises.isNotEmpty ? _exercises.first.thumbnailAsset : '';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkoutDetailHero(
                imagePath: heroImage,
                onBackPressed: () => context.pop(),
                onSharePressed: () {
                  WorkoutDetailShareHelper.copy(
                    context: context,
                    title: resolvedTitle,
                    durationText: resolvedDuration,
                    exerciseCountLabel:
                        t.workouts.workoutDetail.exerciseCount(count: _exercises.length),
                    levelText: resolvedLevel,
                    description: resolvedDescription,
                    snackbarMessage: t.workouts.workoutDetail.copiedMessage,
                  );
                },
                onBookmarkPressed: () =>
                    setState(() => _isBookmarked = !_isBookmarked),
                isBookmarked: _isBookmarked,
                backTooltip: t.core.actions.back,
                shareTooltip: t.workouts.workoutDetail.shareTooltip,
                bookmarkTooltip: _isBookmarked
                    ? t.workouts.workoutDetail.bookmarkRemove
                    : t.workouts.workoutDetail.bookmarkAdd,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WorkoutDetailHeader(
                      readOnly: widget.readOnly,
                      workoutTitle: resolvedTitle,
                      durationText: resolvedDuration,
                      exercisesCount: _exercises.length,
                      levelText: resolvedLevel,
                      description: resolvedDescription,
                    ),
                    const SizedBox(height: 22),
                    if (_exercises.isEmpty)
                      const WorkoutDetailEmptyState()
                    else
                      WorkoutExerciseListSection(exercises: _exercises),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.readOnly || _exercises.isEmpty
            ? null
            : StartWorkoutBottomBar(
                label: widget.activeSessionId != null
                    ? t.workouts.workoutDetail.resume
                    : t.home.todayWorkout.startWorkout,
                icon: widget.activeSessionId != null
                    ? Icons.play_circle_fill_rounded
                    : Icons.play_arrow_rounded,
                onStartWorkout: _startActiveWorkout,
              ),
      ),
    );
  }

  void _startActiveWorkout() {

    final calculatedWeek =
        widget.weekNumber ?? ((widget.dayNumber - 1) ~/ 7 + 1);

    final resolvedTitle = widget.workoutTitle.isNotEmpty
        ? widget.workoutTitle
        : t.workouts.title;

    final programDay = ProgramDay(
      day: widget.dayNumber,
      week: calculatedWeek,
      type: WorkoutTypeCode.p,
      focus: resolvedTitle,
      isRest: false,
      isRetestMilestone: false,
      title: resolvedTitle,
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
        programId: widget.programId,
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
