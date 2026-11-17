import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';
import '../../../exercises/domain/extensions/localized_string_extension.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../controllers/workout_session_state.dart';
import '../../domain/models/exercise_prescription.dart';
import 'active_workout_header.dart';
import 'active_workout_rep_counter.dart';
import 'active_workout_video_card.dart';
import 'next_rest_card.dart';

/// Konten utama Active Workout (fase aktif, bukan rest):
/// header progress, nama exercise, video, rep counter, dan kartu rest.
class ActiveWorkoutContent extends StatelessWidget {
  final WorkoutSessionState sessionState;
  final Exercise exercise;
  final WorkoutExercisePrescription prescription;
  final int totalExercises;
  final ValueChanged<int> onRepCounterChanged;
  final VoidCallback onFullscreen;

  const ActiveWorkoutContent({
    super.key,
    required this.sessionState,
    required this.exercise,
    required this.prescription,
    required this.totalExercises,
    required this.onRepCounterChanged,
    required this.onFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDuration =
        exercise.trackingType == TrackingType.duration ||
        prescription.isDuration;
    final targetValue = isDuration
        ? (prescription.targetDurationSeconds ?? 45)
        : prescription.maxReps;
    final valueLabel = isDuration
        ? t.workoutSession.durationValue(value: targetValue)
        : t.workoutSession.repsValue(value: targetValue);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ActiveWorkoutHeader(
            currentExerciseIndex: sessionState.currentExerciseIndex,
            totalExercises: totalExercises,
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
                  exercise.name.localized(
                    LocaleSettings.currentLocale.languageCode,
                  ),
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
                  t.workoutSession.setProgress(
                    current: sessionState.currentSet,
                    total: sessionState.totalSetsPerExercise,
                    target: valueLabel,
                  ),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                ActiveWorkoutVideoCard(
                  videoUrl: exercise.resolvedVideoUrl,
                  imageAsset: exercise.resolvedImageUrl,
                  onFullscreen: onFullscreen,
                ),
                const SizedBox(height: 28),
                ActiveWorkoutRepCounter(
                  key: ValueKey('${exercise.id}_${sessionState.currentSet}'),
                  initialValue: targetValue,
                  isDuration: isDuration,
                  onChanged: onRepCounterChanged,
                ),
                const SizedBox(height: 24),
                NextRestCard(restSeconds: sessionState.defaultRestSeconds),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
