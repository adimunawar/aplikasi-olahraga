import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';

/// Section "Next Workout" di Home Screen:
/// Kartu preview sesi latihan berikutnya dengan thumbnail dan tombol Play.
class NextWorkoutSection extends StatelessWidget {
  final ProgramDay? programDay;
  final List<Exercise> exercises;
  final VoidCallback onStartWorkout;

  const NextWorkoutSection({
    super.key,
    required this.programDay,
    required this.exercises,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final day = programDay;
    final isRest = day?.isRest == true;
    final title = day != null && !isRest ? day.focus.id : 'Upper Body (A)';
    final subtitle = isRest
        ? 'Fokus pemulihan otot & istirahat'
        : 'Chest • Back • Shoulder • Arms';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next Workout',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1D1E),
                fontSize: 18,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F5DA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Today',
                style: AppTypography.labelSmall.copyWith(
                  color: const Color(0xFF5B8E1B),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Workout Card
        InkWell(
          onTap: () {
            if (exercises.isNotEmpty) {
              context.push(
                AppRoutes.exerciseDetail,
                extra: exercises.first,
              );
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x04000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF222B22),
                    child: Image.asset(
                      'assets/images/coach_character.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFFB8E66B),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Middle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1D1E),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF71767B),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF71767B)),
                          const SizedBox(width: 4),
                          Text(
                            '45 min',
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFF71767B),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.bar_chart_rounded, size: 14, color: Color(0xFF71767B)),
                          const SizedBox(width: 4),
                          Text(
                            'Intermediate',
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFF71767B),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right Play Button
                InkWell(
                  onTap: onStartWorkout,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB8E66B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF131A11),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

