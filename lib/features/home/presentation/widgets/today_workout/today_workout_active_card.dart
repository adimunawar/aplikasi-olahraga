import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../i18n/strings.g.dart';

/// Kartu Latihan Aktif Hari Ini (Mockup 1:1)
class TodayWorkoutActiveCard extends StatelessWidget {
  final String sessionTitle;
  final String targetMuscles;
  final int durationMinutes;
  final int estimatedCalories;
  final VoidCallback onStartWorkout;
  final VoidCallback onViewPlan;

  const TodayWorkoutActiveCard({
    super.key,
    required this.sessionTitle,
    required this.targetMuscles,
    required this.durationMinutes,
    this.estimatedCalories = 280,
    required this.onStartWorkout,
    required this.onViewPlan,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Today's Workout + View Plan ->
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.home.todayWorkout.title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.darkCharcoal,
                ),
              ),
              InkWell(
                onTap: onViewPlan,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.home.todayWorkout.viewPlan,
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF65A30D),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Workout Card Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.neutral200,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Info Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dumbbell Icon Container
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8D5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFF65A30D),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title, Muscles, Meta Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sessionTitle,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.darkCharcoal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            targetMuscles,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.neutral500,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppColors.neutral500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                t.home.todayWorkout.approxMin(min: durationMinutes),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.neutral600,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 14,
                                color: Color(0xFFEA580C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                t.home.todayWorkout.approxKcal(kcal: estimatedCalories),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.neutral600,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Big Lime Button: ▷ Start Workout
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onStartWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF84CC16),
                      foregroundColor: AppColors.darkCharcoal,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: const Color(0xFF84CC16).withValues(alpha: 0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          size: 24,
                          color: AppColors.darkCharcoal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t.home.todayWorkout.startWorkout,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
