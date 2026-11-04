import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Section "Cara Melakukan":
/// Panduan bertahap dengan badge nomor lime dan kartu visual Posisi Awal & Posisi Bawah.
class ExerciseStepsSection extends StatelessWidget {
  final Exercise exercise;

  const ExerciseStepsSection({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final steps = exercise.steps.id.isNotEmpty
        ? exercise.steps.id
        : [
            'Mulai dari posisi plank, tangan sedikit lebih lebar dari bahu.',
            'Turunkan tubuh perlahan hingga dada hampir menyentuh lantai.',
            'Dorong kembali ke atas sampai lengan lurus.',
            'Ulangi sesuai target repetisi dengan ritme stabil.',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cara Melakukan',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Numbered instructions
            Expanded(
              flex: 6,
              child: Column(
                children: List.generate(steps.length, (idx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB8E66B),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                color: Color(0xFF13361A),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            steps[idx],
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.4,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(width: 12),

            // Right: Posisi Awal & Posisi Bawah Visual Demonstration Cards
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildPoseCard('Posisi Awal', Icons.accessibility_new_rounded, true),
                  const SizedBox(height: 10),
                  _buildPoseCard('Posisi Bawah', Icons.sports_gymnastics, false),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPoseCard(String label, IconData icon, bool isStart) {
    return Container(
      width: double.infinity,
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Center(
            child: Icon(
              icon,
              size: 38,
              color: const Color(0xFF13361A).withValues(alpha: 0.35),
            ),
          ),
          Positioned(
            left: 8,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFB8E66B),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF13361A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

