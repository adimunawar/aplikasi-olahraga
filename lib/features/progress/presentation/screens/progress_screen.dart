import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/workout_history_item.dart';
import '../controllers/progress_controller.dart';
import '../controllers/progress_state.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedTab = 0;
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
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.neutral200)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.neutral600),
          const SizedBox(width: 7),
          Text('Last 4 Weeks', style: AppTypography.labelSmall.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.w600)),
          const SizedBox(width: 5),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.neutral600),
        ]),
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
      _heading('Your Progress', 'A quick summary of your training and body progress.'),
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

  Widget _bodyTab(ProgressState state) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Body Progress', 'Track your weight and body metrics.'),
    const SizedBox(height: 10),
    _MetricCard(icon: Icons.monitor_weight_outlined, value: '${state.currentWeight.toStringAsFixed(1)} kg', label: 'Current Weight', fullWidth: true, onTap: () => _recordWeight(state.currentWeight)),
    const SizedBox(height: 10),
    _MetricCard(icon: Icons.favorite_border_rounded, value: state.bmiValue.toStringAsFixed(1), label: 'BMI · ${state.bmiStatus}', fullWidth: true),
    const SizedBox(height: 10),
    _WeightChangeCard(change: state.weightChange, onTap: () => _recordWeight(state.currentWeight)),
  ]);

  Widget _workoutTab(ProgressState state) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Workout Activity', 'Your recent training consistency.'),
    const SizedBox(height: 10),
    _MetricCard(icon: Icons.fitness_center_rounded, value: '${state.metrics.workoutCount}', label: 'Completed Workouts', fullWidth: true),
    const SizedBox(height: 10),
    _HighlightsCard(completed: state.metrics.completedThisWeek, target: state.metrics.weeklyTarget, weightChange: state.weightChange, streak: state.metrics.streakDays),
    const SizedBox(height: 10),
    _RecentWorkoutsCard(workouts: state.recentWorkouts),
  ]);

  Widget _historyTab(ProgressState state) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Workout History', 'Your latest completed sessions.'),
    const SizedBox(height: 10),
    _RecentWorkoutsCard(workouts: state.recentWorkouts, expanded: true),
  ]);

  Widget _heading(String title, [String? subtitle], {IconData? trailing}) => Row(children: [
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
