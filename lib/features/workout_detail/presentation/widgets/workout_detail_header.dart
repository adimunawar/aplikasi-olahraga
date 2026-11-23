import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Header section displaying title, metadata chips, read-only notice, and description.
class WorkoutDetailHeader extends StatelessWidget {
  final bool readOnly;
  final String workoutTitle;
  final String durationText;
  final int exercisesCount;
  final String levelText;
  final String description;

  const WorkoutDetailHeader({
    super.key,
    required this.readOnly,
    required this.workoutTitle,
    required this.durationText,
    required this.exercisesCount,
    required this.levelText,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = theme.colorScheme.onSurface;
    final subtextColor = theme.colorScheme.onSurfaceVariant;
    final exerciseCountLabel = t.workouts.workoutDetail.exerciseCount(
      count: exercisesCount,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (readOnly) ...[
          _buildReadOnlyNotice(context, t, isDark),
          const SizedBox(height: 16),
        ],
        Text(
          workoutTitle,
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: titleColor,
            letterSpacing: -0.55,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 9,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildWorkoutMeta(
              icon: Icons.access_time_rounded,
              label: durationText,
              color: subtextColor,
            ),
            _buildWorkoutMeta(
              icon: Icons.fitness_center_rounded,
              label: exerciseCountLabel,
              color: subtextColor,
            ),
            _buildWorkoutMeta(
              icon: Icons.signal_cellular_alt_rounded,
              label: levelText,
              color: subtextColor,
            ),
          ],
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              color: subtextColor,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWorkoutMeta({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyNotice(
    BuildContext context,
    Translations t,
    bool isDark,
  ) {
    final bgColor = isDark ? const Color(0xFF2C1E0A) : const Color(0xFFFFFBEB);
    final borderColor = isDark
        ? const Color(0xFF78350F)
        : const Color(0xFFFDE68A);
    final titleTextColor = isDark
        ? const Color(0xFFFDE68A)
        : const Color(0xFF92400E);
    final bodyTextColor = isDark
        ? const Color(0xFFFCD34D)
        : const Color(0xFFB45309);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.visibility_rounded, size: 18, color: bodyTextColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.workouts.workoutDetail.readOnlyTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: titleTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.workouts.workoutDetail.readOnlyNotice,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: bodyTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
