import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../../i18n/strings.g.dart';

/// Empty state ketika Active Workout dibuka tanpa daftar exercise.
class WorkoutSessionEmptyState extends StatelessWidget {
  final String programTitle;

  const WorkoutSessionEmptyState({super.key, required this.programTitle});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          programTitle,
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: AppEmptyState(
          icon: Icons.fitness_center_rounded,
          title: t.workouts.allWorkouts.emptyTitle,
          message: t.workoutSession.emptySessionDescription,
          useCard: false,
          neutralBadge: true,
          action: AppButton.primary(
            text: t.workoutSession.backButtonLabel,
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.pop(),
          ),
        ),
      ),
    );
  }
}
