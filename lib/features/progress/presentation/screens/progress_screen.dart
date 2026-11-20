import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/progress_history_grouping.dart';
import '../controllers/progress_controller.dart';
import '../controllers/progress_state.dart';
import '../widgets/progress_dashboard_widgets.dart';
import '../widgets/progress_history_widgets.dart';

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
                  const LoadingState()
                else if (state.errorMessage != null && state.recentWorkouts.isEmpty)
                  ErrorState(message: state.errorMessage!, onRetry: () => ref.read(progressControllerProvider.notifier).loadProgress())
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
    decoration: BoxDecoration(color: const AppColors.neutral100, borderRadius: BorderRadius.circular(28)),
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
      if (metrics.workoutCount == 0)
        const ProgressEmptyState(
          icon: Icons.fitness_center_rounded,
          title: 'No workout data yet',
          message: 'Complete your first workout to see your training progress here.',
        )
      else ...[
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.78,
          children: [
            MetricCard(icon: Icons.fitness_center_rounded, value: '${metrics.workoutCount}', label: 'Workouts'),
            MetricCard(icon: Icons.check_circle_outline_rounded, value: '$completion%', label: 'Completion'),
            MetricCard(icon: Icons.access_time_rounded, value: _duration(metrics.totalMinutes), label: 'Training Time'),
            MetricCard(icon: Icons.local_fire_department_outlined, value: '${metrics.streakDays} days', label: 'Current Streak'),
          ],
        ),
        const SizedBox(height: 20),
        _heading('Program Progress'),
        const SizedBox(height: 10),
        if (state.hasActiveProgram)
          ProgramCard(title: state.activeProgramTitle, week: state.activeProgramWeek, totalWeeks: state.activeProgramTotalWeeks, percent: state.activeProgramPercent)
        else
          const ProgressEmptyState(
            icon: Icons.flag_outlined,
            title: 'No active program',
            message: 'Choose a training program to track your weekly progress.',
            compact: true,
          ),
        const SizedBox(height: 20),
        _heading('Recent Highlights', trailing: Icons.info_outline),
        const SizedBox(height: 10),
        HighlightsCard(completed: metrics.completedThisWeek, target: metrics.weeklyTarget, weightChange: state.weightChange, streak: metrics.streakDays, hasWeightData: state.weightHistory.isNotEmpty),
      ],
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
        WeightTrendCard(
          points: chartPoints,
          weeks: _bodyRangeWeeks,
          currentWeight: state.currentWeight,
          hasData: hasWeightData,
        ),
        if (hasWeightData) ...[
          const SizedBox(height: 10),
          CurrentWeightSummary(
            currentWeight: state.currentWeight,
            change: state.weightChange,
            rangeWeeks: _bodyRangeWeeks,
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () => _recordWeight(hasWeightData ? state.currentWeight : null),
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
        MetricNotTrackedCard(metric: _bodyMetric),
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
              color: selected ? AppColors.limeAccent : const AppColors.neutral100,
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
      if (state.metrics.workoutCount == 0)
        const ProgressEmptyState(
          icon: Icons.fitness_center_rounded,
          title: 'No workout performance yet',
          message: 'Your weekly activity and training volume will appear after you complete a workout.',
        )
      else ...[
      if (state.hasActiveProgram)
        ProgramCard(title: state.activeProgramTitle, week: state.activeProgramWeek, totalWeeks: state.activeProgramTotalWeeks, percent: state.activeProgramPercent)
      else
        const ProgressEmptyState(icon: Icons.flag_outlined, title: 'No active program', message: 'Choose a program to see its progress.', compact: true),
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
      if (weeklyMinutes > 0)
        _WeeklyActivityCard(days: state.weeklyActivity, maxMinutes: maxMinutes)
      else
        const ProgressEmptyState(
          icon: Icons.calendar_today_outlined,
          title: 'No activity this week',
          message: 'Completed workout time will be summarized here.',
          compact: true,
        ),
      const SizedBox(height: 20),
      _heading('Training Volume', trailing: Icons.info_outline),
      const SizedBox(height: 10),
      if (totalSets > 0)
        _TrainingVolumeCard(totalSets: totalSets, totalReps: totalReps, activePatterns: state.movementVolume.length)
      else
        const ProgressEmptyState(
          icon: Icons.bar_chart_rounded,
          title: 'No training volume yet',
          message: 'Set and rep totals will appear after you log completed sets.',
          compact: true,
        ),
      const SizedBox(height: 20),
      _heading('Recent Workouts'),
      const SizedBox(height: 10),
      RecentWorkoutsCard(workouts: state.recentWorkouts),
      const SizedBox(height: 4),
      Text('$weeklyMinutes training minutes this week', style: AppTypography.labelSmall.copyWith(color: AppColors.neutral500)),
      ],
    ]);
  }

  Widget _historyTab(ProgressState state) {
    final workoutItems = state.recentWorkouts.map((item) => HistoryEntry.workout(item)).toList();
    final measurementItems = state.weightHistory.map((item) => HistoryEntry.measurement(item)).toList();
    final entries = <HistoryEntry>[
      if (_historyFilter != 'Measurement') ...workoutItems,
      if (_historyFilter != 'Workout') ...measurementItems,
    ]..sort((a, b) {
      final comparison = a.date.compareTo(b.date);
      return _historyNewestFirst ? -comparison : comparison;
    });

    final grouped = <String, List<HistoryEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(_historyGroup(entry.date), () => []).add(entry);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        HistoryFilterChip(label: 'All', selected: _historyFilter == 'All', onTap: () => setState(() => _historyFilter = 'All')),
        const SizedBox(width: 6),
        HistoryFilterChip(label: 'Workout', icon: Icons.fitness_center_rounded, selected: _historyFilter == 'Workout', onTap: () => setState(() => _historyFilter = 'Workout')),
        const SizedBox(width: 6),
        HistoryFilterChip(label: 'Measurement', icon: Icons.monitor_weight_outlined, selected: _historyFilter == 'Measurement', onTap: () => setState(() => _historyFilter = 'Measurement')),
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
        HistoryEmptyState(filter: _historyFilter)
      else
        ...grouped.entries.map((group) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(group.key, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            HistoryGroupCard(entries: group.value),
          ]),
        )),
    ]);
  }

  String _historyGroup(DateTime date) => const ProgressHistoryGrouping().groupFor(date, now: DateTime.now());

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

  Future<void> _recordWeight(double? initialWeight) async {
    final controller = TextEditingController(text: initialWeight?.toStringAsFixed(1) ?? '');
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
