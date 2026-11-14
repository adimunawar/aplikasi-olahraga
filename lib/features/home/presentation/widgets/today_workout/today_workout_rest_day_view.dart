import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1FADC),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.weekend_rounded,
                      color: Color(0xFF65A30D),
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
                    color: AppColors.darkCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    t.home.restDay.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
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
