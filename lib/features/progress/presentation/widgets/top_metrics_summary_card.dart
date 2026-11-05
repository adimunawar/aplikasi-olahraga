import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Top Metrics Summary Card pada Halaman Progress (1:1 sesuai mockup):
/// - 1 Kartu putih utuh tanpa garis pemisah vertikal
/// - 3 Metrik: Workouts, Calories, Minutes
/// - Ikon bulat lime lembut di kiri, teks angka tebal dan label abu-abu di sampingnya
class TopMetricsSummaryCard extends StatelessWidget {
  final int workoutCount;
  final int caloriesBurned;
  final int totalMinutes;

  const TopMetricsSummaryCard({
    super.key,
    this.workoutCount = 10,
    this.caloriesBurned = 2540,
    this.totalMinutes = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Workouts
          _buildMetricItem(
            icon: Icons.fitness_center_rounded,
            value: '$workoutCount',
            label: 'Workouts',
          ),

          // 2. Calories
          _buildMetricItem(
            icon: Icons.local_fire_department_outlined,
            value: _formatNumber(caloriesBurned),
            label: 'Calories',
          ),

          // 3. Minutes
          _buildMetricItem(
            icon: Icons.access_time_rounded,
            value: '$totalMinutes',
            label: 'Minutes',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Lingkaran Hijau Lime Lembut untuk Icon
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.limeSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppColors.darkCharcoal,
          ),
        ),
        const SizedBox(width: 8),

        // Nilai & Label Metrik
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.darkCharcoal,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final last3 = s.substring(s.length - 3);
      final first = s.substring(0, s.length - 3);
      return '$first,$last3';
    }
    return n.toString();
  }
}
