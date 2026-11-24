import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/i18n/strings.g.dart';

import 'progress_card_decoration.dart';

/// Ringkasan program aktif beserta persentase penyelesaiannya.
class ProgramCard extends StatelessWidget {
  const ProgramCard({
    super.key,
    required this.title,
    required this.week,
    required this.totalWeeks,
    required this.percent,
  });

  final String title;
  final int week;
  final int totalWeeks;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final labels = context.t.core.progress.programCard;
    final safePercent = percent.clamp(0, 100);
    final safeTotalWeeks = totalWeeks > 0 ? totalWeeks : 1;
    final safeWeek = week.clamp(1, safeTotalWeeks);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: progressCardDecoration(context)
          .copyWith(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.primaryContainer
                      : AppColors.limeSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  size: 19,
                  color: isDark ? colorScheme.primary : AppColors.greenDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels.weekOf(week: safeWeek, total: safeTotalWeeks),
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.primaryContainer
                      : AppColors.limeSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  labels.active,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: isDark ? colorScheme.primary : AppColors.greenDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labels.completion,
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              Text(
                '$safePercent%',
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? colorScheme.primary : AppColors.greenDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: safePercent / 100),
              duration: const Duration(milliseconds: 850),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: isDark
                    ? colorScheme.surfaceContainerHigh
                    : AppColors.neutral100,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
