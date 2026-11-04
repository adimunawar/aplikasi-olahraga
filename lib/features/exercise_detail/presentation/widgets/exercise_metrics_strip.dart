import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Strip 4 Kolom Metrik Latihan: Sets, Reps, Rest, Level.
class ExerciseMetricsStrip extends StatelessWidget {
  final Exercise exercise;
  final int sets;
  final String reps;
  final String rest;

  const ExerciseMetricsStrip({
    super.key,
    required this.exercise,
    this.sets = 3,
    this.reps = '8 – 15',
    this.rest = '60 – 90s',
  });

  @override
  Widget build(BuildContext context) {
    final repText = exercise.trackingType == TrackingType.duration ? '30-45 dtk' : reps;
    final levelText = exercise.difficulty.localizedName('id');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildMetricPill(
            icon: Icons.calendar_today_outlined,
            label: 'Sets',
            value: '$sets',
            color: const Color(0xFF65A30D),
          ),
          _buildVerticalDivider(),
          _buildMetricPill(
            icon: Icons.loop_rounded,
            label: 'Reps',
            value: repText,
            color: const Color(0xFF65A30D),
          ),
          _buildVerticalDivider(),
          _buildMetricPill(
            icon: Icons.timer_outlined,
            label: 'Rest',
            value: rest,
            color: const Color(0xFF65A30D),
          ),
          _buildVerticalDivider(),
          _buildMetricPill(
            icon: Icons.bar_chart_rounded,
            label: 'Level',
            value: levelText,
            color: const Color(0xFF65A30D),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

