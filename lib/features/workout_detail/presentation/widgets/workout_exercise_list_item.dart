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

  String get _prescriptionLabel {
    final value = reps.trim();
    final lower = value.toLowerCase();
    final alreadyHasUnit =
        lower.contains('rep') || lower.contains('sec') || lower.endsWith('s');
    return alreadyHasUnit ? value : '$value reps';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.exerciseDetail, extra: exercise);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF0F2F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  width: 66,
                  height: 48,
                  child: AppSmartImage(
                    imagePathOrUrl: thumbnailAsset,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: const Color(0xFFF3F5F2),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(
                        color: const Color(0xFF141718),
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sets sets × $_prescriptionLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF64748B),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
