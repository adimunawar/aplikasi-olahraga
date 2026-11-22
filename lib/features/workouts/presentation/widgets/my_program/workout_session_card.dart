import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/i18n/strings.g.dart';

/// Kartu untuk satu sesi latihan terjadwal pada jadwal mingguan
/// dengan dukungan status: Completed (centang), Ready/Active (play button),
/// In-Progress, Missed, dan Locked/Scheduled (gembok).
class WorkoutSessionCard extends StatelessWidget {
  final int dayNumber;
  final String dateText;
  final String title;
  final String? focusLabel;
  final int durationMinutes;
  final bool isCompleted;
  final bool isInProgress;
  final bool isActiveToday;
  final bool isMissed;
  final VoidCallback? onTap;

  const WorkoutSessionCard({
    super.key,
    required this.dayNumber,
    required this.dateText,
    required this.title,
    this.focusLabel,
    required this.durationMinutes,
    required this.isCompleted,
    required this.isInProgress,
    required this.isActiveToday,
    required this.isMissed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isActionable = isActiveToday || isInProgress || isCompleted;
    final isLocked = !isActionable && !isMissed;

    // Status label text
    final statusText = isCompleted
        ? t.workouts.session.status.completed
        : isInProgress
        ? t.workouts.session.status.inProgress
        : isActiveToday
        ? t.workouts.session.status.readyToStart
        : isMissed
        ? t.workouts.session.status.missed
        : t.workouts.session.status.scheduled;

    // Left badge colors & icons
    final Color badgeBg;
    final Color badgeIconColor;
    final IconData badgeIcon;

    if (isCompleted) {
      badgeBg = isDark ? const Color(0xFF233B19) : const Color(0xFFDCFCE7);
      badgeIconColor = isDark
          ? const Color(0xFFA3E635)
          : const Color(0xFF16A34A);
      badgeIcon = Icons.check_rounded;
    } else if (isInProgress) {
      badgeBg = isDark ? const Color(0xFF3D2E14) : const Color(0xFFFEF3C7);
      badgeIconColor = isDark
          ? const Color(0xFFFBBF24)
          : const Color(0xFFD97706);
      badgeIcon = Icons.play_arrow_rounded;
    } else if (isActiveToday) {
      badgeBg = isDark ? const Color(0xFF1E3516) : const Color(0xFFECFCCB);
      badgeIconColor = isDark ? AppColors.limeAccent : const Color(0xFF65A30D);
      badgeIcon = Icons.play_arrow_rounded;
    } else if (isMissed) {
      badgeBg = isDark ? const Color(0xFF381E1E) : const Color(0xFFFEE2E2);
      badgeIconColor = isDark
          ? const Color(0xFFF87171)
          : const Color(0xFFDC2626);
      badgeIcon = Icons.event_busy_rounded;
    } else {
      // Locked / Scheduled
      badgeBg = isDark ? const Color(0xFF1E242C) : const Color(0xFFF1F5F9);
      badgeIconColor = isDark
          ? const Color(0xFF8B9CB2)
          : const Color(0xFF64748B);
      badgeIcon = Icons.lock_rounded;
    }

    // Card background & borders
    final cardBgColor = isDark ? const Color(0xFF16191D) : Colors.white;
    final borderColor = isActionable
        ? (isDark ? const Color(0xFF2C3524) : const Color(0xFFE2E8F0))
        : (isDark ? const Color(0xFF222830) : const Color(0xFFE5E7EB));

    final titleColor = isDark
        ? (isLocked ? const Color(0xFFD1D5DB) : Colors.white)
        : const Color(0xFF141718);
    final subtextColor = isDark
        ? const Color(0xFF8E9BAE)
        : const Color(0xFF6B7280);

    // Subtitle composition
    final durationStr = t.workouts.session.min(min: durationMinutes);
    final subParts = <String>[];
    if (focusLabel != null && focusLabel!.trim().isNotEmpty) {
      subParts.add(focusLabel!.trim());
    }
    subParts.add(durationStr);
    subParts.add(statusText);
    final subtitleText = subParts.join(' • ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x33000000) : const Color(0x06000000),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Status Badge (38x38)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
              child: Center(
                child: Icon(badgeIcon, size: 18, color: badgeIconColor),
              ),
            ),
            const SizedBox(width: 14),

            // Middle: Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.workouts.session.date(n: dayNumber, date: title),
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitleText,
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Right Action Button (Lime Play button for actionable sessions)
            if (isActionable) ...[
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF141718),
                    size: 26,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
