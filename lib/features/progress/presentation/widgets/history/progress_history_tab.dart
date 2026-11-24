import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/features/progress/application/progress_history_grouping.dart';
import 'package:workout_app/i18n/strings.g.dart';

import '../../controllers/progress_state.dart';
import '../shared/progress_shared_widgets.dart';
import 'progress_history_widgets.dart';

/// Tab Riwayat (History) pada Halaman Progress
class ProgressHistoryTab extends StatefulWidget {
  final ProgressState state;

  const ProgressHistoryTab({super.key, required this.state});

  @override
  State<ProgressHistoryTab> createState() => _ProgressHistoryTabState();
}

class _ProgressHistoryTabState extends State<ProgressHistoryTab> {
  String _historyFilter = 'All';
  bool _historyNewestFirst = true;

  String _historyGroup(DateTime date) =>
      const ProgressHistoryGrouping().groupFor(date, now: DateTime.now());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final workoutItems = widget.state.recentWorkouts
        .map((item) => HistoryEntry.workout(item))
        .toList();
    final measurementItems = widget.state.weightHistory
        .map((item) => HistoryEntry.measurement(item))
        .toList();
    final entries =
        <HistoryEntry>[
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HistoryFilterChip(
              label: context.t.core.progress.history.all,
              selected: _historyFilter == 'All',
              onTap: () => setState(() => _historyFilter = 'All'),
            ),
            const SizedBox(width: 6),
            HistoryFilterChip(
              label: context.t.core.progress.history.workout,
              icon: Icons.fitness_center_rounded,
              selected: _historyFilter == 'Workout',
              onTap: () => setState(() => _historyFilter = 'Workout'),
            ),
            const SizedBox(width: 6),
            HistoryFilterChip(
              label: context.t.core.progress.history.measurement,
              icon: Icons.monitor_weight_outlined,
              selected: _historyFilter == 'Measurement',
              onTap: () => setState(() => _historyFilter = 'Measurement'),
            ),
            const Spacer(),
            IconButton(
              tooltip: _historyNewestFirst
                  ? context.t.core.progress.history.oldestFirst
                  : context.t.core.progress.history.newestFirst,
              onPressed: () =>
                  setState(() => _historyNewestFirst = !_historyNewestFirst),
              icon: const Icon(Icons.swap_vert_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? colorScheme.surfaceContainerHighest
                    : AppColors.neutral100,
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(
                  color: isDark ? colorScheme.outline : AppColors.neutral200,
                  width: 0.8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          HistoryEmptyState(filter: _historyFilter)
        else
          ...grouped.entries.map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: ProgressReveal(
                delay: Duration(
                  milliseconds: grouped.keys.toList().indexOf(group.key) * 65,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.key,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    HistoryGroupCard(entries: group.value),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
