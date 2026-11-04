import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Card "Tips" Latihan:
/// Menampilkan checklist tips eksekusi gerakan yang aman dan efektif.
class ExerciseTipsCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseTipsCard({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final tips = exercise.commonMistakes.id.isNotEmpty
        ? exercise.commonMistakes.id
        : [
            'Jaga tubuh tetap lurus dari kepala hingga kaki.',
            'Turunkan tubuh dengan kontrol, jangan terlalu cepat.',
            'Jika masih berat, mulailah dengan Knee Push Up (dengan lutut).',
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successSurface, // #E9F5DA
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFC7E5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFB8E66B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF13361A), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF13361A),
                  ),
                ),
                const SizedBox(height: 8),
                ...tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF65A30D),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tip,
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF202820),
                              height: 1.35,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
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

