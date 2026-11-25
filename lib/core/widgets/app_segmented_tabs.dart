import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_typography.dart';

/// Item definisi untuk satu segmen pada [AppSegmentedTabs].
class AppSegmentedTabItem<T> {
  final T value;
  final String label;

  const AppSegmentedTabItem({
    required this.value,
    required this.label,
  });
}

/// Tab bar terstandarisasi mengikuti spesifikasi Google Material 3
/// (`SegmentedButton`) dengan dukungan penuh Light Mode dan Dark Mode.
class AppSegmentedTabs<T> extends StatelessWidget {
  final List<AppSegmentedTabItem<T>> tabs;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  const AppSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: [
          for (final tab in tabs)
            ButtonSegment<T>(
              value: tab.value,
              label: Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
        ],
        selected: {selectedValue},
        onSelectionChanged: (selection) {
          if (selection.isNotEmpty) {
            onChanged(selection.first);
          }
        },
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: colorScheme.primary,
          selectedForegroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurfaceVariant,
          side: BorderSide(color: colorScheme.outline),
          textStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
    );
  }
}
