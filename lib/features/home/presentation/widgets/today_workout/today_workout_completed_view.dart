import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/app_typography.dart';
import '../recovery_tips_section.dart';

/// Shown after a workout is completed. Completion is not presented as a rest day.
class TodayWorkoutCompletedView extends StatelessWidget {
  final VoidCallback onHydrationTap;
  final VoidCallback onSleepTap;
  final VoidCallback onStretchingTap;

  const TodayWorkoutCompletedView({
    super.key,
    required this.onHydrationTap,
    required this.onSleepTap,
    required this.onStretchingTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIndonesian = Localizations.localeOf(context).languageCode == 'id';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isIndonesian ? 'Latihan hari ini selesai!' : 'Workout completed!',
                  textAlign: TextAlign.center,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    isIndonesian
                        ? 'Kerja bagus. Beri tubuhmu waktu untuk pulih sebelum sesi berikutnya.'
                        : 'Great work. Give your body time to recover before your next session.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          RecoveryTipsSection(
            onHydrationTap: onHydrationTap,
            onSleepTap: onSleepTap,
            onStretchingTap: onStretchingTap,
          ),
        ],
      ),
    );
  }
}
