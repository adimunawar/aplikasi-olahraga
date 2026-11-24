import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';

/// Toggle pil navigasi tab: [ Program Saya ] | [ Semua Latihan ]
class WorkoutsPillToggle extends StatelessWidget {
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final String myProgramTitle;
  final String allWorkoutsTitle;

  const WorkoutsPillToggle({
    super.key,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.myProgramTitle,
    required this.allWorkoutsTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final containerColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : const Color(0xFFF3F4F6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildItem(
                context: context,
                title: myProgramTitle,
                isSelected: selectedTabIndex == 0,
                onTap: () => onTabChanged(0),
              ),
            ),
            Expanded(
              child: _buildItem(
                context: context,
                title: allWorkoutsTitle,
                isSelected: selectedTabIndex == 1,
                onTap: () => onTabChanged(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final unselectedTextColor = theme.colorScheme.onSurfaceVariant;
    const selectedTextColor = Color(0xFF141718);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13.5,
              color: isSelected ? selectedTextColor : unselectedTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
