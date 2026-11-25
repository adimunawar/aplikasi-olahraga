import 'package:material_ui/material_ui.dart';

import 'package:workout_app/features/workouts/domain/models/exercise_muscle_filter.dart';
import 'package:workout_app/i18n/strings.g.dart';

/// Tombol aksi AppBar (search & filter) pada tab Semua Latihan.
class WorkoutsAppBarActions extends StatelessWidget {
  final bool isSearchActive;
  final ExerciseMuscleFilter selectedMuscleFilter;
  final VoidCallback onToggleSearch;
  final VoidCallback onOpenFilter;

  const WorkoutsAppBarActions({
    super.key,
    required this.isSearchActive,
    required this.selectedMuscleFilter,
    required this.onToggleSearch,
    required this.onOpenFilter,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onToggleSearch,
          icon: Icon(
            isSearchActive ? Icons.close_rounded : Icons.search_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: t.workouts.filter.title,
            onPressed: onOpenFilter,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: colorScheme.onSurface,
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
                        color: colorScheme.primary,
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
        ),
      ],
    );
  }
}

/// Kolom pencarian latihan saat tombol search diaktifkan pada tab Semua Latihan.
class WorkoutsSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const WorkoutsSearchBar({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        autofocus: true,
        style: TextStyle(color: colorScheme.onSurface),
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: t.workouts.searchHint,
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
