import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Section "Your Progress" di Home Screen:
/// 3 kartu ringkasan (Workouts, Calories, Weight + trend).
class YourProgressSection extends StatelessWidget {
  final int completedWorkouts;
  final int totalWorkouts;
  final int currentCalories;
  final int targetCalories;
  final double currentWeightKg;
  final double weightTrendKg;
  final String weekLabel;

  const YourProgressSection({
    super.key,
    this.completedWorkouts = 6,
    this.totalWorkouts = 12,
    this.currentCalories = 2850,
    this.targetCalories = 3000,
    this.currentWeightKg = 67.5,
    this.weightTrendKg = 1.8,
    this.weekLabel = 'Week 3 of 8',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Progress',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1D1E),
                fontSize: 18,
              ),
            ),
            Text(
              weekLabel,
              style: AppTypography.labelMedium.copyWith(
                color: const Color(0xFF71767B),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            // Card 1: Workouts
            Expanded(
              child: _buildProgressCard(
                icon: Icons.fitness_center_rounded,
                title: 'Workouts',
                value: '$completedWorkouts / $totalWorkouts',
                progress: completedWorkouts / (totalWorkouts > 0 ? totalWorkouts : 1),
              ),
            ),
            const SizedBox(width: 10),

            // Card 2: Calories
            Expanded(
              child: _buildProgressCard(
                icon: Icons.restaurant_rounded,
                title: 'Calories',
                value: _formatNumber(currentCalories),
                subValue: ' / ${_formatNumber(targetCalories)}',
                progress: currentCalories / (targetCalories > 0 ? targetCalories : 1),
              ),
            ),
            const SizedBox(width: 10),

            // Card 3: Weight
            Expanded(
              child: _buildProgressCard(
                icon: Icons.scale_rounded,
                title: 'Weight',
                value: '$currentWeightKg kg',
                trendText: '+${weightTrendKg.toStringAsFixed(1)} kg',
                isTrend: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int val) {
    if (val >= 1000) {
      final s = val.toString();
      final thousands = s.substring(0, s.length - 3);
      final hundreds = s.substring(s.length - 3);
      return '$thousands,$hundreds';
    }
    return val.toString();
  }

  Widget _buildProgressCard({
    required IconData icon,
    required String title,
    required String value,
    String? subValue,
    double? progress,
    String? trendText,
    bool isTrend = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1A1D1E)),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: const Color(0xFF71767B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Metric Value
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1D1E),
                    fontSize: 14,
                  ),
                ),
                if (subValue != null)
                  TextSpan(
                    text: subValue,
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF71767B),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Progress Bar or Trend
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: const Color(0xFFE9ECEF),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB8E66B)),
              ),
            )
          else if (isTrend && trendText != null)
            Row(
              children: [
                const Icon(
                  Icons.arrow_outward_rounded,
                  color: Color(0xFF65A30D),
                  size: 13,
                ),
                const SizedBox(width: 3),
                Text(
                  trendText,
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF65A30D),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

