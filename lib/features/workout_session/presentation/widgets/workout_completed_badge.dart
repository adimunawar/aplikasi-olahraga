import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_colors.dart';

/// Scalloped badge dengan animasi pop-in dan confetti burst (Mockup 1:1 Resolusi Tinggi)
class WorkoutCompletedBadge extends StatefulWidget {
  final double size;

  const WorkoutCompletedBadge({super.key, this.size = 150});

  @override
  State<WorkoutCompletedBadge> createState() => _WorkoutCompletedBadgeState();
}

class _WorkoutCompletedBadgeState extends State<WorkoutCompletedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _badgeScale;
  late final Animation<double> _checkScale;
  late final Animation<double> _confettiProgress;
  late final Animation<double> _confettiOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Badge scalloped pop dengan elastic spring
    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
      ),
    );

    // Checkmark scale in setelah badge mulai terbuka
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOutBack),
      ),
    );

    // Partikel konfeti memancar keluar
    _confettiProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Fade-in konfeti
    _confettiOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.35, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Confetti burst memancar keluar dari badge
              CustomPaint(
                size: Size(size, size),
                painter: _ConfettiPainter(
                  progress: _confettiProgress.value,
                  opacity: _confettiOpacity.value,
                ),
              ),

              // 2. Scalloped Badge hijau dengan checkmark putih
              Transform.scale(
                scale: _badgeScale.value,
                child: CustomPaint(
                  size: Size(size * 0.58, size * 0.58),
                  painter: _ScallopBadgePainter(
                    color: AppColors.celebrationBadge,
                  ),
                  child: SizedBox(
                    width: size * 0.58,
                    height: size * 0.58,
                    child: Center(
                      child: Transform.scale(
                        scale: _checkScale.value,
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.surface,
                          size: 44,
                          weight: 700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScallopBadgePainter extends CustomPainter {
  final Color color;

  _ScallopBadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.88;
    const points = 16;
    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final radius = isOuter ? outerRadius : innerRadius;
      final angle = (i * math.pi) / points;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Soft drop shadow
    canvas.drawShadow(path, color.withValues(alpha: 0.35), 8, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScallopBadgePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final double opacity;

  _ConfettiPainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.44;

    final particles = [
      // angle in deg, target distance factor, color, isDot
      (angle: 15.0, dist: 0.95, color: AppColors.tertiaryFixedDim, isDot: true),
      (angle: 38.0, dist: 1.05, color: AppColors.secondary, isDot: false),
      (angle: 65.0, dist: 0.92, color: AppColors.amberWarning, isDot: true),
      (angle: 95.0, dist: 1.08, color: AppColors.limeAccent, isDot: false),
      (angle: 125.0, dist: 0.96, color: AppColors.workoutPush, isDot: true),
      (angle: 155.0, dist: 1.02, color: AppColors.coral, isDot: false),
      (angle: 185.0, dist: 0.94, color: AppColors.secondary, isDot: true),
      (angle: 215.0, dist: 1.06, color: AppColors.amberWarning, isDot: false),
      (angle: 245.0, dist: 0.92, color: AppColors.limeAccent, isDot: true),
      (angle: 275.0, dist: 1.04, color: AppColors.workoutLegs, isDot: false),
      (angle: 305.0, dist: 0.96, color: AppColors.secondary, isDot: true),
      (
        angle: 335.0,
        dist: 1.02,
        color: AppColors.tertiaryFixedDim,
        isDot: false,
      ),
    ];

    for (final p in particles) {
      final rad = p.angle * (math.pi / 180.0);
      // Animasi memancar dari radius 0.35 keluar ke radius target (p.dist)
      final currentDist = lerpDouble(0.35, p.dist, progress) ?? p.dist;
      final r = maxRadius * currentDist;
      final x = center.dx + r * math.cos(rad);
      final y = center.dy + r * math.sin(rad);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      if (p.isDot) {
        final dotSize = lerpDouble(1.5, 3.5, progress) ?? 3.5;
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      } else {
        canvas.save();
        canvas.translate(x, y);
        // Putaran dinamis saat meluncur keluar
        canvas.rotate(rad + (1.0 - progress) * 1.2);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-4, -2, 8, 4),
            const Radius.circular(2),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.opacity != opacity;
}
