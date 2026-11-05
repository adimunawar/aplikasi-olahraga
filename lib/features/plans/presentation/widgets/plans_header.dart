import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Header Halaman Plans (Mockup Baru):
/// - Judul besar: "Plans"
/// - Subtitle: "Choose a program and follow a structured plan."
class PlansHeader extends StatelessWidget {
  const PlansHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plans',
            style: AppTypography.headlineLarge.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: AppColors.darkCharcoal,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a program and follow a structured plan.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
