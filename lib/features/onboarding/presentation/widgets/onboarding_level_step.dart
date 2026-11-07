import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import 'onboarding_cta_button.dart';
import 'onboarding_dots_indicator.dart';

/// Step 3 Onboarding: What's Your Experience Level?
/// 3 Pilihan: Beginner, Intermediate, Advanced.
class OnboardingLevelStep extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onLevelSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingLevelStep({
    super.key,
    required this.selectedLevel,
    required this.onLevelSelected,
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
                "What's Your\nExperience Level?",
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1D1E),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us set the right program for you.',
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF71767B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),

              // Option 1: Beginner
              _buildLevelCard(
                id: 'beginner',
                title: 'Beginner',
                description: 'New to training or getting back on track.',
                icon: Icons.signal_cellular_alt_1_bar_rounded,
                isSelected: selectedLevel == 'beginner',
              ),
              const SizedBox(height: 14),

              // Option 2: Intermediate
              _buildLevelCard(
                id: 'intermediate',
                title: 'Intermediate',
                description: 'Have some experience and can do basic exercises.',
                icon: Icons.signal_cellular_alt_2_bar_rounded,
                isSelected: selectedLevel == 'intermediate',
              ),
              const SizedBox(height: 14),

              // Option 3: Advanced
              _buildLevelCard(
                id: 'advanced',
                title: 'Advanced',
                description: 'Train regularly and ready for a bigger challenge.',
                icon: Icons.signal_cellular_alt_rounded,
                isSelected: selectedLevel == 'advanced',
              ),

              const Spacer(),

              // Dots Indicator (Step 3: Index 1 dari 5)
              const OnboardingDotsIndicator(activeIndex: 1, totalDots: 5),
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

  Widget _buildLevelCard({
    required String id,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onLevelSelected(id),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
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
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            icon,
                            color: isSelected ? const Color(0xFF65A30D) : const Color(0xFF71767B),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1D1E),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF71767B),
                          height: 1.35,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Posture Icon / Mini illustration
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE8F5D8) : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.sports_gymnastics_rounded,
                    size: 32,
                    color: isSelected ? const Color(0xFF65A30D) : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),

            // Top-right selection badge
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF65A30D),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

