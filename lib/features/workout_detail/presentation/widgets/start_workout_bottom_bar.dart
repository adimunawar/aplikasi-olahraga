import 'package:material_ui/material_ui.dart';
import '../../../../core/widgets/core_widgets.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
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
