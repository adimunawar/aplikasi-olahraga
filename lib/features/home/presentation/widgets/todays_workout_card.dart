import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

/// Kartu "Today's Workout" dengan CTA Hijau Kompak & Pose Latihan Menyatu (Referensi Baru 1:1)
class TodaysWorkoutCard extends StatelessWidget {
  final String sessionTitle;
  final int durationMinutes;
  final int exerciseCount;
  final VoidCallback onStartWorkout;
  final String exerciseImageAsset;

  const TodaysWorkoutCard({
    super.key,
    required this.sessionTitle,
    this.durationMinutes = 25,
    this.exerciseCount = 5,
    required this.onStartWorkout,
    this.exerciseImageAsset = 'assets/images/exercises/push_up.webp',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EED3), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Background/Right: Foto Pose Gerakan (Push-up) dengan horizontal soft fade
          Positioned(
            right: 0,
            bottom: 0,
            top: 10,
            width: 180,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Color(0x99FFFFFF), Colors.white],
                  stops: [0.0, 0.35, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                exerciseImageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.bottomRight,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tag Atas: 📅 Today's Workout
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Color(0xFF3F6212),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Today's Workout",
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF3F6212),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Judul Workout: dibatasi ke kolom kiri agar tidak menabrak foto
                SizedBox(
                  width: 170,
                  child: Text(
                    sessionTitle,
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: const Color(0xFF141718),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 8),

                // Meta Info: ⏱ ± 20 min   🏋 3 exercises
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: Color(0xFF4B5563),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '± $durationMinutes min',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF4B5563),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.fitness_center_rounded,
                      size: 13,
                      color: Color(0xFF4B5563),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$exerciseCount exercises',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF4B5563),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Tombol Kompak (Kiri saja, tidak full width)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: const Color(0xFF84CC16),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: onStartWorkout,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                              color: Color(0xFF141718),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Start Workout',
                              style: AppTypography.labelLarge.copyWith(
                                color: const Color(0xFF141718),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
