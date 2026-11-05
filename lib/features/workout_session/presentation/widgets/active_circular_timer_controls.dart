import 'dart:math' as math;
import 'package:flutter/material.dart';
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
        ? remainingSeconds / totalSeconds
        : 0.0;

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

        // Timer Lingkaran Besar di Tengah
        SizedBox(
          width: 155,
          height: 155,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom Circular Progress Ring
              CustomPaint(
                size: const Size(155, 155),
                painter: _CircularTimerRingPainter(progress: progress),
              ),

              // Angka & Teks di Dalam Lingkaran
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rest Time',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$remainingSeconds',
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      color: const Color(0xFF141718),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'seconds',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Tombol Next di Kanan
        _buildControlButton(
          icon: Icons.skip_next_rounded,
          label: 'Next',
          onTap: onNext,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(18),
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
                color: const Color(0xFF141718),
                fontSize: 11,
                fontWeight: FontWeight.w600,
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

  _CircularTimerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;

    // Track Lingkaran Abu-abu Terang
    final trackPaint = Paint()
      ..color = const Color(0xFFE9ECEF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Ring Hijau Lime
    final progressPaint = Paint()
      ..color = const Color(0xFFC7F135) // Vibrant Lime Green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularTimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

