import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Item Baris Gerakan Latihan pada Workout Detail (Mockup 1:1):
/// - Thumbnail foto dengan overlay tombol play bulat mini di sudut kanan bawah
/// - Nama gerakan & Tag kategori otot hijau lime
/// - 3 Kolom Metrik: Sets (3), Reps (8-12), Rest (60-90s)
/// - Ikon reorder handle di ujung kanan (:::)
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
            // Thumbnail dengan overlay Play Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 58,
                    height: 58,
                    color: const Color(0xFF1E293B),
                    child: AppSmartImage(
                      imagePathOrUrl: thumbnailAsset,
                      fit: BoxFit.cover,
                      errorWidget: const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFF94A3B8),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                // Play overlay bulat di sudut kanan bawah
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Nama Gerakan & Tag Kategori
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: const Color(0xFF141718),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF8D6), // Soft lime pill
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      categoryTag,
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF4D7C0F),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Kolom 1: Sets
            _buildMetricColumn('Sets', '$sets'),
            const SizedBox(width: 12),

            // Kolom 2: Reps
            _buildMetricColumn('Reps', reps),
            const SizedBox(width: 12),

            // Kolom 3: Rest
            _buildMetricColumn('Rest', rest),
            const SizedBox(width: 10),

            // Reorder Drag Handle (6 titik - Sentuh & seret untuk tukar posisi)
            if (index != null)
              ReorderableDragStartListener(
                index: index!,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  color: Colors.transparent,
                  child: const Icon(
                    Icons.drag_indicator_rounded,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
                ),
              )
            else
              const Icon(
                Icons.drag_indicator_rounded,
                color: Color(0xFF94A3B8),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: const Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
            color: const Color(0xFF141718),
          ),
        ),
      ],
    );
  }
}
