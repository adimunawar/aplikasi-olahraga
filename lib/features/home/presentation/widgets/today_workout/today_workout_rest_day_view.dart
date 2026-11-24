import 'package:material_ui/material_ui.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../i18n/strings.g.dart';
import '../recovery_tips_section.dart';

/// Rest-day hero and actionable recovery guidance.
class TodayWorkoutRestDayView extends StatelessWidget {
  final VoidCallback onHydrationTap;
  final VoidCallback onSleepTap;
  final VoidCallback onStretchingTap;

  const TodayWorkoutRestDayView({
    super.key,
    required this.onHydrationTap,
    required this.onSleepTap,
    required this.onStretchingTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

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
                  child: Center(
                    child: Icon(
                      Icons.weekend_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  t.home.restDay.title,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    t.home.restDay.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
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
