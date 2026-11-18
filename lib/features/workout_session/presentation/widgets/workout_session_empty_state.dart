import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';

/// Empty state ketika Active Workout dibuka tanpa daftar exercise.
class WorkoutSessionEmptyState extends StatelessWidget {
  final String programTitle;

  const WorkoutSessionEmptyState({super.key, required this.programTitle});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.darkCharcoal,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          programTitle,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.neutral100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 38,
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t.workouts.allWorkouts.emptyTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.darkCharcoal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.workoutSession.emptySessionDescription,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                AppButton.primary(
                  text: t.workoutSession.backButtonLabel,
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
