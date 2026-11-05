import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Item Baris Gerakan Latihan pada Workout Detail (Mockup 1:1):
/// - Thumbnail foto pose dengan overlay tombol play bulat di sisi kanan thumbnail
/// - Nama gerakan bold (14px)
/// - Tag pill hijau muda untuk otot target (Chest • Triceps • Shoulders)
/// - Info set & reps di kanan ("3 sets", "8 – 12 reps")
/// - Chevron icon (>) untuk membuka detail gerakan
class WorkoutExerciseListItem extends StatelessWidget {
  final int? index;
  final String title;
  final String categoryTag;
  final String thumbnailAsset;
  final int sets;
  final String reps;
  final String rest;
  final Exercise exercise;

  const WorkoutExerciseListItem({
    super.key,
    this.index,
    required this.title,
    required this.categoryTag,
    required this.thumbnailAsset,
    this.sets = 3,
    this.reps = '8 – 12',
    this.rest = '60 – 90s',
    required this.exercise,
  });

  String get _muscleText {
    final list = <String>[];
    for (final m in exercise.primaryMuscles) {
      if (!list.contains(m.en)) list.add(m.en);
    }
    for (final m in exercise.stabilizerMuscles) {
      if (!list.contains(m.en)) list.add(m.en);
    }
    if (list.isNotEmpty) {
      return list.take(3).join(' • ');
    }
    return categoryTag;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(AppRoutes.exerciseDetail, extra: exercise);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F3F5), width: 1.2),
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
            // Thumbnail pose dengan background terang & tombol play
            Container(
              width: 76,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppSmartImage(
                      imagePathOrUrl: thumbnailAsset,
                      fit: BoxFit.contain,
                      errorWidget: const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFF94A3B8),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFF141718),
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Nama Gerakan & Tag Otot
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: const Color(0xFF141718),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF8D6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _muscleText,
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF365314),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Sets & Reps
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$sets sets',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: const Color(0xFF141718),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reps.toLowerCase().contains('rep')
                      ? reps.toLowerCase()
                      : '$reps reps',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Chevron Arrow
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF141718),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
