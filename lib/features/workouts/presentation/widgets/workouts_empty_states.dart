import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/widgets/core_widgets.dart';
import 'package:workout_app/i18n/strings.g.dart';

/// State kosong jika user belum memiliki program aktif.
class ProgramEmptyState extends StatelessWidget {
  const ProgramEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return AppEmptyState(
      icon: Icons.fitness_center_rounded,
      title: t.workouts.emptyState.noProgramTitle,
      message: t.workouts.emptyState.noProgramSubtitle,
      useCard: false,
      neutralBadge: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
    );
  }
}

/// State jika tidak ada sesi terjadwal pada minggu yang dipilih.
class NoScheduledWorkoutsState extends StatelessWidget {
  const NoScheduledWorkoutsState({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: const EdgeInsets.all(18),
        child: Text(
          t.workouts.weeklySchedule.empty,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.5),
        ),
      ),
    );
  }
}

/// State jika pencarian atau filter latihan tidak menghasilkan data.
class ExerciseEmptyState extends StatelessWidget {
  final VoidCallback onClearFilters;

  const ExerciseEmptyState({super.key, required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppEmptyState(
      icon: Icons.search_off_rounded,
      title: t.workouts.allWorkouts.emptyTitle,
      message: t.workouts.allWorkouts.emptySubtitle,
      neutralBadge: true,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      action: TextButton(
        onPressed: onClearFilters,
        style: TextButton.styleFrom(
          foregroundColor: isDark
              ? AppColors.limeAccent
              : const Color(0xFF3F6212),
        ),
        child: Text(
          t.workouts.allWorkouts.clearFilters,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// State error saat gagal memuat data workouts.
class WorkoutsErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const WorkoutsErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return AppErrorState(
      icon: Icons.cloud_off_rounded,
      title: t.workouts.errorState.title,
      message: t.workouts.errorState.subtitle,
      retryLabel: t.workouts.errorState.retry,
      onRetry: onRetry,
    );
  }
}
