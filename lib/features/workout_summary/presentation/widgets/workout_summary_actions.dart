import 'package:flutter/material.dart';
import '../../../../core/widgets/core_widgets.dart';

/// Dua Tombol Aksi Bawah pada Workout Summary (DRY via AppButton):
/// 1. "Done" (Tombol Utama Hijau Lime)
/// 2. "View Progress" (Tombol Outline)
class WorkoutSummaryActions extends StatelessWidget {
  final VoidCallback onDone;
  final VoidCallback onViewProgress;

  const WorkoutSummaryActions({
    super.key,
    required this.onDone,
    required this.onViewProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Tombol Utama: Done
        AppButton.primary(
          text: 'Done',
          icon: Icons.check_circle_rounded,
          onPressed: onDone,
        ),
        const SizedBox(height: 12),

        // 2. Tombol Sekunder: View Progress
        AppButton.outline(
          text: 'View Progress',
          icon: Icons.bar_chart_rounded,
          isFullWidth: true,
          size: AppButtonSize.large,
          onPressed: onViewProgress,
        ),
      ],
    );
  }
}
