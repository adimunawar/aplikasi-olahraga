import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant {
  primary, // Lime Accent (Aksi utama/CTA)
  secondary, // Soft Neutral (Aksi sekunder)
  outline, // Border saja
  danger, // Merah/Batal
}

enum AppButtonSize {
  small, // Tinggi 38dp (Pill / Modal Action)
  medium, // Tinggi 46dp (Standar)
  large, // Tinggi 52dp (CTA Utama / Full Width)
}

/// AppButton: Tombol Standar Desain Sistem (DRY Principle).
///
/// Mencegah penulisan ElevatedButton.styleFrom berulang-ulang di berbagai layar.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
  });

  /// Factory untuk Tombol Utama CTA (Lime Accent)
  factory AppButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
    double? width,
    AppButtonSize size = AppButtonSize.large,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: width != null ? false : isFullWidth,
      width: width,
    );
  }

  /// Factory untuk Tombol Sekunder / Batal
  factory AppButton.secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isFullWidth = false,
    double? width,
    AppButtonSize size = AppButtonSize.medium,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      size: size,
      icon: icon,
      isFullWidth: width != null ? false : isFullWidth,
      width: width,
    );
  }

  /// Factory untuk Tombol Outline
  factory AppButton.outline({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isFullWidth = false,
    double? width,
    AppButtonSize size = AppButtonSize.medium,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.outline,
      size: size,
      icon: icon,
      isFullWidth: width != null ? false : isFullWidth,
      width: width,
    );
  }

  /// Factory untuk Tombol Danger / Batal
  factory AppButton.danger({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
    double? width,
    AppButtonSize size = AppButtonSize.large,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.danger,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: width != null ? false : isFullWidth,
      width: width,
    );
  }

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return 38.0;
      case AppButtonSize.medium:
        return 46.0;
      case AppButtonSize.large:
        return 52.0;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 13.0;
      case AppButtonSize.medium:
        return 14.5;
      case AppButtonSize.large:
        return 16.0;
    }
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.limeAccent;
      case AppButtonVariant.secondary:
        return AppColors.neutral100;
      case AppButtonVariant.outline:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.darkCharcoal;
      case AppButtonVariant.secondary:
        return AppColors.darkCharcoal;
      case AppButtonVariant.outline:
        return AppColors.darkCharcoal;
      case AppButtonVariant.danger:
        return const Color(0xFFDC2626);
    }
  }

  BorderSide? get _borderSide {
    if (variant == AppButtonVariant.outline) {
      return const BorderSide(color: AppColors.neutral200, width: 1.2);
    }
    if (variant == AppButtonVariant.danger) {
      return const BorderSide(color: Color(0xFFFCA5A5), width: 1.2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: _borderSide ?? BorderSide.none,
    );

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: _foregroundColor,
        ),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _fontSize + 3, color: _foregroundColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: _fontSize,
              color: _foregroundColor,
            ),
          ),
        ],
      );
    } else {
      childContent = Text(
        text,
        style: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: _fontSize,
          color: _foregroundColor,
        ),
      );
    }

    final button = SizedBox(
      height: _height,
      width: width ?? (isFullWidth ? double.infinity : null),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _foregroundColor,
          disabledBackgroundColor: _backgroundColor.withValues(alpha: 0.5),
          elevation: 0,
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: childContent,
      ),
    );

    return button;
  }
}
