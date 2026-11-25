import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

enum AppCardVariant {
  surface, // Standar kartu surface (adaptif Light & Dark Mode)
  tintedLime, // Kartu hijau muda (Rest card / active highlight)
  flat, // Tanpa shadow
}

/// AppCard: Container Kartu Standar Desain Sistem (DRY Principle).
///
/// Menggantikan penulisan BoxDecoration(color, borderRadius, border, boxShadow)
/// yang berulang-ulang dan mendukung Light Mode serta Dark Mode.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final AppCardVariant variant;
  final double borderRadius;
  final double borderWidth;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.variant = AppCardVariant.surface,
    this.borderRadius = 18.0,
    this.borderWidth = 1.2,
  });

  /// Factory untuk kartu bernuansa hijau muda (Rest Card / Hero Plan)
  factory AppCard.tinted({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    VoidCallback? onTap,
    double borderRadius = 18.0,
  }) {
    return AppCard(
      key: key,
      padding: padding,
      onTap: onTap,
      variant: AppCardVariant.tintedLime,
      borderRadius: borderRadius,
      child: child,
    );
  }

  /// Menghasilkan [BoxDecoration] kartu standar yang adaptif terhadap tema.
  /// Berguna untuk widget yang membutuhkan dekorasi kartu langsung (mis. `.copyWith`).
  static BoxDecoration decoration(
    BuildContext context, {
    AppCardVariant variant = AppCardVariant.surface,
    double borderRadius = 18.0,
    double borderWidth = 1.2,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final Color backgroundColor;
    final Color borderColor;

    switch (variant) {
      case AppCardVariant.surface:
      case AppCardVariant.flat:
        backgroundColor = colorScheme.surface;
        borderColor = isDark ? colorScheme.outline : AppColors.cardBorder;
      case AppCardVariant.tintedLime:
        backgroundColor = isDark
            ? colorScheme.primaryContainer
            : AppColors.limeCardSurface;
        borderColor = isDark
            ? colorScheme.primary.withValues(alpha: 0.4)
            : AppColors.limeCardBorder;
    }

    final List<BoxShadow>? boxShadow =
        (variant == AppCardVariant.flat || isDark)
        ? null
        : AppColors.cardShadow;

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: boxShadow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardDecoration = decoration(
      context,
      variant: variant,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: cardDecoration,
          child: child,
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: cardDecoration,
      child: child,
    );
  }
}
