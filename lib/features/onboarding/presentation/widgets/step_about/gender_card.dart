import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import 'gender_card_glow_painter.dart';

class GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderCard({
    super.key,
    required this.label,
    required this.icon,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final accentColor = isDark ? colorScheme.primary : AppColors.greenBrand;

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 218,
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? accentColor : colorScheme.outlineVariant,
                width: isSelected ? 2.0 : 1.2,
              ),
              boxShadow: isDark
                  ? (isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(
                                alpha: 0.22,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null)
                  : (isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : AppColors.cardShadow),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GenderCardGlowPainter(
                        accentColor: colorScheme.primary,
                        isSelected: isSelected,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 10,
                    bottom: 40,
                    child: AnimatedScale(
                      scale: isSelected ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          icon,
                          size: 64,
                          color: isSelected
                              ? accentColor
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                          width: 1.6,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? colorScheme.surface
                                    : colorScheme.surfaceContainerHighest)
                                .withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? accentColor.withValues(alpha: 0.4)
                              : colorScheme.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: isSelected
                                ? accentColor
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                fontSize: 13.5,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 18,
                            height: 12,
                            child: CustomPaint(
                              painter: DiagonalAccentStripesPainter(
                                color: isSelected
                                    ? accentColor
                                    : colorScheme.onSurfaceVariant.withValues(
                                        alpha: 0.45,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
