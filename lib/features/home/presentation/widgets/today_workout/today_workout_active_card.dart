import 'package:material_ui/material_ui.dart';

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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              InkWell(
                onTap: onViewPlan,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.home.todayWorkout.viewPlan,
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow
                      .withValues(alpha: 0.04),
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
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Theme.of(context).colorScheme.primary,
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            targetMuscles,
                            style: AppTypography.bodySmall.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                t.home.todayWorkout.approxMin(
                                  min: durationMinutes,
                                ),
                                style: AppTypography.bodySmall.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.local_fire_department_rounded,
                                size: 14,
                                color: Color(0xFFEA580C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                t.home.todayWorkout.approxKcal(
                                  kcal: estimatedCalories,
                                ),
                                style: AppTypography.bodySmall.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t.home.todayWorkout.startWorkout,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onPrimary,
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
