import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import 'onboarding_cta_button.dart';
import 'onboarding_dots_indicator.dart';

/// Step 2 Onboarding: What's Your Goal?
/// 3 Pilihan: Build Muscle (Bulking), Get Stronger, Improve Fitness.
class OnboardingGoalStep extends StatelessWidget {
  final String selectedGoal;
  final ValueChanged<String> onGoalSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingGoalStep({
    super.key,
    required this.selectedGoal,
    required this.onGoalSelected,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D1E)),
          onPressed: onBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "What's Your\nGoal?",
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1D1E),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your main goal. You can always change it later.',
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF71767B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),

              // Option 1: Build Muscle (Bulking)
              _buildGoalOption(
                id: 'muscle_gain',
                title: 'Build Muscle',
                subtitle: '(Bulking)',
                icon: Icons.fitness_center_rounded,
                isSelected: selectedGoal == 'muscle_gain',
              ),
              const SizedBox(height: 14),

              // Option 2: Get Stronger
              _buildGoalOption(
                id: 'strength',
                title: 'Get Stronger',
                subtitle: '(More power & endurance)',
                icon: Icons.bolt_rounded,
                isSelected: selectedGoal == 'strength',
              ),
              const SizedBox(height: 14),

              // Option 3: Improve Fitness
              _buildGoalOption(
                id: 'fitness',
                title: 'Improve Fitness',
                subtitle: '(Health, stamina & shape)',
                icon: Icons.favorite_outline_rounded,
                isSelected: selectedGoal == 'fitness',
              ),

              const Spacer(),

              // Dots Indicator (Step 2: Index 0 dari 5)
              const OnboardingDotsIndicator(activeIndex: 0, totalDots: 5),
              const SizedBox(height: 16),

              // CTA Button: Next → (Reusable)
              OnboardingCtaButton(
                text: 'Next',
                onPressed: onNext,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onGoalSelected(id),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F9EA) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFB8E66B) : const Color(0xFFE9ECEF),
            width: isSelected ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0x1265A30D) : const Color(0x04000000),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE4F3D2) : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF5B8E1B) : const Color(0xFF1A1D1E),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1D1E),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected ? const Color(0xFF5B8E1B) : const Color(0xFF71767B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Selection Checkmark Circle
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF65A30D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

