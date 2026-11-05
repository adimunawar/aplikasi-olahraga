import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Section Workout Overview (Mockup 1:1):
/// - Bar aksen hijau + judul 'Workout Overview'
/// - Kartu 4 kolom metrik:
///   1. Exercises (misal: 5)
///   2. Sets (each) (misal: 3)
///   3. Reps (misal: 8 – 12)
///   4. Rest (misal: 60 – 90s)
class TargetMusclesOverviewSection extends StatelessWidget {
  final List<String> targetMuscles;
  final int totalExercises;
  final String setsText;
  final String repsText;
  final String restText;

  const TargetMusclesOverviewSection({
    super.key,
    this.targetMuscles = const [],
    this.totalExercises = 5,
    this.setsText = '3',
    this.repsText = '8 – 12',
    this.restText = '60 – 90s',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: | Workout Overview
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.limeAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Workout Overview',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: const Color(0xFF141718),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 4 Columns Overview Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9EFE2), width: 1.2),
          ),
          child: Row(
            children: [
              // Kolom 1: Exercises
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.fitness_center_rounded,
                  value: '$totalExercises',
                  label: 'Exercises',
                ),
              ),
              _buildDivider(),

              // Kolom 2: Sets
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.layers_rounded,
                  value: setsText.replaceAll(RegExp(r'[^0-9]'), '').isNotEmpty
                      ? setsText.replaceAll(RegExp(r'[^0-9]'), '')
                      : '3',
                  label: 'Sets (each)',
                ),
              ),
              _buildDivider(),

              // Kolom 3: Reps
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.autorenew_rounded,
                  value: repsText.replaceAll(RegExp(r'Reps|reps', caseSensitive: false), '').trim().isNotEmpty
                      ? repsText.replaceAll(RegExp(r'Reps|reps', caseSensitive: false), '').trim()
                      : '8 – 12',
                  label: 'Reps',
                ),
              ),
              _buildDivider(),

              // Kolom 4: Rest
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.access_time_rounded,
                  value: _formatRestText(restText),
                  label: 'Rest',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatRestText(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'Rest|sec|seconds', caseSensitive: false), '').trim();
    if (cleaned.isEmpty) return '60 – 90s';
    if (cleaned.endsWith('s')) return cleaned;
    return '${cleaned}s';
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE2E8F0),
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF141718)),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: const Color(0xFF141718),
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 10.5,
            color: const Color(0xFF64748B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
