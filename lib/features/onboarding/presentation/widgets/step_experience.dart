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

  static const Map<String, String> _assetImages = {
    'beginner': 'assets/images/beginer.webp',
    'intermediate': 'assets/images/intermediate.webp',
    'advanced': 'assets/images/advance.webp',
  };

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.experience;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 26,
              height: 1.15,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          for (final option in t.options) ...[
            _ExperienceLevelCard(
              option: option,
              imagePath:
                  _assetImages[option.id] ?? 'assets/images/beginer.webp',
              isSelected: selectedLevel == option.id,
              onTap: () => onLevelSelected(option.id),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _ExperienceLevelCard extends StatelessWidget {
  final ExperienceOption option;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExperienceLevelCard({
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
                clipper: const _SlantedCardClipper(),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: CustomPaint(
                      painter: _SlantedCardPainter(
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
                                      fontSize: 18,
                                      color: titleColor,
                                    ),
                                    child: Text(
                                      option.title,
                                      maxLines: 1,
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
                            _SelectionIndicator(
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
            AnimatedPositioned(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              left: isSelected ? -12 : -10,
              bottom: 2,
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
    );
  }
}

Path _buildSlantedCardPath(Size size) {
  const skewY = 14.0;
  const xInset = 10.0;
  const radius = 22.0;

  final topLeft = Offset(xInset, skewY);
  final topRight = Offset(size.width, 0);
  final bottomRight = Offset(size.width - xInset, size.height - skewY);
  final bottomLeft = Offset(0, size.height);

  return Path()
    ..moveTo(topLeft.dx + radius, topLeft.dy - 1)
    ..lineTo(topRight.dx - radius, topRight.dy + 1)
    ..quadraticBezierTo(
      topRight.dx,
      topRight.dy,
      topRight.dx - 2,
      topRight.dy + radius,
    )
    ..lineTo(bottomRight.dx + 2, bottomRight.dy - radius)
    ..quadraticBezierTo(
      bottomRight.dx,
      bottomRight.dy,
      bottomRight.dx - radius,
      bottomRight.dy + 1,
    )
    ..lineTo(bottomLeft.dx + radius, bottomLeft.dy - 1)
    ..quadraticBezierTo(
      bottomLeft.dx,
      bottomLeft.dy,
      bottomLeft.dx + 2,
      bottomLeft.dy - radius,
    )
    ..lineTo(topLeft.dx - 2, topLeft.dy + radius)
    ..quadraticBezierTo(
      topLeft.dx,
      topLeft.dy,
      topLeft.dx + radius,
      topLeft.dy - 1,
    )
    ..close();
}

class _SlantedCardClipper extends CustomClipper<Path> {
  const _SlantedCardClipper();

  @override
  Path getClip(Size size) => _buildSlantedCardPath(size);

  @override
  bool shouldReclip(covariant _SlantedCardClipper oldClipper) => false;
}

class _SlantedCardPainter extends CustomPainter {
  final List<Color> gradientColors;
  final Color borderColor;
  final double borderWidth;

  const _SlantedCardPainter({
    required this.gradientColors,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildSlantedCardPath(size);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ).createShader(Offset.zero & size);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SlantedCardPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.gradientColors.first != gradientColors.first ||
        oldDelegate.gradientColors.last != gradientColors.last;
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;
  final ColorScheme colorScheme;

  const _SelectionIndicator({
    required this.isSelected,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.onPrimary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          width: 1.8,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, size: 16, color: colorScheme.primary)
          : null,
    );
  }
}
