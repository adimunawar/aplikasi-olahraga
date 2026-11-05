import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';
import 'mini_anatomy_icon.dart';

/// Item baris gerakan latihan pada Tab Exercises (Mockup 3):
/// - Thumbnail foto gerakan di kiri
/// - Nama gerakan & Kategori (Chest, Back, Shoulder, dll) di tengah
/// - Mini ilustrasi anatomi dengan otot target merah + chevron panah kanan di kanan
class ExercisePlanItemCard extends StatelessWidget {
  final String title;
  final String category;
  final String thumbnailAsset;
  final Exercise exercise;

  const ExercisePlanItemCard({
    super.key,
    required this.title,
    required this.category,
    required this.thumbnailAsset,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(AppRoutes.exerciseDetail, extra: exercise);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail Foto Gerakan
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                color: const Color(0xFF1E293B),
                child: Image.asset(
                  thumbnailAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: Color(0xFF94A3B8),
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Nama & Kategori Gerakan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: const Color(0xFF141718),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Mini Anatomi Otot dengan Highlight Merah
            MiniAnatomyIcon(muscleGroup: category),
            const SizedBox(width: 6),

            // Chevron Arrow
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

