import 'package:flutter/material.dart';

/// Card Video Preview Latihan:
/// Menampilkan preview video demonstrasi gerakan dengan kontrol play/pause, durasi, dan ikon fullscreen.
class VideoPreviewCard extends StatelessWidget {
  final bool isPlaying;
  final bool isShowingEndPose;
  final VoidCallback onTogglePlay;

  const VideoPreviewCard({
    super.key,
    required this.isPlaying,
    required this.isShowingEndPose,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background demonstration pose / photo placeholder
          Container(
            color: const Color(0xFFE9EFE6),
            child: Center(
              child: Icon(
                isShowingEndPose ? Icons.sports_gymnastics : Icons.accessibility_new_rounded,
                size: 64,
                color: const Color(0xFF336C36).withValues(alpha: 0.35),
              ),
            ),
          ),

          // Dark gradient overlay for controls
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Central Play Button
          Center(
            child: InkWell(
              onTap: onTogglePlay,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // Bottom Video Controls Overlay
          Positioned(
            left: 10,
            right: 10,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPlaying ? '0:12 / 0:24' : '0:00 / 0:24',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.closed_caption_outlined, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Icon(Icons.fullscreen_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

