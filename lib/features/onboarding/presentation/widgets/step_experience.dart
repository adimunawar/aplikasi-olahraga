import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Step 4 of 7: What's your experience level? (Light & Dark Mode)
class StepExperience extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onLevelSelected;

  const StepExperience({
    super.key,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  static const Map<String, IconData> _icons = {
    'beginner': Icons.spa_rounded,
    'intermediate': Icons.fitness_center_rounded,
    'advanced': Icons.military_tech_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.experience;
    final colorScheme = Theme.of(context).colorScheme;

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
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          for (final option in t.options) ...[
            _buildLevelCard(
              context: context,
              option: option,
              icon: _icons[option.id] ?? Icons.fitness_center_rounded,
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required ExperienceOption option,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final isSelected = selectedLevel == option.id;
    final accentColor = isDark ? colorScheme.primary : AppColors.greenBrand;

    return InkWell(
      onTap: () => onLevelSelected(option.id),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accentColor : colorScheme.outline,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isDark
              ? null
              : (isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.limeAccent.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : AppColors.cardShadow),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.18)
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? (isDark ? colorScheme.primary : AppColors.greenDark)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
