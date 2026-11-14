import 'package:flutter/material.dart';
import '../../../../core/widgets/core_widgets.dart';

/// Tombol Sticky "Start Workout" di bagian bawah layar Workout Detail (DRY via AppButton)
class StartWorkoutBottomBar extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const StartWorkoutBottomBar({
    super.key,
    required this.onStartWorkout,
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
          text: 'Start Workout',
          icon: Icons.play_arrow_rounded,
          onPressed: onStartWorkout,
        ),
      ),
    );
  }
}
