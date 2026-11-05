import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_smart_image.dart';

/// Card Banner "Up Next" di bagian bawah Active Workout (Mockup 1:1)
class ActiveWorkoutUpNextCard extends StatelessWidget {
  final String nextExerciseName;
  final String nextCategoryTag;
  final String nextThumbnailAsset;
  final VoidCallback onTap;

  const ActiveWorkoutUpNextCard({
    super.key,
    required this.nextExerciseName,
    required this.nextCategoryTag,
    required this.nextThumbnailAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Label "Up Next"
            Text(
              'Up Next',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: const Color(0xFF141718),
              ),
            ),
            const SizedBox(width: 14),

            // Thumbnail Foto dengan Play Icon
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72,
                    height: 44,
                    color: const Color(0xFF1E293B),
                    child: AppSmartImage(
                      imagePathOrUrl: nextThumbnailAsset,
                      fit: BoxFit.cover,
                      errorWidget: const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Nama & Kategori Gerakan Selanjutnya
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nextExerciseName,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: const Color(0xFF141718),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF8D6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      nextCategoryTag,
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF3F6212),
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron Right
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

