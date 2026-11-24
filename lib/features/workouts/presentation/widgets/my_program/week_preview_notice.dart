import 'package:material_ui/material_ui.dart';

import 'package:workout_app/i18n/strings.g.dart';

/// Banner peringatan ketika user melihat jadwal minggu depan / mode pratinjau.
class WeekPreviewNotice extends StatelessWidget {
  const WeekPreviewNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bannerBg = isDark ? const Color(0xFF2C2210) : const Color(0xFFFFFBEB);
    final bannerBorder = isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
    final iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
    final titleColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);
    final bodyColor = isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bannerBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.visibility_rounded,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.workouts.weeklySchedule.previewTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.workouts.weeklySchedule.previewNotice,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: bodyColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
