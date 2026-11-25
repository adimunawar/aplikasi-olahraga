import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/core/widgets/core_widgets.dart';

/// Baris pilihan pill horizontal untuk form Profile (Light & Dark Mode).
class ProfileChoiceChipRow<T> extends StatelessWidget {
  final List<T> options;
  final T selectedValue;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;
  final bool Function(T, T)? equals;

  const ProfileChoiceChipRow({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onSelected,
    this.equals,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: options.map((option) {
        final isSelected = equals != null
            ? equals!(option, selectedValue)
            : option == selectedValue;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(option),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  labelBuilder(option),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13.5,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Field dropdown berbentuk kartu datar untuk form Profile (Light & Dark Mode).
class ProfileDropdownField extends StatelessWidget {
  final String valueText;
  final VoidCallback onTap;

  const ProfileDropdownField({
    super.key,
    required this.valueText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onTap,
      variant: AppCardVariant.flat,
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            valueText,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ],
      ),
    );
  }
}

/// Kartu info penjelasan dinamis pada form Profile (Light & Dark Mode).
class ProfileInfoBanner extends StatelessWidget {
  final String message;

  const ProfileInfoBanner({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return AppCard.tinted(
      borderRadius: 14,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? colorScheme.primary : AppColors.greenDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? colorScheme.onPrimaryContainer
                    : const Color(0xFF2E4E16),
                height: 1.4,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
