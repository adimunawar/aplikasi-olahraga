import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/features/progress/application/weight_chart_series.dart';
import 'package:workout_app/i18n/strings.g.dart';

import 'progress_card_decoration.dart';

/// Grafik tren berat badan pada rentang minggu tertentu.
class WeightTrendCard extends StatelessWidget {
  const WeightTrendCard({
    super.key,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final labels = context.t.core.progress.weightTrend;
    final latest = points.isEmpty ? null : points.last;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 10),
      decoration: progressCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                labels.title,
                style: AppTypography.labelMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (latest != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.primaryContainer
                        : AppColors.limeSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    labels.weekValue(
                      week: latest.weekNumber,
                      value: latest.weightKg.toStringAsFixed(1),
                    ),
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? colorScheme.primary : AppColors.greenDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasData)
            SizedBox(
              height: 188,
              width: double.infinity,
              child: CustomPaint(
                painter: WeightTrendPainter(
                  points: points,
                  weeks: weeks,
                  weekLabel: (week) => labels.weekShort(week: week),
                  gridColor: isDark
                      ? colorScheme.outlineVariant
                      : AppColors.neutral200,
                  labelColor: colorScheme.onSurfaceVariant,
                  lineColor: isDark
                      ? colorScheme.primary
                      : AppColors.greenBrand,
                ),
              ),
            )
          else
            SizedBox(
              height: 188,
              child: Center(
                child: Text(
                  labels.empty,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pelukis grafik tren berat badan beserta sumbu minggu dan nilai kg.
class WeightTrendPainter extends CustomPainter {
  const WeightTrendPainter({
    required this.points,
    required this.weeks,
    required this.weekLabel,
    this.gridColor = AppColors.neutral200,
    this.labelColor = AppColors.neutral600,
    this.lineColor = AppColors.greenBrand,
  });

  final List<WeightChartPoint> points;
  final int weeks;

  /// Label sumbu horizontal untuk sebuah nomor minggu (dilokalkan oleh pemanggil).
  final String Function(int week) weekLabel;

  final Color gridColor;
  final Color labelColor;
  final Color lineColor;

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
      final x =
          left + ((point.weekNumber - 1) / math.max(weeks - 1, 1)) * plotWidth;
      final y = top + ((maxY - point.weightKg) / yRange) * plotHeight;
      return Offset(x, y);
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;
    final labelStyle = AppTypography.labelSmall.copyWith(
      color: labelColor,
      fontSize: 9,
    );
    for (var i = 0; i <= 4; i++) {
      final y = top + (plotHeight * i / 4);
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
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
        colors: [
          AppColors.limeAccent.withValues(alpha: 0.24),
          AppColors.limeAccent.withValues(alpha: 0.01),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(left, top, plotWidth, plotHeight));
    canvas.drawPath(fill, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    for (final point in points) {
      final p = position(point);
      canvas.drawCircle(p, 3.2, Paint()..color = AppColors.limeAccent);
      canvas.drawCircle(
        p,
        3.2,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    for (var week = 1; week <= weeks; week++) {
      final x = left + ((week - 1) / math.max(weeks - 1, 1)) * plotWidth;
      final text = TextPainter(
        text: TextSpan(
          text: weekLabel(week),
          style: labelStyle.copyWith(fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(x - text.width / 2, top + plotHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant WeightTrendPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.weeks != weeks ||
      oldDelegate.weekLabel != weekLabel ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.labelColor != labelColor ||
      oldDelegate.lineColor != lineColor;
}
