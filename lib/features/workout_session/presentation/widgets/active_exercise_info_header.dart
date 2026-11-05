import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Header Info Gerakan (Judul, Tag Otot, & Tombol Petunjuk "How to do it"):
class ActiveExerciseInfoHeader extends StatelessWidget {
  final String exerciseName;
  final String categoryTag;
  final VoidCallback onHowToDoIt;

  const ActiveExerciseInfoHeader({
    super.key,
    required this.exerciseName,
    required this.categoryTag,
    required this.onHowToDoIt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul Gerakan Display Bold
        Text(
          exerciseName,
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 27,
            color: const Color(0xFF141718),
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),

        // Tag Otot & Tombol How to do it
        Row(
          children: [
            // Tag Kategori Otot Hijau Lime
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF8D6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                categoryTag,
                style: AppTypography.labelSmall.copyWith(
                  color: const Color(0xFF3F6212),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Link How to do it
            GestureDetector(
              onTap: onHowToDoIt,
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF141718),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'How to do it',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF141718),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

