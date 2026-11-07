import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/movement_volume_data.dart';

/// Card Visualisasi Volume Latihan Per Movement Pattern (Fase 5: Biomechanical Balance)
/// Menampilkan distribusi Sets & Reps pada Push, Pull, Squat, Hinge, dan Core
class WeeklyMovementVolumeCard extends StatelessWidget {
  final List<MovementVolumeData> volumeData;

  const WeeklyMovementVolumeCard({
    super.key,
    required this.volumeData,
  });

  @override
  Widget build(BuildContext context) {
    final pushData = _getPatternData('push');
    final pullData = _getPatternData('pull');
    final squatData = _getPatternData('squat');
    final hingeData = _getPatternData('hinge');
    final coreData = _getPatternData('core');

    final maxSets = [
      pushData.totalSets,
      pullData.totalSets,
      squatData.totalSets,
      hingeData.totalSets,
      coreData.totalSets,
      1,
    ].reduce((a, b) => a > b ? a : b);

    // Hitung rasio keseimbangan Push vs Pull
    final pushPullRatio = pullData.totalSets > 0
        ? (pushData.totalSets / pullData.totalSets).toStringAsFixed(1)
        : '1.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris 1: Icon & Judul
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.limeAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.darkCharcoal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribusi Volume Otot',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Akumulasi Sets & Reps minggu ini',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge Keseimbangan Push vs Pull
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F9D7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.balance_rounded,
                      color: Color(0xFF16A34A),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'P:P $pushPullRatio:1',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF16A34A),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Baris 2: List Movement Patterns
          _buildVolumeRow(
            icon: Icons.upload_rounded,
            color: const Color(0xFF2563EB),
            label: 'Push (Dada & Bahu)',
            sets: pushData.totalSets,
            reps: pushData.totalReps,
            progress: pushData.totalSets / maxSets,
          ),
          const SizedBox(height: 12),
          _buildVolumeRow(
            icon: Icons.download_rounded,
            color: const Color(0xFF16A34A),
            label: 'Pull (Punggung & Biceps)',
            sets: pullData.totalSets,
            reps: pullData.totalReps,
            progress: pullData.totalSets / maxSets,
          ),
          const SizedBox(height: 12),
          _buildVolumeRow(
            icon: Icons.airline_seat_legroom_extra_rounded,
            color: const Color(0xFFD97706),
            label: 'Squat (Paha Depan)',
            sets: squatData.totalSets,
            reps: squatData.totalReps,
            progress: squatData.totalSets / maxSets,
          ),
          const SizedBox(height: 12),
          _buildVolumeRow(
            icon: Icons.accessibility_new_rounded,
            color: const Color(0xFFDC2626),
            label: 'Hinge (Paha Belakang & Glutes)',
            sets: hingeData.totalSets,
            reps: hingeData.totalReps,
            progress: hingeData.totalSets / maxSets,
          ),
          const SizedBox(height: 12),
          _buildVolumeRow(
            icon: Icons.shield_rounded,
            color: const Color(0xFF9333EA),
            label: 'Core (Perut & Pinggang)',
            sets: coreData.totalSets,
            reps: coreData.totalReps,
            progress: coreData.totalSets / maxSets,
          ),
        ],
      ),
    );
  }

  MovementVolumeData _getPatternData(String pattern) {
    try {
      return volumeData.firstWhere(
        (v) => v.pattern.toLowerCase().trim() == pattern,
        orElse: () => MovementVolumeData(pattern: pattern, totalSets: 0, totalReps: 0),
      );
    } catch (_) {
      return MovementVolumeData(pattern: pattern, totalSets: 0, totalReps: 0);
    }
  }

  Widget _buildVolumeRow({
    required IconData icon,
    required Color color,
    required String label,
    required int sets,
    required int reps,
    required double progress,
  }) {
    final clampedProgress = progress.clamp(0.05, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkCharcoal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Text(
              '$sets sets • $reps reps',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Progress Bar
        Stack(
          children: [
            Container(
              height: 7,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: clampedProgress,
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

