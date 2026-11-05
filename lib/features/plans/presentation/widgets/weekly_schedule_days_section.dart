import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../program/domain/models/program_day.dart';

/// Section "Weekly Schedule" pada Halaman Plans:
/// - Header: Icon kalender + "Weekly Schedule" + Dropdown pill "Week X ∨"
/// - 7 Hari (Mon - Sun):
///   - Selesai: Checklist hijau bulat
///   - Hari Ini: Icon dumbbell aktif dengan outline lime
///   - Hari Istirahat: Icon cangkir kopi / kasur istirahat
class WeeklyScheduleDaysSection extends StatefulWidget {
  final int selectedWeek;
  final int currentWeek;
  final int totalWeeks;
  final List<ProgramDay> days;
  final Set<int> completedDayNumbers;
  final ValueChanged<int>? onSelectWeek;
  final ValueChanged<int>? onSelectDay;

  const WeeklyScheduleDaysSection({
    super.key,
    this.selectedWeek = 3,
    this.currentWeek = 3,
    this.totalWeeks = 8,
    this.days = const [],
    this.completedDayNumbers = const {1, 2, 3},
    this.onSelectWeek,
    this.onSelectDay,
  });

  @override
  State<WeeklyScheduleDaysSection> createState() =>
      _WeeklyScheduleDaysSectionState();
}

class _WeeklyScheduleDaysSectionState extends State<WeeklyScheduleDaysSection> {
  int _selectedDayIndex = 3; // 0: Mon, 1: Tue, ..., 6: Sun

  @override
  void initState() {
    super.initState();
    // Default hari ini berdasarkan kalender riil (0 = Senin, 6 = Minggu)
    final todayWeekday = DateTime.now().weekday - 1;
    _selectedDayIndex = todayWeekday.clamp(0, 6);
  }

  void _showWeekPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Text(
                  'Pilih Minggu Latihan',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
              const Divider(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.totalWeeks > 0 ? widget.totalWeeks : 8,
                  itemBuilder: (context, index) {
                    final weekNum = index + 1;
                    final isSelected = weekNum == widget.selectedWeek;

                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.limeAccent
                              : AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$weekNum',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        'Week $weekNum',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      subtitle: Text(
                        'Jadwal & fokus latihan minggu ke-$weekNum',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.greenBrand,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (widget.onSelectWeek != null) {
                            widget.onSelectWeek!(weekNum);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekDropdown(BuildContext context) {
    return InkWell(
      onTap: () => _showWeekPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Week ${widget.selectedWeek}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkCharcoal,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.darkCharcoal,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIndex = DateTime.now().weekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Bar: Judul & Dropdown "Week X ∨" (DRY via AppSectionHeader)
        AppSectionHeader(
          icon: Icons.calendar_month_rounded,
          title: 'Weekly Schedule',
          trailing: _buildWeekDropdown(context),
        ),
        const SizedBox(height: 12),

        // 7 Kartu Hari Mon - Sun
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayName = dayLabels[index];
            final ProgramDay? pDay = (index < widget.days.length)
                ? widget.days[index]
                : null;

            final isRest = pDay?.isRest ?? (index == 2 || index >= 4);
            final dayNumber = index + 1;
            final isCompleted = widget.completedDayNumbers.contains(dayNumber);
            final isToday =
                (widget.selectedWeek == widget.currentWeek) &&
                (todayIndex == index);
            final isSelected =
                (widget.selectedWeek == widget.currentWeek) &&
                (_selectedDayIndex == index);

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedDayIndex = index);
                  if (widget.onSelectDay != null) {
                    widget.onSelectDay!(dayNumber);
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(right: index < 6 ? 5 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isCompleted || isToday
                        ? AppColors.limeCardSurface
                        : AppColors.neutral50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isToday || isSelected
                          ? AppColors.primary
                          : isCompleted
                          ? AppColors.limeCardBorder
                          : AppColors.neutral200,
                      width: isToday || isSelected ? 1.6 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon Status
                      _buildDayIcon(
                        isCompleted: isCompleted,
                        isToday: isToday,
                        isRest: isRest,
                        dayName: dayName,
                      ),
                      const SizedBox(height: 6),

                      // Nama Hari (Mon, Tue, ...)
                      Text(
                        dayName,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 1),

                      // Status (Workout / Rest)
                      Text(
                        isRest ? 'Rest' : 'Workout',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isRest
                              ? AppColors.neutral400
                              : AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDayIcon({
    required bool isCompleted,
    required bool isToday,
    required bool isRest,
    required String dayName,
  }) {
    if (isCompleted) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.darkCharcoal,
          size: 15,
        ),
      );
    }

    if (isToday) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.limeSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Transform.rotate(
            angle: -0.785398,
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppColors.darkCharcoal,
              size: 13,
            ),
          ),
        ),
      );
    }

    if (isRest) {
      return SizedBox(
        width: 22,
        height: 22,
        child: Icon(
          dayName == 'Sat' ? Icons.bed_rounded : Icons.coffee_rounded,
          size: 16,
          color: AppColors.neutral400,
        ),
      );
    }

    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppColors.neutral100,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.fitness_center_rounded,
        size: 12,
        color: AppColors.neutral400,
      ),
    );
  }
}
