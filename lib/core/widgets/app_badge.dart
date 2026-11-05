import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppBadgeVariant {
  limeAccent, // Background neon lime, teks gelap (misal: "Current Plan")
  limeSoft, // Background soft lime tint, border lime, teks hijau gelap (misal: "BULKING")
  neutral, // Background abu soft, teks abu (misal: "INTERMEDIATE")
  success, // Centang selesai hijau
}

/// AppBadge: Chip/Badge Standar Desain Sistem (DRY Principle).
///
/// Menggantikan pembuatan container badge berulang-ulang di berbagai kartu.
class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  /// Factory untuk badge "Current Plan" (Neon Lime)
  factory AppBadge.currentPlan({Key? key, String label = 'Current Plan'}) {
    return AppBadge(
      key: key,
      label: label,
      variant: AppBadgeVariant.limeAccent,
      fontSize: 11.5,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  /// Factory untuk badge Kategori (Soft Lime + Border)
  factory AppBadge.category({Key? key, required String label}) {
    return AppBadge(
      key: key,
      label: label.toUpperCase(),
      variant: AppBadgeVariant.limeSoft,
      fontSize: 11.0,
    );
  }

  /// Factory untuk badge Difficulty (Neutral)
  factory AppBadge.difficulty({Key? key, required String label}) {
    return AppBadge(
      key: key,
      label: label.toUpperCase(),
      variant: AppBadgeVariant.neutral,
      fontSize: 11.0,
    );
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppBadgeVariant.limeAccent:
        return AppColors.limeAccent;
      case AppBadgeVariant.limeSoft:
        return AppColors.limeCardSurface;
      case AppBadgeVariant.neutral:
        return AppColors.neutral100;
      case AppBadgeVariant.success:
        return AppColors.primary;
    }
  }

  Color get _textColor {
    switch (variant) {
      case AppBadgeVariant.limeAccent:
        return AppColors.darkCharcoal;
      case AppBadgeVariant.limeSoft:
        return AppColors.greenDark;
      case AppBadgeVariant.neutral:
        return AppColors.neutral600;
      case AppBadgeVariant.success:
        return AppColors.darkCharcoal;
    }
  }

  Border? get _border {
    if (variant == AppBadgeVariant.limeSoft) {
      return Border.all(color: AppColors.limeCardBorder);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: _border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: _textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

