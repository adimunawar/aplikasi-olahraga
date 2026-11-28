import 'package:material_ui/material_ui.dart';

class GoalSelectionIndicator extends StatelessWidget {
  final bool isSelected;
  final ColorScheme colorScheme;

  const GoalSelectionIndicator({
    super.key,
    required this.isSelected,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.onPrimary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          width: 1.8,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, size: 16, color: colorScheme.primary)
          : null,
    );
  }
}
