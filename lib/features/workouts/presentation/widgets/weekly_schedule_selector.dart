import 'package:material_ui/material_ui.dart';

import '../../../../i18n/strings.g.dart';
import '../../domain/models/week_progress.dart';

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
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToWeek(widget.selectedWeek, animate: false);
      _updateScrollButtons();
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
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (!pos.hasContentDimensions) return;
    final canLeft = pos.pixels > 2.0;
    final canRight =
        pos.maxScrollExtent > 2.0 && pos.pixels < (pos.maxScrollExtent - 2.0);
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      if (mounted) {
        setState(() {
          _canScrollLeft = canLeft;
          _canScrollRight = canRight;
        });
      }
    }
  }

  void _scrollToWeek(int weekNum, {bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      const itemWidth = 56.0; // 50 width + 6 spacing
      final viewport = _scrollController.position.viewportDimension;
      final targetOffset =
          (14.0 + (weekNum - 1) * itemWidth + 25.0) - (viewport / 2);
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

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Horizontal Scrollable List of Weeks
          NotificationListener<ScrollMetricsNotification>(
            onNotification: (notification) {
              _updateScrollButtons();
              return false;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _updateScrollButtons();
                return false;
              },
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                itemCount: widget.totalWeeks,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final weekNum = index + 1;
                  final isSelected = weekNum == widget.selectedWeek;
                  final progress = widget.weekProgress[weekNum];

                  return _buildWeekItem(
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
            ),
          ),

          // 2. Floating Left Arrow Button
          if (_canScrollLeft)
            Positioned(
              left: 6,
              child: _buildNavArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  if (!_scrollController.hasClients) return;
                  final target = (_scrollController.offset - 140.0).clamp(
                    0.0,
                    _scrollController.position.maxScrollExtent,
                  );
                  _scrollController.animateTo(
                    target,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),

          // 3. Floating Right Arrow Button
          if (_canScrollRight)
            Positioned(
              right: 6,
              child: _buildNavArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  if (!_scrollController.hasClients) return;
                  final target = (_scrollController.offset + 140.0).clamp(
                    0.0,
                    _scrollController.position.maxScrollExtent,
                  );
                  _scrollController.animateTo(
                    target,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF141718),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekItem({
    required Translations t,
    required int weekNum,
    required bool isSelected,
    required WeekProgress? progress,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? const Color(0xFFE4F768)
        : const Color(0xFFF3F4F6);

    final status =
        progress?.status ??
        (weekNum == widget.currentWeek
            ? WeekStatus.current
            : weekNum > widget.currentWeek
            ? WeekStatus.upcoming
            : WeekStatus.empty);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 50,
        height: 58,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t.workouts.weeklySchedule.weekShort(n: weekNum),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF141718)
                    : const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 3),
            _buildWeekStatus(
              t: t,
              status: status,
              isSelected: isSelected,
              completionRate: progress?.completionRate ?? 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekStatus({
    required Translations t,
    required WeekStatus status,
    required bool isSelected,
    required double completionRate,
  }) {
    switch (status) {
      case WeekStatus.current:
        return Text(
          t.workouts.weeklySchedule.current,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? const Color(0xFF3F6212)
                : const Color(0xFF15803D),
          ),
        );

      case WeekStatus.completed:
        return Tooltip(
          message: t.workouts.weeklySchedule.statusTooltip.completed,
          child: Icon(
            Icons.check_rounded,
            size: 14,
            color: isSelected
                ? const Color(0xFF15803D)
                : const Color(0xFF10B981),
          ),
        );

      case WeekStatus.partial:
        final color = isSelected
            ? const Color(0xFF3F6212)
            : const Color(0xFF65A30D);
        return Tooltip(
          message: t.workouts.weeklySchedule.statusTooltip.partial,
          child: SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(
              value: completionRate,
              strokeWidth: 2,
              backgroundColor: isSelected
                  ? const Color(0x334B5563)
                  : const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        );

      case WeekStatus.missed:
        return Tooltip(
          message: t.workouts.weeklySchedule.statusTooltip.missed,
          child: Icon(
            Icons.error_outline_rounded,
            size: 14,
            color: isSelected
                ? const Color(0xFFB45309)
                : const Color(0xFFF59E0B),
          ),
        );

      case WeekStatus.upcoming:
        // Future week boleh dibuka untuk pratinjau, jadi bukan "lock".
        return Tooltip(
          message: t.workouts.weeklySchedule.previewTooltip,
          child: Icon(
            Icons.visibility_outlined,
            size: 14,
            color: isSelected
                ? const Color(0xFF4B5563)
                : const Color(0xFF9CA3AF),
          ),
        );

      case WeekStatus.empty:
        return Icon(
          Icons.remove_rounded,
          size: 14,
          color: isSelected
              ? const Color(0xFF4B5563)
              : const Color(0xFF9CA3AF),
        );
    }
  }
}
