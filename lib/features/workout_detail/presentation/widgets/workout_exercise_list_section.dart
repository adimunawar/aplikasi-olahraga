import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';
import 'workout_exercise_list_item.dart';

/// Section daftar gerakan latihan:
/// - Otomatis mendeteksi jika program memiliki fase 'Warm-up', 'Training', atau 'Cool-down'
/// - Jika TIDAK memiliki warm-up/cool-down, tampil ringkas normal 'Exercises (N)' tanpa seksi kosong
/// - Jika memiliki warm-up/cool-down, dikelompokkan secara terstruktur dan informatif
class WorkoutExerciseListSection extends StatelessWidget {
  final List<WorkoutDetailExerciseData> exercises;
  final VoidCallback? onPreviewAll;
  final void Function(int oldIndex, int newIndex) onReorder;

  const WorkoutExerciseListSection({
    super.key,
    required this.exercises,
    this.onPreviewAll,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final warmupList = exercises.where((e) => e.stage == 'warmup').toList();
    final trainingList = exercises.where((e) => e.stage == 'main').toList();
    final cooldownList = exercises.where((e) => e.stage == 'cooldown').toList();
    final hasMultiStage = warmupList.isNotEmpty || cooldownList.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section Utama
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Exercises (${exercises.length})',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: const Color(0xFF141718),
              ),
            ),
            GestureDetector(
              onTap: onPreviewAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF8D6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      size: 15,
                      color: Color(0xFF141718),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Preview All',
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF141718),
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (!hasMultiStage)
          // 1. Tampilan Standar Normal (Jika program hanya berisi latihan inti)
          _buildExerciseList(exercises)
        else ...[
          // 2. Tampilan Terstruktur (Jika program memiliki Warm-up atau Cool-down)
          if (warmupList.isNotEmpty) ...[
            _buildStageHeader(
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFF97316),
              title: 'Warm up',
              count: warmupList.length,
              subtitle: 'Pemanasan',
            ),
            _buildExerciseList(warmupList),
          ],
          if (trainingList.isNotEmpty) ...[
            _buildStageHeader(
              icon: Icons.fitness_center_rounded,
              iconColor: const Color(0xFF141718),
              title: 'Training',
              count: trainingList.length,
              subtitle: 'Latihan Inti',
            ),
            _buildExerciseList(trainingList),
          ],
          if (cooldownList.isNotEmpty) ...[
            _buildStageHeader(
              icon: Icons.self_improvement_rounded,
              iconColor: const Color(0xFF0284C7),
              title: 'Cool down',
              count: cooldownList.length,
              subtitle: 'Pendinginan',
            ),
            _buildExerciseList(cooldownList),
          ],
        ],
      ],
    );
  }

  Widget _buildStageHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                '$title ($count)',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  color: const Color(0xFF141718),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(List<WorkoutDetailExerciseData> list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Padding(
          key: ValueKey('${item.exercise.id}_$index'),
          padding: const EdgeInsets.only(bottom: 10),
          child: WorkoutExerciseListItem(
            index: index,
            title: item.title,
            categoryTag: item.categoryTag,
            thumbnailAsset: item.thumbnailAsset,
            sets: item.sets,
            reps: item.reps,
            rest: item.rest,
            exercise: item.exercise,
          ),
        );
      },
    );
  }
}

class WorkoutDetailExerciseData {
  final String title;
  final String categoryTag;
  final String thumbnailAsset;
  final int sets;
  final String reps;
  final String rest;
  final Exercise exercise;
  final String stage; // 'warmup', 'main', 'cooldown'

  WorkoutDetailExerciseData({
    required this.title,
    required this.categoryTag,
    required this.thumbnailAsset,
    this.sets = 3,
    this.reps = '8 – 12',
    this.rest = '60 – 90s',
    required this.exercise,
    this.stage = 'main',
  });
}
