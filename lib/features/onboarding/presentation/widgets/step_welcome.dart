import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_smart_image.dart';

/// Step 0: Welcome Screen Content (Mockup 1:1, Tanpa Bottom Bar - dihandle wrapper)
class StepWelcome extends StatelessWidget {
  const StepWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Logo "Workout Coach" di Kiri Atas
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF84CC16),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 18,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Workout\nCoach',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  height: 1.1,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Hero Coach Image (Terpusat)
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.44,
              constraints: const BoxConstraints(maxHeight: 380),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Latar Belakang Lingkaran Glow Halus
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.limeAccent.withOpacity(0.18),
                    ),
                  ),
                  const AppSmartImage(
                    imagePathOrUrl: 'assets/images/coach_hero.png',
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Judul & Subtitle
          Text(
            'Your Personal\nWorkout Coach',
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 28,
              height: 1.15,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Get a workout program based\non your goal, body condition,\nand lifestyle.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

