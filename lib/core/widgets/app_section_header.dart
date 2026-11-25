import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// AppSectionHeader: Header Section Standar (DRY Principle).
///
/// Mendukung Light Mode & Dark Mode secara otomatis via [ColorScheme],
/// serta mendukung [icon] dan [subtitle] opsional.
class AppSectionHeader extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? actionText;
  final VoidCallback? onActionTap;
  final double iconSize;
  final double titleSize;
  final FontWeight titleWeight;

  const AppSectionHeader({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.actionText,
    this.onActionTap,
    this.iconSize = 20.0,
    this.titleSize = 16.5,
    this.titleWeight = FontWeight.w800,
  });

  /// Factory untuk header dengan tombol teks aksi (e.g. "See All")
  factory AppSectionHeader.withAction({
    Key? key,
    IconData? icon,
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

  /// Factory untuk header dengan teks info statis di sebelah kanan
  factory AppSectionHeader.withSubtitle({
    Key? key,
    IconData? icon,
    required String title,
    required String subtitle,
  }) {
    return AppSectionHeader(
      key: key,
      icon: icon,
      title: title,
      trailing: Builder(
        builder: (context) => Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

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
              color: isDark ? colorScheme.primary : AppColors.greenDark,
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
        Expanded(
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: titleWeight,
                        fontSize: titleSize,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        ?rightWidget,
        ?rightWidget,
      ],
    );
  }
}
