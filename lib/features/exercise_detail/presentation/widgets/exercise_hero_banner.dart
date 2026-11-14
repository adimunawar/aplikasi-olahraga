import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Hero Banner Card untuk Detail Gerakan:
/// Gradien dark forest green dengan badge 'Home Workout', info otot, dan Coach Karakter.
class ExerciseHeroBanner extends StatelessWidget {
  final Exercise exercise;
  final String primaryMuscles;

  const ExerciseHeroBanner({
    super.key,
    required this.exercise,
    required this.primaryMuscles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF13361A), // Dark forest green
            Color(0xFF22542B),
            Color(0xFF336C36),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F13361A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background subtle lime decorative arc
          Positioned(
            right: -20,
            bottom: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB8E66B).withValues(alpha: 0.18),
              ),
            ),
          ),

          // Content & Character Layout
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left Text Info
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge "Home Workout"
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8E66B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.home_rounded, size: 14, color: Color(0xFF13361A)),
                            const SizedBox(width: 4),
                            Text(
                              'Home Workout',
                              style: AppTypography.labelSmall.copyWith(
                                color: const Color(0xFF13361A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Exercise Name
                      Text(
                        exercise.name.id,
                        style: AppTypography.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Muscle subtitle
                      Row(
                        children: [
                          const Icon(Icons.fitness_center_rounded, size: 14, color: Color(0xFFB8E66B)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              primaryMuscles.isNotEmpty ? primaryMuscles : 'Chest • Triceps • Shoulder',
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFFE2EED9),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Short Description
                      Text(
                        'Latihan efektif untuk membangun kekuatan otot dada, lengan, dan bahu tanpa alat.',
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFFD3E2CA),
                          height: 1.35,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Coach Character
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: 145,
                      child: Image.asset(
                        'assets/images/coach_character.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/main-caracter.png',
                          fit: BoxFit.contain,
                        ),
                      ),
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

