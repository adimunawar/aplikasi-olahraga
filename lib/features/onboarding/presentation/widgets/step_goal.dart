import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../../../../i18n/strings.g.dart';

/// Step 1 of 7: What's your main goal? (Mockup 1:1)
class StepGoal extends StatelessWidget {
  final String selectedGoal;
  final ValueChanged<String> onGoalSelected;

  const StepGoal({
    super.key,
    required this.selectedGoal,
    required this.onGoalSelected,
  });

  /// Gambar coach untuk tiap goal (konten id tidak perlu diterjemahkan).
  static const Map<String, String> _images = {
    'muscle_gain': 'assets/images/coach_flex.png',
    'fat_loss': 'assets/images/coach_hero.png',
    'maintenance': 'assets/images/coach_crossed_arms.png',
  };

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.goal;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          for (final option in t.options) ...[
            _buildGoalCard(
              option: option,
              imageAsset: _images[option.id] ?? '',
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required GoalOption option,
    required String imageAsset,
  }) {
    final isSelected = selectedGoal == option.id;

    return InkWell(
      onTap: () => onGoalSelected(option.id),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
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
            // Gambar Coach
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected
                    ? AppColors.limeCardSurface
                    : AppColors.neutral100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AppSmartImage(
                  imagePathOrUrl: imageAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Teks Judul & Deskripsi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 11.5,
                      height: 1.3,
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

