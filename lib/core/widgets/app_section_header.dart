import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// AppSectionHeader: Header Section Standar (DRY Principle).
///
/// Menggantikan penulisan berulang:
/// Row(
///   mainAxisAlignment: MainAxisAlignment.spaceBetween,
///   children: [
///     Row(children: [Icon(...), SizedBox(width: 8), Text(title)]),
///     trailing,
///   ]
/// )
class AppSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final String? actionText;
  final VoidCallback? onActionTap;
  final double iconSize;
  final double titleSize;

  const AppSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.actionText,
    this.onActionTap,
    this.iconSize = 20.0,
    this.titleSize = 16.5,
  });

  /// Factory untuk header dengan tombol teks aksi (e.g. "See All")
  factory AppSectionHeader.withAction({
    Key? key,
    required IconData icon,
    required String title,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    return AppSectionHeader(
      key: key,
      icon: icon,
      title: title,
      actionText: actionText,
      onActionTap: onActionTap,
    );
  }

  /// Factory untuk header dengan teks info statis (e.g. "8 weeks • 4 days/week")
  factory AppSectionHeader.withSubtitle({
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return AppSectionHeader(
      key: key,
      icon: icon,
      title: title,
      trailing: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.neutral500,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? rightWidget = trailing;

    if (actionText != null && rightWidget == null) {
      rightWidget = InkWell(
        onTap: onActionTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            actionText!,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.greenDark,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: iconSize,
              color: AppColors.darkCharcoal,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: titleSize,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
        if (rightWidget != null) rightWidget,
      ],
    );
  }
}

