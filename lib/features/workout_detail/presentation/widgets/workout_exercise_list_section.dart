import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';
import 'workout_exercise_list_item.dart';

/// Section daftar 5 gerakan latihan dengan tombol header "Edit Workout"
class WorkoutExerciseListSection extends StatelessWidget {
  final List<WorkoutDetailExerciseData> exercises;
  final VoidCallback onEditWorkout;
  final void Function(int oldIndex, int newIndex) onReorder;

  const WorkoutExerciseListSection({
    super.key,
    required this.exercises,
    required this.onEditWorkout,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
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
              onTap: onEditWorkout,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF8D6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Color(0xFF365314),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Edit Workout',
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF365314),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List Gerakan Latihan (Dapat Digeser & Ditukar Posisinya)
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false, // Handle khusus di drag indicator :::
          itemCount: exercises.length,
          onReorder: onReorder,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(animation.value);
                return Material(
                  color: Colors.transparent,
                  elevation: 10 * t,
                  shadowColor: const Color(0x33000000),
                  borderRadius: BorderRadius.circular(16),
                  child: child,
                );
              },
            );
          },
          itemBuilder: (context, index) {
            final item = exercises[index];
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
        ),
      ],
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

  WorkoutDetailExerciseData({
    required this.title,
    required this.categoryTag,
    required this.thumbnailAsset,
    this.sets = 3,
    this.reps = '8 – 12',
    this.rest = '60 – 90s',
    required this.exercise,
  });
}

