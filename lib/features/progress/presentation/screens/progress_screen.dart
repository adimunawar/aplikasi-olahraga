import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/i18n/strings.g.dart';

import '../controllers/progress_controller.dart';
import '../controllers/progress_state.dart';
import '../widgets/progress_widgets.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedTab = 0;
  int _bodyRangeWeeks = 8;

  List<String> get _tabs => [
    context.t.core.progress.tabs.overview,
    context.t.core.progress.tabs.body,
    context.t.core.progress.tabs.workout,
    context.t.core.progress.tabs.history,
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          context.t.core.progress.title,
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ProgressRangeSelector(
              selectedWeeks: _bodyRangeWeeks,
              onWeeksChanged: (value) =>
                  setState(() => _bodyRangeWeeks = value),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _tabsBar(colorScheme),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: () =>
              ref.read(progressControllerProvider.notifier).loadProgress(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.isLoading && state.recentWorkouts.isEmpty)
                  const LoadingState()
                else if (state.errorMessage != null &&
                    state.recentWorkouts.isEmpty)
                  ErrorState(
                    message: state.errorMessage!,
                    onRetry: () => ref
                        .read(progressControllerProvider.notifier)
                        .loadProgress(),
                  )
                else
                  _tabContent(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabsBar(ColorScheme colorScheme) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Row(
      children: List.generate(_tabs.length, (index) {
        final selected = _selectedTab == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                _tabs[index],
                style: AppTypography.labelSmall.copyWith(
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );

  Widget _tabContent(ProgressState state) {
    final Widget content = switch (_selectedTab) {
      1 => ProgressBodyTab(
        state: state,
        rangeWeeks: _bodyRangeWeeks,
        onLogWeight: _recordWeight,
      ),
      2 => ProgressWorkoutTab(state: state),
      3 => ProgressHistoryTab(state: state),
      _ => ProgressOverviewTab(state: state),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(key: ValueKey(_selectedTab), child: content),
    );
  }

  Future<void> _recordWeight(double? initialWeight) async {
    final controller = TextEditingController(
      text: initialWeight?.toStringAsFixed(1) ?? '',
    );
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.t.core.progress.weightDialog.title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: context.t.core.progress.weightDialog.currentWeight,
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.t.core.progress.weightDialog.cancel),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed != null && parsed > 0 && parsed < 500) {
                Navigator.pop(dialogContext, parsed);
              }
            },
            child: Text(context.t.core.progress.weightDialog.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && mounted) {
      await ref.read(progressControllerProvider.notifier).recordWeight(value);
    }
  }
}
