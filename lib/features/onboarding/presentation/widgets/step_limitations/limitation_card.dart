import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class LimitationCard extends StatelessWidget {
  final String label;
  final String? imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const LimitationCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final backgroundColor = isSelected
        ? colorScheme.primary
        : (isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface);
    final foregroundColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final dividerColor = isSelected
        ? colorScheme.onPrimary.withValues(alpha: 0.25)
        : colorScheme.outlineVariant.withValues(alpha: 0.5);

    return AnimatedScale(
      scale: isSelected ? 1.015 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 1.8 : 1.2,
              ),
              boxShadow: isDark
                  ? (isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null)
                  : (isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(
                                alpha: 0.24,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : AppColors.cardShadow),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 58,
                  child: imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.healing_rounded,
                              size: 28,
                              color: isSelected
                                  ? foregroundColor
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.monitor_heart_outlined,
                            size: 32,
                            color: isSelected
                                ? foregroundColor
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Container(width: 1, height: 36, color: dividerColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      fontSize: 14.5,
                      height: 1.25,
                      color: foregroundColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      width: 1.6,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            key: const ValueKey('checked'),
                            size: 15,
                            color: colorScheme.primary,
                          )
                        : const SizedBox.shrink(key: ValueKey('unchecked')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
