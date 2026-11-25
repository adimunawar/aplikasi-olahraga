import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/core/widgets/core_widgets.dart';

/// Menampilkan bottom sheet pemilih opsi terstandarisasi untuk App Settings.
Future<void> showAppSettingsPickerSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  required String selectedValue,
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final isDark = theme.brightness == Brightness.dark;
      final colorScheme = theme.colorScheme;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const Divider(height: 1),
            ...options.map((option) {
              final isSelected = option == selectedValue;
              return ListTile(
                title: Text(
                  option,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: isDark
                            ? colorScheme.primary
                            : AppColors.greenBrand,
                      )
                    : null,
                tileColor: isSelected
                    ? (isDark
                          ? colorScheme.primaryContainer
                          : AppColors.limeCardSurface)
                    : Colors.transparent,
                onTap: () {
                  onSelected(option);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      );
    },
  );
}

/// Kartu baris navigasi untuk memilih opsi pada halaman App Settings.
class AppSettingsNavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String valueText;
  final VoidCallback onTap;

  const AppSettingsNavigationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.valueText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onTap,
      variant: AppCardVariant.flat,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface),
          const SizedBox(width: 14),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            valueText,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}

/// Kartu toggle switch pada halaman App Settings.
class AppSettingsSwitchCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppSettingsSwitchCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: colorScheme.onPrimary,
            activeTrackColor: colorScheme.primary,
            inactiveThumbColor: colorScheme.onSurfaceVariant,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
