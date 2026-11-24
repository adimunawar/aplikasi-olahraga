import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/app_button.dart';

/// Tombol Sticky "Start Workout" di bagian bawah layar Workout Detail (DRY via AppButton)
class StartWorkoutBottomBar extends StatelessWidget {
  final VoidCallback onStartWorkout;
  final String label;
  final IconData icon;

  const StartWorkoutBottomBar({
    super.key,
    required this.onStartWorkout,
    this.label = 'Start Workout',
    this.icon = Icons.play_arrow_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final borderColor = isDark
        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.25)
        : theme.dividerColor.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: AppButton.primary(
          text: label,
          icon: icon,
          onPressed: onStartWorkout,
        ),
      ),
    );
  }
}
