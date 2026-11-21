import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import '../../../../../i18n/strings.g.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../application/weight_chart_series.dart';
import '../../../domain/models/workout_history_item.dart';

class WeightTrendCard extends StatelessWidget {
  const WeightTrendCard({super.key, 
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
            child: CustomPaint(painter: WeightTrendPainter(points: points, weeks: weeks)),
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

class WeightTrendPainter extends CustomPainter {
  const WeightTrendPainter({required this.points, required this.weeks});
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
  bool shouldRepaint(covariant WeightTrendPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.weeks != weeks;
}

class CurrentWeightSummary extends StatelessWidget {
  const CurrentWeightSummary({super.key, required this.currentWeight, required this.change, required this.rangeWeeks});
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

class MetricNotTrackedCard extends StatelessWidget {
  const MetricNotTrackedCard({super.key, required this.metric});
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

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.fullWidth = false,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool fullWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.92, end: 1),
    duration: const Duration(milliseconds: 420),
    curve: Curves.easeOutCubic,
    builder: (context, scale, child) => Opacity(
      opacity: ((scale - 0.92) / 0.08).clamp(0.0, 1.0).toDouble(),
      child: Transform.translate(
        offset: Offset(0, (1 - scale) * 28),
        child: Transform.scale(scale: scale, child: child),
      ),
    ),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
        width: fullWidth ? double.infinity : null,
        constraints: const BoxConstraints(minHeight: 88),
        padding: const EdgeInsets.all(13),
        decoration: _cardDecoration().copyWith(
          borderRadius: BorderRadius.circular(17),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: const BoxDecoration(
                color: AppColors.limeSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: AppColors.greenDark),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 10,
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    ),
  );
}

class ProgramCard extends StatelessWidget {
  const ProgramCard({
    super.key,
    required this.title,
    required this.week,
    required this.totalWeeks,
    required this.percent,
  });

  final String title;
  final int week;
  final int totalWeeks;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 100);
    final safeTotalWeeks = totalWeeks > 0 ? totalWeeks : 1;
    final safeWeek = week.clamp(1, safeTotalWeeks);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration().copyWith(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.limeSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 19,
                  color: AppColors.greenDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Week $safeWeek of $safeTotalWeeks',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.limeSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: AppColors.greenDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: AppColors.neutral400,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Program completion',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 10,
                ),
              ),
              Text(
                '$safePercent%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.greenDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: safePercent / 100),
              duration: const Duration(milliseconds: 850),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: AppColors.neutral100,
                valueColor: const AlwaysStoppedAnimation(AppColors.limeAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KeepGoingCard extends StatelessWidget {
  const KeepGoingCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppColors.limeSurface,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keep Going!',
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Stay consistent. Every workout brings you closer to your goal.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            size: 24,
            color: AppColors.greenDark,
          ),
        ),
      ],
    ),
  );
}

class HighlightsCard extends StatelessWidget {
  const HighlightsCard({super.key, required this.completed, required this.target, required this.weightChange, required this.streak, this.hasWeightData = false});
  final int completed;
  final int target;
  final double weightChange;
  final int streak;
  final bool hasWeightData;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String)>[
      if (target > 0) (Icons.check_circle_outline_rounded, 'Completed $completed of $target workouts this week'),
      if (hasWeightData) (Icons.trending_up_rounded, 'Weight ${weightChange >= 0 ? 'increased' : 'decreased'} by ${weightChange.abs().toStringAsFixed(1)} kg'),
      if (streak > 0) (Icons.emoji_events_outlined, streak == 1
            ? context.t.core.units.activeDaySingular(count: streak)
            : context.t.core.units.activeDayPlural(count: streak)),
    ];
    if (rows.isEmpty) {
      return const ProgressEmptyState(
        icon: Icons.insights_outlined,
        title: 'No highlights yet',
        message: 'Your milestones will appear as you record workouts and measurements.',
        compact: true,
      );
    }
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: List.generate(rows.length, (index) {
        final row = rows[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(offset: Offset((1 - value) * 12, 0), child: child),
          ),
          child: Column(children: [
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
        ]),
        );
      })),
    );
  }
}

class WeightChangeCard extends StatelessWidget {
  const WeightChangeCard({super.key, required this.change, required this.onTap});
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

class RecentWorkoutsCard extends StatelessWidget {
  const RecentWorkoutsCard({super.key, required this.workouts, this.expanded = false});
  final List<WorkoutHistoryItem> workouts;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const ProgressEmptyState(
        icon: Icons.fitness_center_rounded,
        title: 'No recent workouts',
        message: 'Your completed sessions will show up here.',
        compact: true,
      );
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

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()));
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});
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
  boxShadow: AppColors.cardShadow,
);


class ProgressEmptyState extends StatelessWidget {
  const ProgressEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: compact ? 18 : 26),
    decoration: _cardDecoration(),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 40 : 48,
          height: compact ? 40 : 48,
          decoration: const BoxDecoration(
            color: AppColors.limeSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: compact ? 19 : 22, color: AppColors.greenDark),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.titleSmall.copyWith(color: AppColors.darkCharcoal),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
        ),
      ],
    ),
  );
}


/// Subtle entrance motion for Progress cards. Respects the system animation setting.
class ProgressReveal extends StatefulWidget {
  const ProgressReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<ProgressReveal> createState() => _ProgressRevealState();
}

class _ProgressRevealState extends State<ProgressReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}
