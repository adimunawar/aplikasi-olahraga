import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/features/workouts/domain/models/exercise_muscle_filter.dart';
import 'package:workout_app/i18n/strings.g.dart';

/// Label lokal untuk kategori otot.
String getMuscleCategoryLabel(Translations t, ExerciseMuscleFilter filter) {
  switch (filter) {
    case ExerciseMuscleFilter.all:
      return t.workouts.categories.all;
    case ExerciseMuscleFilter.chest:
      return t.workouts.categories.chest;
    case ExerciseMuscleFilter.back:
      return t.workouts.categories.back;
    case ExerciseMuscleFilter.legs:
      return t.workouts.categories.legs;
    case ExerciseMuscleFilter.core:
      return t.workouts.categories.core;
    case ExerciseMuscleFilter.arms:
      return t.workouts.categories.arms;
    case ExerciseMuscleFilter.shoulders:
      return t.workouts.categories.shoulders;
  }
}

/// Menampilkan modal bottom sheet untuk memilih filter otot.
void showMuscleFilterSheet({
  required BuildContext context,
  required ExerciseMuscleFilter currentFilter,
  required ValueChanged<ExerciseMuscleFilter> onFilterSelected,
}) {
  final t = Translations.of(context);
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final sheetBgColor = isDark ? theme.colorScheme.surface : Colors.white;
  final handleColor = isDark
      ? theme.colorScheme.outline
      : const Color(0xFFE5E7EB);
  final titleColor = theme.colorScheme.onSurface;
  final chipBgColor = isDark
      ? theme.colorScheme.surfaceContainerHighest
      : const Color(0xFFF3F4F6);

  showModalBottomSheet(
    context: context,
    backgroundColor: sheetBgColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.workouts.filter.title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: ExerciseMuscleFilter.values.map((filter) {
                  final isSel = filter == currentFilter;
                  return ChoiceChip(
                    label: Text(getMuscleCategoryLabel(t, filter)),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    backgroundColor: chipBgColor,
                    labelStyle: TextStyle(
                      color: isSel
                          ? const Color(0xFF141718)
                          : theme.colorScheme.onSurface,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                    ),
                    onSelected: (_) {
                      onFilterSelected(filter);
                      Navigator.pop(sheetContext);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
