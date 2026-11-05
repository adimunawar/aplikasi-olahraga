import 'package:flutter/material.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
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
                  color: const Color(0xFF141718),
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
                  // Number Badge (Lingkaran Hijau Muda)
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.limeCardSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.limeAccent.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
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
                        color: const Color(0xFF334155),
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

