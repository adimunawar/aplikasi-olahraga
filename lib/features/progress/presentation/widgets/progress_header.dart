import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Header Halaman Progress:
/// - Judul besar: "Progress"
/// - Subtitle: "Track your workouts and consistency."
/// - Latar belakang ambient glow lime di pojok kanan atas
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ambient soft lime glow di pojok kanan atas
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.limeAccent.withValues(alpha: 0.35),
                  AppColors.limeAccent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // Konten Teks
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress',
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: AppColors.darkCharcoal,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track your workouts and consistency.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
