import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/features/workouts/domain/models/week_progress.dart';
import 'package:workout_app/i18n/strings.g.dart';

/// Selector jadwal mingguan bergaya horizontal capsule pill chips
/// dengan dukungan penuh Dark Mode dan Light Mode.
class WeeklyScheduleSelector extends StatefulWidget {
  final int selectedWeek;
  final int currentWeek;
  final int totalWeeks;

  /// Progres tiap minggu (key: nomor minggu).
  final Map<int, WeekProgress> weekProgress;

  final ValueChanged<int> onWeekSelected;

  const WeeklyScheduleSelector({
    super.key,
    required this.selectedWeek,
    required this.currentWeek,
    required this.totalWeeks,
    required this.weekProgress,
    required this.onWeekSelected,
  });

  @override
  State<WeeklyScheduleSelector> createState() => _WeeklyScheduleSelectorState();
}

class _WeeklyScheduleSelectorState extends State<WeeklyScheduleSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToWeek(widget.selectedWeek, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant WeeklyScheduleSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWeek != widget.selectedWeek) {
      _scrollToWeek(widget.selectedWeek);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToWeek(int weekNum, {bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      const approxItemWidth = 68.0;
      final viewport = _scrollController.position.viewportDimension;
      final targetOffset =
          ((weekNum - 1) * approxItemWidth) - (viewport / 2) + 34.0;
      final clampedOffset = targetOffset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      if (animate) {
        _scrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(clampedOffset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: widget.totalWeeks,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final weekNum = index + 1;
          final isSelected = weekNum == widget.selectedWeek;
          final progress = widget.weekProgress[weekNum];

          return _buildWeekPill(
            t: t,
            weekNum: weekNum,
            isSelected: isSelected,
            progress: progress,
            onTap: () {
              widget.onWeekSelected(weekNum);
              _scrollToWeek(weekNum);
            },
          );
        },
      ),
    );
  }

  Widget _buildWeekPill({
    required Translations t,
    required int weekNum,
    required bool isSelected,
    required WeekProgress? progress,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final status =
        progress?.status ??
        (weekNum == widget.currentWeek
            ? WeekStatus.current
            : weekNum > widget.currentWeek
            ? WeekStatus.upcoming
            : WeekStatus.empty);

    final isCompleted = status == WeekStatus.completed;
    final isCurrent = status == WeekStatus.current;
    final isPartial = status == WeekStatus.partial;
    final isMissed = status == WeekStatus.missed;

    Color bgColor;
    Border? border;
    Color textColor;

    if (isSelected) {
      // 1. Selected: Bright fluorescent lime pill
      bgColor = AppColors.primary;
      border = null;
      textColor = const Color(0xFF141718);
    } else if (isCompleted) {
      // 2. Completed: Soft green pill with check
      bgColor = isDark ? const Color(0xFF1E3516) : const Color(0xFFE8FCD0);
      border = Border.all(
        color: isDark ? const Color(0xFF3B682B) : const Color(0xFFD9F99D),
        width: 1.0,
      );
      textColor = isDark ? const Color(0xFFECFCCB) : const Color(0xFF1E4608);
    } else if (isCurrent) {
      // 3. Current (unselected): Subtle green border
      bgColor = isDark ? const Color(0xFF14301B) : const Color(0xFFF0FDF4);
      border = Border.all(
        color: isDark ? AppColors.limeAccent : const Color(0xFF86EFAC),
        width: 1.5,
      );
      textColor = isDark ? AppColors.limeAccent : const Color(0xFF15803D);
    } else {
      // 4. Default / Upcoming / Missed (unselected): Clean white or dark surface pill
      bgColor = isDark
          ? (theme.colorScheme.surfaceContainerHighest)
          : Colors.white;
      border = Border.all(
        color: isDark ? theme.colorScheme.outline : const Color(0xFFE5E7EB),
        width: 1.2,
      );
      textColor = isDark
          ? theme.colorScheme.onSurfaceVariant
          : const Color(0xFF4B5563);
    }

    final weekLabel = t.workouts.weeklySchedule.weekShort(n: weekNum);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: border,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon / Ring / Badge
            if (isCompleted) ...[
              Icon(
                Icons.check_rounded,
                size: 16,
                color: isSelected ? const Color(0xFF141718) : textColor,
              ),
              const SizedBox(width: 5),
            ] else if (isPartial) ...[
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  value: progress?.completionRate ?? 0,
                  strokeWidth: 2,
                  backgroundColor: isDark
                      ? const Color(0x33FFFFFF)
                      : const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.limeAccent : const Color(0xFF65A30D),
                  ),
                ),
              ),
              const SizedBox(width: 5),
            ] else if (isMissed) ...[
              Icon(
                Icons.error_outline_rounded,
                size: 14,
                color: isDark
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFB45309),
              ),
              const SizedBox(width: 4),
            ],

            // Week Text: W1, W2, W3...
            Text(
              weekLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
