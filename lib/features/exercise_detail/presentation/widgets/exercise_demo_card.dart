import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Box 1: Demo Gerakan (Mockup 1:1)
/// - Menampilkan pose awal dan akhir dengan panah transisi (>>>)
/// - Tombol "Watch Demo" di pojok kanan atas
class ExerciseDemoCard extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDemoCard({super.key, required this.exercise});

  @override
  State<ExerciseDemoCard> createState() => _ExerciseDemoCardState();
}

class _ExerciseDemoCardState extends State<ExerciseDemoCard> {
  bool _isPlaying = true;

  void _onWatchDemo() {
    setState(() => _isPlaying = !_isPlaying);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPlaying
              ? 'Memutar demonstrasi gerakan ${widget.exercise.name.get("id")}...'
              : 'Demonstrasi gerakan dijeda.',
        ),
        backgroundColor: AppColors.darkCharcoal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar: Section Title + Tombol Kontrol
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.limeAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Exercise Demo',
                    style: AppTypography.headlineSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF141718),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _onWatchDemo,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.limeAccent.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        size: 16,
                        color: AppColors.darkCharcoal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPlaying ? 'Playing Demo' : 'Watch Demo',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tampilan Visual Animasi Gerakan Penuh (Full-Width Animated WebP)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5EB), width: 1.2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/exercises/${widget.exercise.id}.webp',
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      widget.exercise.media.startPose,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center_rounded,
                                size: 48,
                                color: AppColors.neutral400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.exercise.name.get('id'),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.neutral500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
