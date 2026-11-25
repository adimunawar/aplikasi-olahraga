import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Step 5 of 7: How often can you work out? (Light & Dark Mode)
class StepSchedule extends StatelessWidget {
  final int daysPerWeek;
  final int durationMin;
  final ValueChanged<int> onDaysPerWeekChanged;
  final ValueChanged<int> onDurationMinChanged;

  const StepSchedule({
    super.key,
    required this.daysPerWeek,
    required this.durationMin,
    required this.onDaysPerWeekChanged,
    required this.onDurationMinChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.schedule;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final accentColor = isDark ? colorScheme.primary : AppColors.greenBrand;

    const frequencies = [2, 3, 4, 5, 6];
    const durations = [30, 45, 60];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ...frequencies.map((freq) {
            final isSelected = daysPerWeek == freq;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onDaysPerWeekChanged(freq),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? accentColor : colorScheme.outline,
                      width: isSelected ? 1.8 : 1.2,
                    ),
                    boxShadow: isDark
                        ? null
                        : (isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.limeAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : AppColors.cardShadow),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: isSelected
                            ? (isDark ? colorScheme.primary : AppColors.greenDark)
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        t.daysPerWeek(n: freq),
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: isSelected
                              ? (isDark
                                  ? colorScheme.onPrimaryContainer
                                  : AppColors.greenDark)
                              : colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                t.sessionDuration,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: durations.map((dur) {
              final isSelected = durationMin == dur;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => onDurationMinChanged(dur),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? accentColor : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        t.minutes(n: dur),
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
