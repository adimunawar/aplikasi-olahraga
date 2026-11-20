import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/workout_history_item.dart';
import '../../domain/models/weight_record.dart';
import '../../application/weight_chart_series.dart';
import '../controllers/progress_controller.dart';
import '../controllers/progress_state.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedTab = 0;
  int _bodyRangeWeeks = 8;
  String _bodyMetric = 'Weight';
  String _historyFilter = 'All';
  bool _historyNewestFirst = true;
  static const _tabs = ['Overview', 'Body', 'Workout', 'History'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.greenBrand,
          onRefresh: () => ref.read(progressControllerProvider.notifier).loadProgress(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 22),
                _tabsBar(),
                const SizedBox(height: 20),
                if (state.isLoading && state.recentWorkouts.isEmpty)
                  const _LoadingState()
                else if (state.errorMessage != null && state.recentWorkouts.isEmpty)
                  _ErrorState(message: state.errorMessage!, onRetry: () => ref.read(progressControllerProvider.notifier).loadProgress())
                else
                  _tabContent(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(
    children: [
      Expanded(child: Text('Progress', style: AppTypography.headlineLarge.copyWith(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.7, color: AppColors.darkCharcoal))),
      PopupMenuButton<int>(
        initialValue: _bodyRangeWeeks,
        onSelected: (value) => setState(() => _bodyRangeWeeks = value),
        itemBuilder: (context) => const [
          PopupMenuItem(value: 4, child: Text('Last 4 Weeks')),
          PopupMenuItem(value: 8, child: Text('Last 8 Weeks')),
          PopupMenuItem(value: 12, child: Text('Last 12 Weeks')),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.neutral200)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.neutral600),
            const SizedBox(width: 7),
            Text('Last $_bodyRangeWeeks Weeks', style: AppTypography.labelSmall.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.w600)),
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.neutral600),
          ]),
        ),
      ),
    ],
  );

  Widget _tabsBar() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: const Color(0xFFEFF1F3), borderRadius: BorderRadius.circular(28)),
    child: Row(children: List.generate(_tabs.length, (index) {
      final selected = _selectedTab == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedTab = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: selected ? AppColors.limeAccent : Colors.transparent, borderRadius: BorderRadius.circular(24)),
            alignment: Alignment.center,
            child: Text(_tabs[index], style: AppTypography.labelSmall.copyWith(color: AppColors.darkCharcoal, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ),
        ),
      );
    })),
  );

  Widget _tabContent(ProgressState state) {
    switch (_selectedTab) {
      case 1: return _bodyTab(state);
      case 2: return _workoutTab(state);
      case 3: return _historyTab(state);
      default: return _overviewTab(state);
    }
  }

  Widget _overviewTab(ProgressState state) {
    final metrics = state.metrics;
    final completion = metrics.weeklyTarget > 0
        ? (metrics.completedThisWeek / metrics.weeklyTarget * 100).clamp(0, 100).round()
        : 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Your Progress', subtitle: 'A quick summary of your training and body progress.'),
      const SizedBox(height: 10),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.78,
        children: [
          _MetricCard(icon: Icons.fitness_center_rounded, value: '${metrics.workoutCount}', label: 'Workouts'),
          _MetricCard(icon: Icons.check_circle_outline_rounded, value: '$completion%', label: 'Completion'),
          _MetricCard(icon: Icons.access_time_rounded, value: _duration(metrics.totalMinutes), label: 'Training Time'),
          _MetricCard(icon: Icons.local_fire_department_outlined, value: '${metrics.streakDays} days', label: 'Current Streak'),
        ],
      ),
      const SizedBox(height: 20),
      _heading('Program Progress'),
      const SizedBox(height: 10),
      _ProgramCard(title: state.activeProgramTitle, week: state.activeProgramWeek, totalWeeks: state.activeProgramTotalWeeks, percent: state.activeProgramPercent),
      const SizedBox(height: 20),
      _heading('Recent Highlights', trailing: Icons.info_outline),
      const SizedBox(height: 10),
      _HighlightsCard(completed: metrics.completedThisWeek, target: metrics.weeklyTarget, weightChange: state.weightChange, streak: metrics.streakDays),
    ]);
  }

  Widget _bodyTab(ProgressState state) {
    final chartPoints = const WeightChartSeries().build(
      state.weightHistory,
      weeks: _bodyRangeWeeks,
      now: DateTime.now(),
    );
    final hasWeightData = chartPoints.isNotEmpty;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Body Progress', subtitle: 'Track changes in your body over time.'),
      const SizedBox(height: 10),
      _bodyMetricSelector(),
      const SizedBox(height: 10),
      if (_bodyMetric == 'Weight') ...[
        _WeightTrendCard(
          points: chartPoints,
          weeks: _bodyRangeWeeks,
          currentWeight: state.currentWeight,
          hasData: hasWeightData,
        ),
        const SizedBox(height: 10),
        _CurrentWeightSummary(
          currentWeight: state.currentWeight,
          change: state.weightChange,
          rangeWeeks: _bodyRangeWeeks,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () => _recordWeight(state.currentWeight),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Log Measurement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.limeAccent,
              foregroundColor: AppColors.darkCharcoal,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              textStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ] else
        _MetricNotTrackedCard(metric: _bodyMetric),
    ]);
  }

  Widget _bodyMetricSelector() {
    const metrics = ['Weight', 'Muscle Mass', 'Body Fat'];
    return Row(children: metrics.map((metric) {
      final selected = _bodyMetric == metric;
      return Padding(
        padding: const EdgeInsets.only(right: 7),
        child: GestureDetector(
          onTap: () => setState(() => _bodyMetric = metric),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? AppColors.limeAccent : const Color(0xFFEFF1F3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(metric, style: AppTypography.labelSmall.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            )),
          ),
        ),
      );
    }).toList());
  }

  Widget _workoutTab(ProgressState state) {
    final weeklyMinutes = state.weeklyActivity.fold<int>(0, (sum, day) => sum + day.minutes);
    final maxMinutes = state.weeklyActivity.fold<int>(0, (max, day) => day.minutes > max ? day.minutes : max);
    final totalSets = state.movementVolume.fold<int>(0, (sum, item) => sum + item.totalSets);
    final totalReps = state.movementVolume.fold<int>(0, (sum, item) => sum + item.totalReps);
    final completion = state.metrics.weeklyTarget > 0
        ? (state.metrics.completedThisWeek / state.metrics.weeklyTarget * 100).clamp(0, 100).round()
        : 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Workout Performance', subtitle: 'Your training progress and consistency.'),
      const SizedBox(height: 10),
      _ProgramCard(title: state.activeProgramTitle, week: state.activeProgramWeek, totalWeeks: state.activeProgramTotalWeeks, percent: state.activeProgramPercent),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _WorkoutStatCard(icon: Icons.fitness_center_rounded, value: '${state.metrics.workoutCount}', label: 'Workouts')),
        const SizedBox(width: 8),
        Expanded(child: _WorkoutStatCard(icon: Icons.check_circle_outline_rounded, value: '$completion%', label: 'Completion')),
        const SizedBox(width: 8),
        Expanded(child: _WorkoutStatCard(icon: Icons.access_time_rounded, value: _duration(state.metrics.totalMinutes), label: 'Total Time')),
      ]),
      const SizedBox(height: 20),
      _heading('Weekly Activity', trailing: Icons.info_outline),
      const SizedBox(height: 10),
      _WeeklyActivityCard(days: state.weeklyActivity, maxMinutes: maxMinutes),
      const SizedBox(height: 20),
      _heading('Training Volume', trailing: Icons.info_outline),
      const SizedBox(height: 10),
      _TrainingVolumeCard(totalSets: totalSets, totalReps: totalReps, activePatterns: state.movementVolume.length),
      const SizedBox(height: 20),
      _heading('Recent Workouts'),
      const SizedBox(height: 10),
      _RecentWorkoutsCard(workouts: state.recentWorkouts),
      const SizedBox(height: 4),
      Text('$weeklyMinutes training minutes this week', style: AppTypography.labelSmall.copyWith(color: AppColors.neutral500)),
    ]);
  }

  Widget _historyTab(ProgressState state) {
    final workoutItems = state.recentWorkouts.map((item) => _HistoryEntry.workout(item)).toList();
    final measurementItems = state.weightHistory.map((item) => _HistoryEntry.measurement(item)).toList();
    final entries = <_HistoryEntry>[
      if (_historyFilter != 'Measurement') ...workoutItems,
      if (_historyFilter != 'Workout') ...measurementItems,
    ]..sort((a, b) {
      final comparison = a.date.compareTo(b.date);
      return _historyNewestFirst ? -comparison : comparison;
    });

    final grouped = <String, List<_HistoryEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(_historyGroup(entry.date), () => []).add(entry);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _HistoryFilterChip(label: 'All', selected: _historyFilter == 'All', onTap: () => setState(() => _historyFilter = 'All')),
        const SizedBox(width: 6),
        _HistoryFilterChip(label: 'Workout', icon: Icons.fitness_center_rounded, selected: _historyFilter == 'Workout', onTap: () => setState(() => _historyFilter = 'Workout')),
        const SizedBox(width: 6),
        _HistoryFilterChip(label: 'Measurement', icon: Icons.monitor_weight_outlined, selected: _historyFilter == 'Measurement', onTap: () => setState(() => _historyFilter = 'Measurement')),
        const Spacer(),
        IconButton(
          tooltip: _historyNewestFirst ? 'Oldest first' : 'Newest first',
          onPressed: () => setState(() => _historyNewestFirst = !_historyNewestFirst),
          icon: const Icon(Icons.swap_vert_rounded, size: 20),
          style: IconButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: AppColors.neutral200)),
        ),
      ]),
      const SizedBox(height: 12),
      if (entries.isEmpty)
        _HistoryEmptyState(filter: _historyFilter)
      else
        ...grouped.entries.map((group) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(group.key, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _HistoryGroupCard(entries: group.value),
          ]),
        )),
    ]);
  }

  String _historyGroup(DateTime date) {
    final today = DateTime.now();
    final startToday = DateTime(today.year, today.month, today.day);
    final entryDay = DateTime(date.year, date.month, date.day);
    final daysAgo = startToday.difference(entryDay).inDays;
    if (daysAgo < 7 && daysAgo >= 0) return 'This Week';
    if (daysAgo < 14 && daysAgo >= 7) return 'Last Week';
    return 'Earlier';
  }

  Widget _heading(String title, {String? subtitle, IconData? trailing}) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkCharcoal)),
      if (subtitle != null) ...[
        const SizedBox(height: 3),
        Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500, fontSize: 11)),
      ],
    ])),
    if (trailing != null) Icon(trailing, size: 15, color: AppColors.neutral400),
  ]);

  String _duration(int minutes) {
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (hours == 0) return '${remaining}m';
    if (remaining == 0) return '${hours}h';
    return '${hours}h ${remaining}m';
  }

  Future<void> _recordWeight(double initialWeight) async {
    final controller = TextEditingController(text: initialWeight.toStringAsFixed(1));
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Record weight'),
        content: TextField(
          controller: controller, autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Current weight', suffixText: 'kg'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final parsed = double.tryParse(controller.text.trim());
            if (parsed != null && parsed > 0 && parsed < 500) Navigator.pop(dialogContext, parsed);
          }, child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (value != null) await ref.read(progressControllerProvider.notifier).recordWeight(value);
  }
}

class _WeightTrendCard extends StatelessWidget {
  const _WeightTrendCard({
    required this.points,
    required this.weeks,
    required this.currentWeight,
    required this.hasData,
  });

  final List<WeightChartPoint> points;
  final int weeks;
  final double currentWeight;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    final latest = points.isEmpty ? null : points.last;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Weight (kg)', style: AppTypography.labelMedium.copyWith(
            color: AppColors.darkCharcoal, fontWeight: FontWeight.w700,
          )),
          const Spacer(),
          if (latest != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.limeSurface, borderRadius: BorderRadius.circular(12)),
              child: Text('W${latest.weekNumber} · ${latest.weightKg.toStringAsFixed(1)} kg',
                style: AppTypography.labelSmall.copyWith(color: AppColors.greenDark, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
        ]),
        const SizedBox(height: 8),
        if (hasData)
          SizedBox(
            height: 188,
            width: double.infinity,
            child: CustomPaint(painter: _WeightTrendPainter(points: points, weeks: weeks)),
          )
        else
          SizedBox(
            height: 188,
            child: Center(child: Text('No weight measurements in this period yet.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500))),
          ),
      ]),
    );
  }
}

class _WeightTrendPainter extends CustomPainter {
  const _WeightTrendPainter({required this.points, required this.weeks});
  final List<WeightChartPoint> points;
  final int weeks;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || weeks <= 0) return;
    const left = 30.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 27.0;
    final plotWidth = size.width - left - right;
    final plotHeight = size.height - top - bottom;
    final values = points.map((point) => point.weightKg);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final spread = (maxValue - minValue).abs();
    final padding = spread < 0.1 ? 1.0 : spread * 0.25;
    final minY = (minValue - padding).floorToDouble();
    final maxY = (maxValue + padding).ceilToDouble();
    final yRange = math.max(maxY - minY, 1.0).toDouble();

    Offset position(WeightChartPoint point) {
      final x = left + ((point.weekNumber - 1) / math.max(weeks - 1, 1)) * plotWidth;
      final y = top + ((maxY - point.weightKg) / yRange) * plotHeight;
      return Offset(x, y);
    }

    final gridPaint = Paint()..color = AppColors.neutral200..strokeWidth = 0.8;
    final labelStyle = AppTypography.labelSmall.copyWith(color: AppColors.neutral600, fontSize: 9);
    for (var i = 0; i <= 4; i++) {
      final y = top + (plotHeight * i / 4);
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
      final value = maxY - (yRange * i / 4);
      final text = TextPainter(
        text: TextSpan(text: value.toStringAsFixed(0), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(0, y - text.height / 2));
    }

    final path = Path();
    final first = position(points.first);
    path.moveTo(first.dx, first.dy);
    for (final point in points.skip(1)) {
      final p = position(point);
      path.lineTo(p.dx, p.dy);
    }

    final fill = Path.from(path)
      ..lineTo(position(points.last).dx, top + plotHeight)
      ..lineTo(first.dx, top + plotHeight)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.limeAccent.withValues(alpha: 0.24), AppColors.limeAccent.withValues(alpha: 0.01)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(left, top, plotWidth, plotHeight));
    canvas.drawPath(fill, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.greenBrand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    for (final point in points) {
      final p = position(point);
      canvas.drawCircle(p, 3.2, Paint()..color = AppColors.limeAccent);
      canvas.drawCircle(p, 3.2, Paint()..color = AppColors.greenBrand..style = PaintingStyle.stroke..strokeWidth = 1);
    }

    for (var week = 1; week <= weeks; week++) {
      final x = left + ((week - 1) / math.max(weeks - 1, 1)) * plotWidth;
      final text = TextPainter(
        text: TextSpan(text: 'W$week', style: labelStyle.copyWith(fontSize: 8)),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(x - text.width / 2, top + plotHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _WeightTrendPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.weeks != weeks;
}

class _CurrentWeightSummary extends StatelessWidget {
  const _CurrentWeightSummary({required this.currentWeight, required this.change, required this.rangeWeeks});
  final double currentWeight;
  final double change;
  final int rangeWeeks;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: _cardDecoration(),
    child: Row(children: [
      Container(width: 37, height: 37, decoration: BoxDecoration(color: AppColors.limeSurface, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.monitor_weight_outlined, size: 19, color: AppColors.greenDark)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${currentWeight.toStringAsFixed(1)} kg', style: AppTypography.titleLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
        Text('vs. $rangeWeeks weeks ago', style: AppTypography.labelSmall.copyWith(color: AppColors.neutral500, fontSize: 9)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: AppColors.limeSurface, borderRadius: BorderRadius.circular(15)),
        child: Text('${change >= 0 ? '↑ +' : '↓ '}${change.abs().toStringAsFixed(1)} kg',
          style: AppTypography.labelSmall.copyWith(color: AppColors.greenDark, fontSize: 10, fontWeight: FontWeight.w700)),
      ),
    ]),
  );
}

class _MetricNotTrackedCard extends StatelessWidget {
  const _MetricNotTrackedCard({required this.metric});
  final String metric;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
    decoration: _cardDecoration(),
    child: Column(children: [
      const Icon(Icons.insights_outlined, size: 30, color: AppColors.neutral400),
      const SizedBox(height: 10),
      Text('$metric tracking is not available yet', style: AppTypography.titleSmall, textAlign: TextAlign.center),
      const SizedBox(height: 5),
      Text('This metric is not stored in your measurements yet.',
        style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
        textAlign: TextAlign.center),
    ]),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.value, required this.label, this.fullWidth = false, this.onTap});
  final IconData icon;
  final String value;
  final String label;
  final bool fullWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(15),
      child: Container(
        width: fullWidth ? double.infinity : null,
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: _cardDecoration(),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.limeSurface, shape: BoxShape.circle), child: Icon(icon, size: 17, color: AppColors.greenDark)),
          const SizedBox(width: 10),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.titleLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
            const SizedBox(height: 2),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.neutral500)),
          ])),
        ]),
      ),
    ),
  );
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.title, required this.week, required this.totalWeeks, required this.percent});
  final String title;
  final int week;
  final int totalWeeks;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 100);
    return Container(
      padding: const EdgeInsets.all(13), decoration: _cardDecoration(),
      child: Row(children: [
        Container(width: 37, height: 37, decoration: const BoxDecoration(color: AppColors.limeSurface, shape: BoxShape.circle), child: const Icon(Icons.fitness_center_rounded, size: 18, color: AppColors.greenDark)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.darkCharcoal))),
            const SizedBox(width: 7),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppColors.limeSurface, borderRadius: BorderRadius.circular(10)), child: Text('Active', style: AppTypography.labelSmall.copyWith(fontSize: 9, color: AppColors.greenDark, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 4),
          Text('Week $week of $totalWeeks · $safePercent%', style: AppTypography.labelSmall.copyWith(color: AppColors.neutral500, fontSize: 10)),
          const SizedBox(height: 7),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: safePercent / 100, minHeight: 5, backgroundColor: AppColors.neutral100, valueColor: const AlwaysStoppedAnimation(AppColors.limeAccent))),
        ])),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.neutral400),
      ]),
    );
  }
}

class _HighlightsCard extends StatelessWidget {
  const _HighlightsCard({required this.completed, required this.target, required this.weightChange, required this.streak});
  final int completed;
  final int target;
  final double weightChange;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String)>[
      (Icons.check_circle_outline_rounded, 'Completed $completed of $target workouts this week'),
      (Icons.trending_up_rounded, 'Weight ${weightChange >= 0 ? 'increased' : 'changed'} by ${weightChange.abs().toStringAsFixed(1)} kg'),
      (Icons.emoji_events_outlined, '$streak consecutive active days'),
    ];
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: List.generate(rows.length, (index) {
        final row = rows[index];
        return Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            child: Row(children: [
              Container(width: 29, height: 29, decoration: const BoxDecoration(color: AppColors.limeSurface, shape: BoxShape.circle), child: Icon(row.$1, size: 15, color: AppColors.greenDark)),
              const SizedBox(width: 10),
              Expanded(child: Text(row.$2, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.darkCharcoal, fontWeight: FontWeight.w500))),
              const Icon(Icons.chevron_right_rounded, size: 19, color: AppColors.neutral400),
            ]),
          ),
          if (index != rows.length - 1) const Divider(height: 1, color: AppColors.neutral200),
        ]);
      })),
    );
  }
}

class _WeightChangeCard extends StatelessWidget {
  const _WeightChangeCard({required this.change, required this.onTap});
  final double change;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white, borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15), decoration: _cardDecoration(),
        child: Row(children: [
          const Icon(Icons.monitor_weight_outlined, color: AppColors.greenDark),
          const SizedBox(width: 10),
          Expanded(child: Text('Change weight record', style: AppTypography.bodyMedium)),
          Text('${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg', style: AppTypography.titleSmall),
          const SizedBox(width: 5),
          const Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
        ]),
      ),
    ),
  );
}

class _RecentWorkoutsCard extends StatelessWidget {
  const _RecentWorkoutsCard({required this.workouts, this.expanded = false});
  final List<WorkoutHistoryItem> workouts;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: _cardDecoration(), child: Text('No completed workouts yet.', textAlign: TextAlign.center, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)));
    }
    final items = expanded ? workouts : workouts.take(3).toList();
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: List.generate(items.length, (index) {
        final workout = items[index];
        return Column(children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
            leading: Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.limeSurface, shape: BoxShape.circle), child: const Icon(Icons.fitness_center_rounded, size: 17, color: AppColors.greenDark)),
            title: Text(workout.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.titleSmall.copyWith(fontSize: 12)),
            subtitle: Text('${workout.dateText} · ${workout.durationText} · ${workout.caloriesText}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall.copyWith(fontSize: 9)),
            trailing: const Icon(Icons.chevron_right_rounded, size: 19, color: AppColors.neutral400),
          ),
          if (index != items.length - 1) const Divider(height: 1, color: AppColors.neutral200),
        ]);
      })),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()));
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20), decoration: _cardDecoration(),
    child: Column(children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 28),
      const SizedBox(height: 8),
      Text('Unable to load progress', style: AppTypography.titleSmall),
      const SizedBox(height: 4),
      Text(message, textAlign: TextAlign.center, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
      const SizedBox(height: 12),
      TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded, size: 16), label: const Text('Try again')),
    ]),
  );
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(15),
  border: Border.all(color: AppColors.neutral200, width: 0.8),
  boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
);
