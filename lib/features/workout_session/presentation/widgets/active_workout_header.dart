import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Header Active Workout (Mockup 1:1):
/// - Judul sesi latihan: "Upper Body Strength"
/// - Indikator progress: "Exercise 1 of 5" + Segmented Progress Bars (5 bar kapsul)
class ActiveWorkoutHeader extends StatelessWidget {
  final String workoutTitle;
  final int currentExerciseIndex; // 0-based
  final int totalExercises;

  const ActiveWorkoutHeader({
    super.key,
    required this.workoutTitle,
    required this.currentExerciseIndex,
    required this.totalExercises,
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = currentExerciseIndex + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul Sesi Latihan
        Text(
          workoutTitle,
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 21,
            color: const Color(0xFF141718),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),

        // Progress Text & Segmented Bars
        Row(
          children: [
            // "Exercise 1 of 5"
            RichText(
              text: TextSpan(
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                children: [
                  const TextSpan(text: 'Exercise '),
                  TextSpan(
                    text: '$currentStep',
                    style: const TextStyle(
                      color: Color(0xFF65A30D),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(text: ' of $totalExercises'),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Segmented Progress Bars (5 kapsul)
            Expanded(
              child: Row(
                children: List.generate(totalExercises, (index) {
                  final isDoneOrCurrent = index <= currentExerciseIndex;
                  return Expanded(
                    child: Container(
                      height: 5.5,
                      margin: EdgeInsets.only(right: index == totalExercises - 1 ? 0 : 5),
                      decoration: BoxDecoration(
                        color: isDoneOrCurrent
                            ? const Color(0xFFC7F135) // Lime Green Aktif
                            : const Color(0xFFE2E8F0), // Abu-abu
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

