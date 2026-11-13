import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Step 5 of 7: How often can you work out? (Frequency & Duration) (Mockup 1:1)
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
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // List Frekuensi (2..6 hari / minggu)
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
                    color: isSelected ? const Color(0xFFF4F9ED) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF84CC16)
                          : AppColors.neutral200,
                      width: isSelected ? 1.8 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.limeAccent.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: isSelected
                            ? AppColors.greenDark
                            : AppColors.neutral500,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        t.daysPerWeek(n: freq),
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: isSelected
                              ? AppColors.greenDark
                              : AppColors.darkCharcoal,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFF84CC16),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 18),

          // Session Duration Selector
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.darkCharcoal,
              ),
              const SizedBox(width: 6),
              Text(
                t.sessionDuration,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.darkCharcoal,
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
                            ? AppColors.limeAccent
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF84CC16)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        t.minutes(n: dur),
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: AppColors.darkCharcoal,
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

