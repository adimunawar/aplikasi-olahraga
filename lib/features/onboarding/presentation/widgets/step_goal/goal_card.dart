import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../i18n/strings.g.dart';
import 'goal_selection_indicator.dart';
import 'slanted_goal_card_painter.dart';

class GoalCard extends StatelessWidget {
  final GoalOption option;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.option,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final cardBackground = isSelected
        ? colorScheme.primary
        : (isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface);
    final cardGradientColors = isSelected
        ? [
            colorScheme.primary,
            Color.lerp(colorScheme.primary, colorScheme.tertiary, 0.25) ??
                colorScheme.primary,
          ]
        : [
            cardBackground,
            isDark
                ? colorScheme.surfaceContainer
                : colorScheme.surfaceContainerLow,
          ];
    final titleColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final descriptionColor = isSelected
        ? colorScheme.onPrimary.withValues(alpha: 0.85)
        : colorScheme.onSurfaceVariant;
    final borderColor = isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: SizedBox(
        height: 140,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: const SlantedGoalCardClipper(),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: CustomPaint(
                      painter: SlantedGoalCardPainter(
                        gradientColors: cardGradientColors,
                        borderColor: borderColor,
                        borderWidth: isSelected ? 2.0 : 1.2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(168, 18, 16, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 17,
                                      height: 1.2,
                                      color: titleColor,
                                    ),
                                    child: Text(
                                      option.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: descriptionColor,
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                    child: Text(
                                      option.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GoalSelectionIndicator(
                              isSelected: isSelected,
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: ClipPath(
                clipper: const SlantedGoalBottomClipper(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutBack,
                      left: isSelected ? -12 : -10,
                      bottom: -4,
                      top: isSelected ? -28 : -20,
                      width: 180,
                      child: IgnorePointer(
                        child: AnimatedScale(
                          scale: isSelected ? 1.06 : 1.0,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutBack,
                          alignment: Alignment.bottomLeft,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomLeft,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.fitness_center_rounded,
                              size: 48,
                              color: titleColor.withValues(alpha: 0.6),
                            ),
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
    );
  }
}
