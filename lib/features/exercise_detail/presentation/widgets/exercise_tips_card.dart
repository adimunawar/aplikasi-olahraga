import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Box 5: Tips for Beginners (Mockup 1:1)
/// - Kartu bernuansa hijau lembut dengan icon lampu bohlam
/// - Menampilkan tips pernapasan & panduan pemula dari `exercise.breathing`
class ExerciseTipsCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseTipsCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final tipText = exercise.breathing.en.isNotEmpty
        ? exercise.breathing.en
        : (exercise.breathing.id.isNotEmpty
            ? exercise.breathing.id
            : 'Start with knee push-ups, keep your core tight, and focus on controlled, steady movement.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F9EA), // Soft lime surface
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EED0), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lampu Bohlam Icon Badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.limeAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.limeAccent.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFF141718),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Teks Tips
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips for Beginners',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: const Color(0xFF141718),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tipText,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12.5,
                    color: const Color(0xFF475569),
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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
