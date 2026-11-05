import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Card "Program Progress" di bagian bawah Halaman Progress:
/// - Icon target/sasaran dalam lingkaran lime lembut
/// - Judul: "Program Progress" & Subtitle: "Upper Body Strength"
/// - Info kanan atas: "Week X of Y"
/// - Bar segmen minggu terisi hijau lime dengan persentase di kanan
class ProgramProgressBottomCard extends StatelessWidget {
  final String programTitle;
  final int currentWeek;
  final int totalWeeks;
  final int percent;

  const ProgramProgressBottomCard({
    super.key,
    this.programTitle = 'Upper Body Strength',
    this.currentWeek = 3,
    this.totalWeeks = 8,
    this.percent = 37,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.limeCardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.limeCardBorder, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Icon + Judul/Subtitle + "Week X of Y"
          Row(
            children: [
              // Icon Target Bulat Lime Lembut
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.limeSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  size: 20,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(width: 10),

              // Judul & Subtitle Program
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Program Progress',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      programTitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Info Minggu Kanan
              Text(
                'Week $currentWeek of $totalWeeks',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Baris 2: Segmen Pill Progress + Label Persentase
          Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(totalWeeks > 0 ? totalWeeks : 8, (index) {
                    final isFilled = index < currentWeek;
                    final total = totalWeeks > 0 ? totalWeeks : 8;
                    return Expanded(
                      child: Container(
                        height: 9,
                        margin: EdgeInsets.only(
                          right: index < total - 1 ? 5 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: isFilled
                              ? AppColors.primary
                              : AppColors.neutral200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent%',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
