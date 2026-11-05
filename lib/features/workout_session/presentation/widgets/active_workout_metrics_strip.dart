import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Strip Metrik Sesi Aktif: Sets (1/3), Reps (8-12), Rest (60 sec)
class ActiveWorkoutMetricsStrip extends StatelessWidget {
  final String setsText;
  final String repsText;
  final String restText;

  const ActiveWorkoutMetricsStrip({
    super.key,
    required this.setsText,
    required this.repsText,
    required this.restText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Kolom 1: Sets
          Expanded(
            child: _buildMetricItem(
              icon: Icons.layers_rounded,
              label: 'Sets',
              value: setsText,
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: const Color(0xFFF1F5F9),
          ),

          // Kolom 2: Reps
          Expanded(
            child: _buildMetricItem(
              icon: Icons.cached_rounded,
              label: 'Reps',
              value: repsText,
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: const Color(0xFFF1F5F9),
          ),

          // Kolom 3: Rest
          Expanded(
            child: _buildMetricItem(
              icon: Icons.access_time_rounded,
              label: 'Rest',
              value: restText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: const Color(0xFF141718)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
                color: const Color(0xFF141718),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

