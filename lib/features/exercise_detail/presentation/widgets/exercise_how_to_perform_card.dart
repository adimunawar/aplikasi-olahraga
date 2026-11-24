import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Box 3: How to Perform (Mockup 1:1)
/// - Menampilkan panduan langkah 1, 2, 3 berurutan dinamis dari data `exercise.steps`
class ExerciseHowToPerformCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseHowToPerformCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? theme.colorScheme.surface : Colors.white;
    final cardBorderColor = isDark
        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.4)
        : const Color(0xFFF1F3F5);
    final titleColor = theme.colorScheme.onSurface;
    final stepTextColor = isDark ? theme.colorScheme.onSurface : const Color(0xFF334155);

    final badgeBg = isDark
        ? theme.colorScheme.primaryContainer
        : AppColors.limeCardSurface;
    final badgeBorder = isDark
        ? theme.colorScheme.primary.withValues(alpha: 0.5)
        : AppColors.limeAccent.withValues(alpha: 0.6);
    final badgeTextColor = isDark
        ? theme.colorScheme.onPrimaryContainer
        : AppColors.darkCharcoal;

    final steps = exercise.steps.id.isNotEmpty
        ? exercise.steps.id
        : (exercise.steps.en.isNotEmpty ? exercise.steps.en : [
            'Start in a high plank position with hands under your shoulders and a straight body line.',
            'Lower your chest toward the floor, keeping your elbows at about 45° from your body.',
            'Push back up to the starting position in a controlled movement.',
          ]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0x06000000),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with Green Accent Indicator
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.limeAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'How to Perform',
                style: AppTypography.headlineSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // List of Step Items
          ...List.generate(steps.length, (index) {
            final isLast = index == steps.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number Badge (Lingkaran Hijau)
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: badgeBorder,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Step Description Text
                  Expanded(
                    child: Text(
                      steps[index],
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13.5,
                        color: stepTextColor,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

