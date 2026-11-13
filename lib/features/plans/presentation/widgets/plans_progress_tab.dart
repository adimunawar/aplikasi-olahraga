import 'package:flutter/material.dart';
import '../../../../core/database/models/body_measurement_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PlansProgressTab extends StatelessWidget {
  final UserProfileEntity? profile;
  final List<BodyMeasurementEntity> weightHistory;
  final int completedWorkouts;
  final int totalScheduledWorkouts;
  final int currentWeek;
  final int totalWeeks;
  final bool hasError;
  final VoidCallback onRetry;
  final VoidCallback onLogWeight;
  final VoidCallback onStartWorkout;

  const PlansProgressTab({
    super.key,
    required this.profile,
    required this.weightHistory,
    required this.completedWorkouts,
    required this.totalScheduledWorkouts,
    required this.currentWeek,
    required this.totalWeeks,
    this.hasError = false,
    required this.onRetry,
    required this.onLogWeight,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return _buildErrorState();
    }

    // If no weight logged and no workouts completed, show Empty State
    final isEmpty = weightHistory.isEmpty && completedWorkouts == 0;
    if (isEmpty) {
      return _buildEmptyState();
    }

    return _buildContent(context);
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load progress',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't load your progress data. Please check your connection and try again.",
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF6B7280),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.limeAccent,
                foregroundColor: AppColors.darkCharcoal,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                // Illustration / Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F9ED),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4F836), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 46,
                    color: Color(0xFF84CC16),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'No progress data yet',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Start your first workout and log your weight to see your progress here.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Button 1: Log Today's Weight
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onLogWeight,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.limeAccent,
                      foregroundColor: AppColors.darkCharcoal,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Log Today's Weight",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Button 2: Start Workout
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onStartWorkout,
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text(
                      'Start Workout',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkCharcoal,
                      side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final curWeight = profile?.currentWeightKg ?? 75.0;
    final tarWeight = profile?.targetWeightKg ?? 82.0;

    // Weight gain/loss diff from start
    final double initialWeight = weightHistory.isNotEmpty
        ? weightHistory.first.value
        : curWeight;
    final double weightDiff = curWeight - initialWeight;
    final double remainingWeight = (tarWeight - curWeight).abs();

    final diffSign = weightDiff >= 0 ? '+' : '';
    final diffText = '$diffSign${weightDiff.toStringAsFixed(1)} kg';

    // Workouts consistency
    final totalWorkouts = totalScheduledWorkouts > 0 ? totalScheduledWorkouts : 12;
    final completed = completedWorkouts.clamp(0, totalWorkouts);
    final consistencyPercent = ((completed / totalWorkouts) * 100).round();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Your Progress Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: "Your Progress" and "Week X of Y"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Progress',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    Text(
                      'Week $currentWeek of $totalWeeks',
                      style: AppTypography.labelMedium.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Week Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (currentWeek / (totalWeeks > 0 ? totalWeeks : 12)).clamp(0.05, 1.0),
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF84CC16)),
                  ),
                ),
                const SizedBox(height: 20),

                // 2 Weight Stat Boxes
                Row(
                  children: [
                    // Box 1: Current Weight
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.scale_outlined, size: 16, color: Color(0xFF6B7280)),
                                const SizedBox(width: 6),
                                Text(
                                  'Current Weight',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${curWeight.toStringAsFixed(1)} kg',
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              diffText,
                              style: AppTypography.labelSmall.copyWith(
                                color: const Color(0xFF16A34A),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Box 2: Target Weight
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.track_changes_outlined, size: 16, color: Color(0xFF6B7280)),
                                const SizedBox(width: 6),
                                Text(
                                  'Target Weight',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${tarWeight.toStringAsFixed(1)} kg',
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${remainingWeight.toStringAsFixed(1)} kg remaining',
                              style: AppTypography.labelSmall.copyWith(
                                color: const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Weight Progress Line Chart Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weight Progress',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF84CC16),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Weight (kg)',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // The Chart
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: _WeightLineChart(
                    weightHistory: weightHistory,
                    currentWeight: curWeight,
                    targetWeight: tarWeight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. Workout Consistency Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F9ED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        size: 18,
                        color: Color(0xFF84CC16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Workout Consistency',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completed / $totalWorkouts workouts',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    Text(
                      '$consistencyPercent%',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (consistencyPercent / 100).clamp(0.05, 1.0),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF84CC16)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bottom Action: Log Today's Weight
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onLogWeight,
              icon: const Icon(Icons.scale_rounded, size: 18),
              label: const Text(
                "Log Today's Weight",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.limeAccent,
                foregroundColor: AppColors.darkCharcoal,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightLineChart extends StatelessWidget {
  final List<BodyMeasurementEntity> weightHistory;
  final double currentWeight;
  final double targetWeight;

  const _WeightLineChart({
    required this.weightHistory,
    required this.currentWeight,
    required this.targetWeight,
  });

  @override
  Widget build(BuildContext context) {
    // Generate data points: at least 5 points (W1 to W5)
    final points = <double>[];
    if (weightHistory.length >= 3) {
      for (final m in weightHistory.take(5)) {
        points.add(m.value);
      }
    } else {
      // Interpolate simulated initial trend up to current weight
      final start = currentWeight - 1.2;
      points.addAll([
        start,
        start + 0.4,
        start + 0.8,
        currentWeight,
      ]);
    }

    // Determine min & max Y
    double minY = points.reduce((a, b) => a < b ? a : b);
    double maxY = points.reduce((a, b) => a > b ? a : b);
    if ((maxY - minY).abs() < 2.0) {
      minY = (currentWeight - 2.0).floorToDouble();
      maxY = (currentWeight + 2.0).ceilToDouble();
    } else {
      minY = (minY - 1.0).floorToDouble();
      maxY = (maxY + 1.0).ceilToDouble();
    }

    final yLabels = [
      maxY.toStringAsFixed(0),
      ((maxY + minY) / 2).toStringAsFixed(0),
      minY.toStringAsFixed(0),
    ];

    return Row(
      children: [
        // Y-axis labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: yLabels.map((lbl) {
            return Text(
              lbl,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
        const SizedBox(width: 8),

        // Chart canvas and X-axis
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LineChartPainter(
                    data: points,
                    minY: minY,
                    maxY: maxY,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // X-axis labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return Text(
                    'W${index + 1}',
                    style: TextStyle(
                      color: index < points.length
                          ? const Color(0xFF4B5563)
                          : const Color(0xFF9CA3AF),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double minY;
  final double maxY;

  _LineChartPainter({
    required this.data,
    required this.minY,
    required this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) return;

    final gridPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), gridPaint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), gridPaint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), gridPaint);

    final rangeY = (maxY - minY) > 0 ? (maxY - minY) : 1.0;
    final totalSteps = 5; // W1 to W5
    final stepX = size.width / (totalSteps - 1);

    final offsets = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedY = (data[i] - minY) / rangeY;
      final y = size.height - (normalizedY * size.height);
      offsets.add(Offset(x, y));
    }

    // Line Path
    final path = Path();
    path.moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Fill underneath
    final fillPath = Path.from(path)
      ..lineTo(offsets.last.dx, size.height)
      ..lineTo(offsets.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF84CC16).withOpacity(0.25),
          const Color(0xFF84CC16).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final linePaint = Paint()
      ..color = const Color(0xFF84CC16)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Nodes
    final nodeFill = Paint()..color = Colors.white;
    final nodeBorder = Paint()
      ..color = const Color(0xFF84CC16)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final pt in offsets) {
      canvas.drawCircle(pt, 4.0, nodeFill);
      canvas.drawCircle(pt, 4.0, nodeBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY;
  }
}

