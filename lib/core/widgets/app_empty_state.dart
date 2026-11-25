import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';

import 'app_card.dart';

/// Empty state standar desain sistem (DRY Principle).
///
/// Mendukung mode kartu ([useCard] = true) maupun layout bebas,
/// mode ringkas ([compact] = true), dan tema Light/Dark secara otomatis.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final bool useCard;
  final bool compact;
  final bool neutralBadge;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.useCard = true,
    this.compact = false,
    this.neutralBadge = false,
    this.margin,
    this.padding,
    this.borderRadius = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final badgeSize = compact ? 40.0 : 52.0;
    final iconSize = compact ? 20.0 : 24.0;

    final Color badgeBgColor;
    final Color badgeIconColor;
    if (neutralBadge) {
      badgeBgColor = colorScheme.surfaceContainerHighest;
      badgeIconColor = colorScheme.onSurfaceVariant;
    } else {
      badgeBgColor = isDark
          ? colorScheme.primaryContainer
          : AppColors.limeSurface;
      badgeIconColor = isDark ? colorScheme.primary : AppColors.greenDark;
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            color: badgeBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: badgeIconColor,
          ),
        ),
        SizedBox(height: compact ? 10 : 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        if (message != null && message!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
        if (action != null) ...[
          SizedBox(height: compact ? 12 : 16),
          action!,
        ],
      ],
    );

    if (!useCard) {
      return Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(child: content),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: AppCard(
          borderRadius: borderRadius,
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: 20,
                vertical: compact ? 18 : 26,
              ),
          child: content,
        ),
      ),
    );
  }
}
