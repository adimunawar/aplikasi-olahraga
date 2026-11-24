import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../workout_session/domain/models/exercise_prescription.dart';
import 'workout_exercise_list_item.dart';

class WorkoutExerciseListSection extends StatelessWidget {
  final List<WorkoutDetailExerciseData> exercises;

  const WorkoutExerciseListSection({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    final warmupList = exercises.where((e) => e.stage == 'warmup').toList();
    final trainingList = exercises.where((e) => e.stage == 'main').toList();
    final cooldownList = exercises.where((e) => e.stage == 'cooldown').toList();
    final hasMultiStage = warmupList.isNotEmpty || cooldownList.isNotEmpty;

    final sectionTitle = t.workouts.workoutDetail.exerciseListTitle(
      count: exercises.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        if (!hasMultiStage)
          _buildExerciseList(exercises)
        else ...[
          if (warmupList.isNotEmpty) ...[
            _buildStageHeader(
              context: context,
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFF97316),
              title: t.workouts.workoutDetail.stages.warmup.title,
              count: warmupList.length,
              subtitle: t.workouts.workoutDetail.stages.warmup.subtitle,
            ),
            _buildExerciseList(warmupList),
          ],
          if (trainingList.isNotEmpty) ...[
            _buildStageHeader(
              context: context,
              icon: Icons.fitness_center_rounded,
              iconColor: theme.colorScheme.primary,
              title: t.workouts.workoutDetail.stages.main.title,
              count: trainingList.length,
              subtitle: t.workouts.workoutDetail.stages.main.subtitle,
            ),
            _buildExerciseList(trainingList),
          ],
          if (cooldownList.isNotEmpty) ...[
            _buildStageHeader(
              context: context,
              icon: Icons.self_improvement_rounded,
              iconColor: const Color(0xFF0284C7),
              title: t.workouts.workoutDetail.stages.cooldown.title,
              count: cooldownList.length,
              subtitle: t.workouts.workoutDetail.stages.cooldown.subtitle,
            ),
            _buildExerciseList(cooldownList),
          ],
        ],
      ],
    );
  }

  Widget _buildStageHeader({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                '$title ($count)',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(List<WorkoutDetailExerciseData> list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Padding(
          key: ValueKey('${item.exercise.id}_$index'),
          padding: const EdgeInsets.only(bottom: 10),
          child: WorkoutExerciseListItem(
            title: item.title,
            thumbnailAsset:
                item.exercise.media.thumbnailUrl ?? item.thumbnailAsset,
            sets: item.sets,
            reps: item.reps,
            exercise: item.exercise,
          ),
        );
      },
    );
  }
}

class WorkoutDetailExerciseData {
  final String title;
  final String categoryTag;
  final String thumbnailAsset;
  final int sets;
  final String reps;
  final String rest;
  final Exercise exercise;
  final String stage; // 'warmup', 'main', 'cooldown'

  /// Preskripsi asli dari program (target set, min/max reps, rest) supaya
  /// bisa diteruskan ke Active Workout tanpa kehilangan detail.
  final WorkoutExercisePrescription? prescription;

  WorkoutDetailExerciseData({
    required this.title,
    required this.categoryTag,
    required this.thumbnailAsset,
    this.sets = 3,
    this.reps = '8 – 12',
    this.rest = '60 – 90s',
    required this.exercise,
    this.stage = 'main',
    this.prescription,
  });
}
