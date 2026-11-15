import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Compact exercise progress bar shown below the Active Workout app bar.
class ActiveWorkoutHeader extends StatelessWidget {
  final int currentExerciseIndex;
  final int totalExercises;

  const ActiveWorkoutHeader({
    super.key,
    required this.currentExerciseIndex,
    required this.totalExercises,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalExercises > 0 ? totalExercises : 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 5,
        backgroundColor: const Color(0xFFE5E7EB),
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.limeAccent),
      ),
    );
  }
}
