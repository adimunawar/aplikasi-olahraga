import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Card "Streak" pada Halaman Progress (1:1 sesuai mockup):
/// - Icon petir dalam squircle lime lembut
/// - Judul: "Streak" & Subtitle: "Keep it up!"
/// - Badge bulat lime lembut di kanan dengan angka besar dan label "days"
class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({super.key, this.streakDays = 3});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Petir dalam Squircle Lime Lembut
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.limeSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt_rounded,
              size: 21,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(width: 8),

          // Teks Judul & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Streak',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Keep it up!',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),

          // Bulatan Nilai Hari di Kanan
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.limeSurface,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$streakDays',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1.0,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'days',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenDark,
                    height: 1.0,
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
