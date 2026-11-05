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
  bool _isPlaying = false;

  void _onWatchDemo() {
    setState(() => _isPlaying = !_isPlaying);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPlaying
              ? 'Memutar demonstrasi gerakan ${widget.exercise.name.get("id")}...'
              : 'Video demonstrasi dijeda.',
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
          // Tombol Watch Demo di Kanan Atas
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _onWatchDemo,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.limeCardSurface,
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
                        _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
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
          const SizedBox(height: 10),

          // Tampilan Visual Pose Awal >>> Pose Akhir
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFBFDF9),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Pose Awal
                Expanded(
                  child: _buildPoseIllustration(
                    label: 'Start Position',
                    imagePath: widget.exercise.media.startPose,
                    isStart: true,
                  ),
                ),

                // Panah Transisi Hijau >>>
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chevron_right_rounded, color: AppColors.limeAccent.withValues(alpha: 0.8), size: 22),
                      Icon(Icons.chevron_right_rounded, color: AppColors.limeAccent, size: 22),
                      Icon(Icons.chevron_right_rounded, color: AppColors.greenDark, size: 22),
                    ],
                  ),
                ),

                // Pose Akhir
                Expanded(
                  child: _buildPoseIllustration(
                    label: 'End Position',
                    imagePath: widget.exercise.media.endPose,
                    isStart: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoseIllustration({
    required String label,
    required String imagePath,
    required bool isStart,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              // Fallback gambar jika path webp spesifik belum ada
              return Image.asset(
                'assets/images/Detail Gerakan.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Icon(
                    isStart ? Icons.accessibility_new_rounded : Icons.sports_gymnastics_rounded,
                    size: 56,
                    color: AppColors.neutral400,
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral500,
          ),
        ),
      ],
    );
  }
}

