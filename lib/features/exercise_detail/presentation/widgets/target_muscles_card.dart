import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'anatomy_torso_painter.dart';

/// Card diagram "Target Muscles":
/// Menampilkan diagram anatomi tubuh dengan legend otot utama & sekunder.
class TargetMusclesCard extends StatelessWidget {
  final String primaryMuscles;
  final String secondaryMuscles;

  const TargetMusclesCard({
    super.key,
    required this.primaryMuscles,
    required this.secondaryMuscles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Muscles',
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),

          // Torso Visual Outline
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(120, 60),
                painter: AnatomyTorsoPainter(),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Muscle Legends
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444), // Primary Muscle Red
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Utama: ${primaryMuscles.isNotEmpty ? primaryMuscles : "Dada"}',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCA5A5), // Secondary Muscle Coral Pink
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sekunder: ${secondaryMuscles.isNotEmpty ? secondaryMuscles : "Triceps, Bahu"}',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

