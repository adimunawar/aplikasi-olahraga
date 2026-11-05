import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_typography.dart';

/// Card item latihan harian pada Tab Workouts:
/// - Thumbnail ilustrasi gerakan/otot di kiri
/// - Judul (Day 1 - Upper Body (A)), Target Otot, Durasi (45 min), & Tingkat kesulitan
/// - Tombol play bulat hijau lime cerah di kanan
class WorkoutDayCard extends StatelessWidget {
  final int dayNumber;
  final String title;
  final String targetMuscles;
  final String durationText;
  final String levelText;
  final String thumbnailAsset;

  const WorkoutDayCard({
    super.key,
    required this.dayNumber,
    required this.title,
    required this.targetMuscles,
    this.durationText = '45 min',
    this.levelText = 'Intermediate',
    required this.thumbnailAsset,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail Foto Gerakan
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 66,
                height: 66,
                color: const Color(0xFF1E293B),
                child: Image.asset(
                  thumbnailAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Konten Tengah
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
                    targetMuscles,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        durationText,
                        style: AppTypography.labelSmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.signal_cellular_alt_rounded,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        levelText,
                        style: AppTypography.labelSmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Tombol Play Bulat Hijau Lime
            GestureDetector(
              onTap: () => _openDetail(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFC7F135),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF141718),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    context.push(
      AppRoutes.workoutDetail,
      extra: WorkoutDetailArgs(
        dayNumber: dayNumber,
        weekDayText: 'Week 3 • Day $dayNumber',
        workoutTitle: title,
        targetMusclesText: targetMuscles,
        durationText: durationText,
        levelText: levelText,
        description:
            'Build strength and mass for your ${targetMuscles.toLowerCase()}.',
      ),
    );
  }
}

