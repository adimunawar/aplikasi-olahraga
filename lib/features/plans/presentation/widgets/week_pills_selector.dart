import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Komponen horizontal week selector pills:
/// Menampilkan W1 s/d W8 dengan indikator checklist selesai dan tab aktif (lime green).
class WeekPillsSelector extends StatelessWidget {
  final int selectedWeek;
  final ValueChanged<int> onWeekChanged;

  const WeekPillsSelector({
    super.key,
    required this.selectedWeek,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(8, (index) {
          final weekNumber = index + 1;
          final isSelected = weekNumber == selectedWeek;
          final isPastCompleted = weekNumber < selectedWeek;

          return Padding(
            padding: EdgeInsets.only(right: index == 7 ? 0 : 8),
            child: GestureDetector(
              onTap: () => onWeekChanged(weekNumber),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFC7F135) // Vibrant lime green
                      : isPastCompleted
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFC7F135)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'W$weekNumber',
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected
                            ? const Color(0xFF141718)
                            : const Color(0xFF64748B),
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (isPastCompleted) ...[
                      const SizedBox(height: 2),
                      const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Color(0xFF65A30D),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

