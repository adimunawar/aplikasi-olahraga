import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/features/workouts/domain/models/exercise_muscle_filter.dart';
import 'package:workout_app/i18n/strings.g.dart';

/// Header pada layar Workouts: judul, tombol search & filter, dan search bar.
class WorkoutsHeader extends StatelessWidget {
  final bool isAllWorkoutsTab;
  final bool isSearchActive;
  final String searchQuery;
  final ExerciseMuscleFilter selectedMuscleFilter;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilter;

  const WorkoutsHeader({
    super.key,
    required this.isAllWorkoutsTab,
    required this.isSearchActive,
    required this.searchQuery,
    required this.selectedMuscleFilter,
    required this.onToggleSearch,
    required this.onSearchChanged,
    required this.onOpenFilter,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = theme.colorScheme.onSurface;
    final hintColor = theme.colorScheme.onSurfaceVariant;
    final searchBgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : Colors.white;
    final searchBorderColor = isDark
        ? theme.colorScheme.outline
        : const Color(0xFFE5E7EB);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
          child: Row(
            children: [
              Text(
                t.workouts.title,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  color: primaryTextColor,
                  letterSpacing: -0.6,
                ),
              ),
              const Spacer(),
              if (isAllWorkoutsTab) ...[
                IconButton(
                  onPressed: onToggleSearch,
                  icon: Icon(
                    isSearchActive
                        ? Icons.close_rounded
                        : Icons.search_rounded,
                    color: primaryTextColor,
                    size: 24,
                  ),
                ),
                IconButton(
                  tooltip: t.workouts.filter.title,
                  onPressed: onOpenFilter,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: primaryTextColor,
                        size: 24,
                      ),
                      if (selectedMuscleFilter != ExerciseMuscleFilter.all)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isAllWorkoutsTab && isSearchActive)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              autofocus: true,
              style: TextStyle(color: primaryTextColor),
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: t.workouts.searchHint,
                hintStyle: TextStyle(color: hintColor),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: hintColor,
                ),
                filled: true,
                fillColor: searchBgColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: searchBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: searchBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
