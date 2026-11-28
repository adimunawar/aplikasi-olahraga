import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import 'equipment_card_glow_painter.dart';

class EquipmentCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final IconData fallbackIcon;
  final bool isBodyweight;
  final bool isSelected;
  final VoidCallback onTap;

  const EquipmentCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.fallbackIcon,
    required this.isBodyweight,
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

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 2.0 : 1.2,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  if (!isSelected)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: EquipmentCardGlowPainter(
                          accentColor: colorScheme.primary,
                          isSelected: false,
                        ),
                      ),
                    ),
                  if (isBodyweight)
                    _BodyweightContent(
                      label: label,
                      imagePath: imagePath,
                      fallbackIcon: fallbackIcon,
                      isSelected: isSelected,
                      foregroundColor: foregroundColor,
                    )
                  else
                    _StandardEquipmentContent(
                      label: label,
                      imagePath: imagePath,
                      fallbackIcon: fallbackIcon,
                      isSelected: isSelected,
                      foregroundColor: foregroundColor,
                    ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: colorScheme.primary,
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

class _BodyweightContent extends StatelessWidget {
  final String label;
  final String imagePath;
  final IconData fallbackIcon;
  final bool isSelected;
  final Color foregroundColor;

  const _BodyweightContent({
    required this.label,
    required this.imagePath,
    required this.fallbackIcon,
    required this.isSelected,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          right: -6,
          top: 6,
          bottom: 0,
          width: 98,
          child: AnimatedScale(
            scale: isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            alignment: Alignment.bottomRight,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              errorBuilder: (context, error, stackTrace) => Icon(
                fallbackIcon,
                size: 44,
                color: isSelected
                    ? foregroundColor
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          right: 78,
          top: 12,
          bottom: 12,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                fontSize: 13.5,
                height: 1.2,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StandardEquipmentContent extends StatelessWidget {
  final String label;
  final String imagePath;
  final IconData fallbackIcon;
  final bool isSelected;
  final Color foregroundColor;

  const _StandardEquipmentContent({
    required this.label,
    required this.imagePath,
    required this.fallbackIcon,
    required this.isSelected,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AnimatedScale(
              scale: isSelected ? 1.07 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  fallbackIcon,
                  size: 38,
                  color: isSelected
                      ? foregroundColor
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              fontSize: 13,
              height: 1.2,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
