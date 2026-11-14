import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Card Statistik Sesi Selesai (Judul Sesi + 4 Metrik: Durasi, Gerakan, Sets, Kalori)
class WorkoutSummaryStatsCard extends StatelessWidget {
  final String workoutTitle;
  final String weekDayText;
  final String durationText;
  final String exercisesCountText;
  final String setsCountText;
  final String caloriesText;

  const WorkoutSummaryStatsCard({
    super.key,
    this.workoutTitle = 'Upper Body Strength',
    this.weekDayText = 'Week 3 • Day 1',
    this.durationText = '25 min',
    this.exercisesCountText = '5 / 5',
    this.setsCountText = '15',
    this.caloriesText = '≈ 185 kcal',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Baris Atas: Icon Bicep, Judul Sesi, & Badge Minggu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Bicep / Otot dalam badge mint lembut
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F9D7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: Color(0xFF3F6212),
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Judul & Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workoutTitle,
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 16.5,
                          color: const Color(0xFF141718),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3FBE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: Color(0xFF4D7C0F),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              weekDayText,
                              style: AppTypography.labelSmall.copyWith(
                                color: const Color(0xFF4D7C0F),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 4 Kolom Metrik di Bawah
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Row(
              children: [
                _buildStatColumn(
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFF16A34A),
                  label: 'Duration',
                  value: durationText,
                ),
                _buildVerticalDivider(),
                _buildStatColumn(
                  icon: Icons.layers_rounded,
                  iconColor: const Color(0xFF0284C7),
                  label: 'Exercises',
                  value: exercisesCountText,
                ),
                _buildVerticalDivider(),
                _buildStatColumn(
                  icon: Icons.cached_rounded,
                  iconColor: const Color(0xFF84CC16),
                  label: 'Sets',
                  value: setsCountText,
                ),
                _buildVerticalDivider(),
                _buildStatColumn(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFF97316),
                  label: 'Est. Calories',
                  value: caloriesText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
              color: const Color(0xFF141718),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 36,
      width: 1,
      color: const Color(0xFFF1F5F9),
    );
  }
}

