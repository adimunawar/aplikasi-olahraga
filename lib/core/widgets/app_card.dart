import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppCardVariant {
  surface, // Standar kartu putih
  tintedLime, // Kartu hijau muda (Rest card / active highlight)
  flat, // Tanpa shadow
}

/// AppCard: Container Kartu Standar Desain Sistem (DRY Principle).
///
/// Menggantikan penulisan BoxDecoration(color, borderRadius, border, boxShadow) yang berulang-ulang.
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

  Color get _backgroundColor {
    switch (variant) {
      case AppCardVariant.surface:
      case AppCardVariant.flat:
        return AppColors.surface;
      case AppCardVariant.tintedLime:
        return AppColors.limeCardSurface;
    }
  }

  Color get _borderColor {
    switch (variant) {
      case AppCardVariant.surface:
      case AppCardVariant.flat:
        return AppColors.cardBorder;
      case AppCardVariant.tintedLime:
        return AppColors.limeCardBorder;
    }
  }

  List<BoxShadow>? get _boxShadow {
    if (variant == AppCardVariant.flat) return null;
    return AppColors.cardShadow;
  }

  @override
  Widget build(BuildContext context) {
    final cardDecoration = BoxDecoration(
      color: _backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: _borderColor, width: borderWidth),
      boxShadow: _boxShadow,
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
