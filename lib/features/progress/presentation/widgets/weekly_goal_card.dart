import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Card "Weekly Goal" pada Halaman Progress:
/// - Judul: "Weekly Goal"
/// - Info: "3 of 4 workouts"
/// - Progress bar hijau lime dengan label "75%" di samping kanannya
class WeeklyGoalCard extends StatelessWidget {
  final int completedWorkouts;
  final int targetWorkouts;

  const WeeklyGoalCard({
    super.key,
    this.completedWorkouts = 3,
    this.targetWorkouts = 4,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (targetWorkouts > 0 ? completedWorkouts / targetWorkouts : 0.0).clamp(0.0, 1.0);
    final percentInt = (progress * 100).round();

    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Icon Bulat Lime Lembut
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.limeSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  size: 18,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Goal',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  Text(
                    '$completedWorkouts of $targetWorkouts workouts',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Progress bar + Label Persen di Kanan
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.cardBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percentInt%',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
