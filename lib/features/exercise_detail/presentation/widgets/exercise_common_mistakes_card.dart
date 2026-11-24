import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Box 4: Common Mistakes (Mockup 1:1)
/// - Menampilkan daftar kesalahan umum dinamis dari data `exercise.commonMistakes`
/// - Format list rapi tanpa gambar dengan icon silang merah (X)
class ExerciseCommonMistakesCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCommonMistakesCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? theme.colorScheme.surface : Colors.white;
    final cardBorderColor = isDark
        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.4)
        : const Color(0xFFF1F3F5);
    final titleColor = theme.colorScheme.onSurface;
    final mistakeTextColor = isDark ? theme.colorScheme.onSurface : const Color(0xFF334155);

    final iconBgColor = isDark ? const Color(0xFF3B1515) : const Color(0xFFFEE2E2);
    final iconBorderColor = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5);
    final iconColor = isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);

    final mistakes = exercise.commonMistakes.id.isNotEmpty
        ? exercise.commonMistakes.id
        : (exercise.commonMistakes.en.isNotEmpty ? exercise.commonMistakes.en : [
            'Hips dropping too low or back arching excessively.',
            'Elbows flaring too wide away from the body.',
            'Not using full range of motion during repetition.',
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
                'Common Mistakes',
                style: AppTypography.headlineSmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // List of Mistake Items
          ...List.generate(mistakes.length, (index) {
            final isLast = index == mistakes.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Silang Merah Bulat (X)
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: iconBorderColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Mistake Description Text
                  Expanded(
                    child: Text(
                      mistakes[index],
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13.5,
                        color: mistakeTextColor,
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

