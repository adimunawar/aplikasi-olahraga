import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Step 4 of 7: What's your experience level? (Mockup 1:1)
class StepExperience extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onLevelSelected;

  const StepExperience({
    super.key,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your experience level?",
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose an option that best describes you.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          _buildLevelCard(
            id: 'beginner',
            title: 'Beginner',
            description: 'New to training or exercising inconsistently.',
            icon: Icons.spa_rounded,
          ),
          const SizedBox(height: 14),

          _buildLevelCard(
            id: 'intermediate',
            title: 'Intermediate',
            description: 'Have some experience and train regularly.',
            icon: Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 14),

          _buildLevelCard(
            id: 'advanced',
            title: 'Advanced',
            description:
                'Train consistently, have good form, and want a bigger challenge.',
            icon: Icons.military_tech_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required String id,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = selectedLevel == id;

    return InkWell(
      onTap: () => onLevelSelected(id),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4F9ED) : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF84CC16) : AppColors.neutral200,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.limeAccent.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.limeCardSurface
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.greenDark : AppColors.neutral600,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF84CC16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

