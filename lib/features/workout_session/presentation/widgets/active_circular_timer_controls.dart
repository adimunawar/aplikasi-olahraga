import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Timer Melingkar & Kontrol Pause / Next pada Layar Active Workout (Mockup 1:1)
class ActiveCircularTimerControls extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isPaused;
  final VoidCallback onPauseToggle;
  final VoidCallback onNext;

  const ActiveCircularTimerControls({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isPaused,
    required this.onPauseToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;
    final isTimeUp = remainingSeconds <= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tombol Pause / Resume di Kiri
        _buildControlButton(
          icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          label: isPaused ? 'Resume' : 'Pause',
          onTap: onPauseToggle,
        ),
        const SizedBox(width: 24),

        // Timer Lingkaran Besar di Tengah (Dibuat Interactive InkWell agar bisa langsung di-tap)
        GestureDetector(
          onTap: onNext,
          child: Container(
            width: 155,
            height: 155,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTimeUp ? const Color(0xFFF4F9ED) : Colors.white,
              boxShadow: isTimeUp
                  ? [
                      BoxShadow(
                        color: AppColors.limeAccent.withValues(alpha: 0.4),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom Circular Progress Ring
                CustomPaint(
                  size: const Size(155, 155),
                  painter: _CircularTimerRingPainter(
                    progress: progress,
                    isTimeUp: isTimeUp,
                  ),
                ),

                // Angka & Teks di Dalam Lingkaran
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isTimeUp ? 'READY' : 'Rest Time',
                      style: AppTypography.labelSmall.copyWith(
                        color: isTimeUp
                            ? AppColors.greenDark
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTimeUp ? 'GO!' : '$remainingSeconds',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: isTimeUp ? 38 : 46,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        color: isTimeUp
                            ? AppColors.greenDark
                            : const Color(0xFF141718),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTimeUp ? 'Tap to next' : 'seconds',
                      style: AppTypography.labelSmall.copyWith(
                        color: isTimeUp
                            ? AppColors.greenDark
                            : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: isTimeUp ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Tombol Next di Kanan
        _buildControlButton(
          icon: Icons.skip_next_rounded,
          label: 'Next',
          onTap: onNext,
          highlight: isTimeUp,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: highlight ? AppColors.limeAccent : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(18),
          border: highlight
              ? Border.all(color: const Color(0xFF84CC16), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: const Color(0xFF141718),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF141718),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularTimerRingPainter extends CustomPainter {
  final double progress;
  final bool isTimeUp;

  _CircularTimerRingPainter({
    required this.progress,
    this.isTimeUp = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 9.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Lingkaran Background (Abu-abu lembut)
    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Indicator Aktif (Hijau Neon Lime)
    final activePaint = Paint()
      ..color = isTimeUp ? const Color(0xFF84CC16) : const Color(0xFFCCF13E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (isTimeUp ? 1.0 : progress);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularTimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isTimeUp != isTimeUp;
  }
}
