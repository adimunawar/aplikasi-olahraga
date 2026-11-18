import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Dedicated rest phase shown between completed sets.
class RestTimerScreen extends StatelessWidget {
  final String nextExerciseName;
  final int nextSet;
  final int totalSets;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isPaused;

  /// Keluar dari layar sesi (sesi tetam in_progress & bisa dilanjutkan).
  /// Bukan skip rest — itu tugas [onSkipRest] di bawah.
  final VoidCallback onExitSession;
  final ValueChanged<int> onAdjustTime;
  final VoidCallback onPauseToggle;
  final VoidCallback onSkipRest;

  const RestTimerScreen({
    super.key,
    required this.nextExerciseName,
    required this.nextSet,
    required this.totalSets,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isPaused,
    required this.onExitSession,
    required this.onAdjustTime,
    required this.onPauseToggle,
    required this.onSkipRest,
  });

  String _formatTime(int seconds) {
    final safeSeconds = seconds.clamp(0, 5999).toInt();
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final progress = totalSeconds > 0
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: onExitSession,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.darkCharcoal,
          ),
        ),
        title: Text(
          t.workoutSession.restTitle,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      // Scrollable saat layar pendek / text scaling besar: konten tetap bisa
      // dijangkau tanpa overflow.
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Ring menyesuaikan tinggi layar; minimal cukup lega untuk angka.
            final ringSize = math
                .min(238.0, math.max(170.0, constraints.maxHeight * 0.4))
                .clamp(150.0, 238.0);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          t.workoutSession.restNextExercise(
                            exercise: nextExerciseName,
                          ),
                          textAlign: TextAlign.center,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.darkCharcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          t.workoutSession.restSetProgress(
                            current: nextSet,
                            total: totalSets,
                          ),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: ringSize,
                          height: ringSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: Size(ringSize, ringSize),
                                painter: _RestProgressPainter(
                                  progress: progress,
                                ),
                              ),
                              // ScaleDown: angka & label ikut menyusut saat
                              // text scaling besar, tanpa overflow.
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      t.workoutSession.restTitle,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: AppColors.neutral600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _formatTime(remainingSeconds),
                                      style: AppTypography.displayLarge
                                          .copyWith(
                                            color: AppColors.darkCharcoal,
                                            fontSize: 47,
                                            fontWeight: FontWeight.w900,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                    ),
                                    if (isPaused) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        t.workoutSession.restPaused,
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: AppColors.greenDark,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _RestControlButton(
                              label: t.workoutSession.restMinusTenSeconds,
                              onTap: () => onAdjustTime(-10),
                            ),
                            _RestPauseButton(
                              isPaused: isPaused,
                              onTap: onPauseToggle,
                            ),
                            _RestControlButton(
                              label: t.workoutSession.restPlusTenSeconds,
                              onTap: () => onAdjustTime(10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _RestTipCard(),
                        const SizedBox(height: 18),
                        TextButton.icon(
                          onPressed: onSkipRest,
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: AppColors.darkCharcoal,
                            size: 19,
                          ),
                          label: Text(
                            t.workoutSession.skipRest,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.darkCharcoal,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Kartu tips istirahat.
class _RestTipCard extends StatelessWidget {
  const _RestTipCard();

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FBE5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE4F3C5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.greenDark,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.workoutSession.restTipTitle,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.greenDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.workoutSession.restTipDescription,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral700,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RestControlButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RestControlButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F3F5),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 70,
          height: 46,
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.darkCharcoal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestPauseButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onTap;

  const _RestPauseButton({required this.isPaused, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 58,
          height: 58,
          child: Icon(
            isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: AppColors.darkCharcoal,
            size: 27,
          ),
        ),
      ),
    );
  }
}

class _RestProgressPainter extends CustomPainter {
  final double progress;

  const _RestProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final background = Paint()
      ..color = const Color(0xFFE8F5D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final foreground = Paint()
      ..color = AppColors.limeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, background);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _RestProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
