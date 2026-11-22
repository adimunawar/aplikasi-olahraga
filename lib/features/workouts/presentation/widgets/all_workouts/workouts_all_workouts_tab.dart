import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/features/exercises/domain/models/exercise.dart';
import 'package:workout_app/features/workouts/domain/models/exercise_muscle_filter.dart';
import 'package:workout_app/i18n/strings.g.dart';
import '../workouts_empty_states.dart';
import 'exercise_item_card.dart';
import 'muscle_filter_sheet.dart';

/// Tab tampilan "Semua Latihan" pada layar Workouts.
class WorkoutsAllWorkoutsTab extends StatelessWidget {
  final List<Exercise> exercises;
  final ExerciseMuscleFilter selectedMuscleFilter;
  final ValueChanged<ExerciseMuscleFilter> onMuscleFilterSelected;
  final VoidCallback onClearFilters;

  const WorkoutsAllWorkoutsTab({
    super.key,
    required this.exercises,
    required this.selectedMuscleFilter,
    required this.onMuscleFilterSelected,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final langCode = LocaleSettings.currentLocale.languageCode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: ExerciseMuscleFilter.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = ExerciseMuscleFilter.values[index];
              final isSel = filter == selectedMuscleFilter;

              return GestureDetector(
                onTap: () => onMuscleFilterSelected(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.primary
                        : (isDark
                              ? theme.colorScheme.surfaceContainerHighest
                              : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      getMuscleCategoryLabel(t, filter),
                      style: TextStyle(
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                        color: isSel
                            ? const Color(0xFF141718)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (exercises.isEmpty)
          ExerciseEmptyState(onClearFilters: onClearFilters)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: exercises.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ExerciseItemCard(
                exercise: exercise,
                langCode: langCode,
                onTap: () =>
                    context.push(AppRoutes.exerciseDetail, extra: exercise),
              );
            },
          ),
      ],
    );
  }
}
