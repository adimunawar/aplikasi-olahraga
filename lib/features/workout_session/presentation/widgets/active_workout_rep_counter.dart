import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Large set counter used on the Active Workout screen.
class ActiveWorkoutRepCounter extends StatefulWidget {
  final int initialValue;
  final bool isDuration;
  final ValueChanged<int> onChanged;

  const ActiveWorkoutRepCounter({
    super.key,
    required this.initialValue,
    required this.isDuration,
    required this.onChanged,
  });

  @override
  State<ActiveWorkoutRepCounter> createState() =>
      _ActiveWorkoutRepCounterState();
}

class _ActiveWorkoutRepCounterState extends State<ActiveWorkoutRepCounter> {
  late int _value;

  int get _step => widget.isDuration ? 5 : 1;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(1, 999).toInt();
    widget.onChanged(_value);
  }

  @override
  void didUpdateWidget(covariant ActiveWorkoutRepCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue ||
        oldWidget.isDuration != widget.isDuration) {
      _value = widget.initialValue.clamp(1, 999).toInt();
    }
  }

  void _change(int delta) {
    final next = (_value + delta).clamp(1, 999).toInt();
    if (next == _value) return;
    setState(() => _value = next);
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final unit = widget.isDuration
        ? t.workoutSession.durationUnit
        : t.workoutSession.repsUnit;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CounterButton(
          icon: Icons.remove_rounded,
          onTap: () => _change(-_step),
        ),
        const SizedBox(width: 18),
        Container(
          width: 142,
          height: 142,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FCEB),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.limeAccent,
              width: 8,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_value',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.darkCharcoal,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unit,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 18),
        _CounterButton(
          icon: Icons.add_rounded,
          onTap: () => _change(_step),
          highlight: true,
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  const _CounterButton({
    required this.icon,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlight ? AppColors.limeAccent : const Color(0xFFF1F3F5),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            size: 25,
            color: AppColors.darkCharcoal,
          ),
        ),
      ),
    );
  }
}
