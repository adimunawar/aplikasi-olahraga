import 'package:flutter/material.dart';
import '../../../../core/widgets/app_smart_image.dart';

/// Container Video / Animasi Gerakan Latihan:
/// - Foto/video atlet sedang melakukan gerakan (Push-Up) dengan sudut rounded halus
/// - Tombol expand fullscreen di sudut kanan bawah
class ActiveWorkoutVideoCard extends StatelessWidget {
  final String imageAsset;
  final VoidCallback onFullscreen;

  const ActiveWorkoutVideoCard({
    super.key,
    required this.imageAsset,
    required this.onFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 215,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gambar Gerakan
            AppSmartImage(
              imagePathOrUrl: imageAsset,
              fit: BoxFit.cover,
              errorWidget: Container(
                color: const Color(0xFFE2E8F0),
                child: const Center(
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 48,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),

            // Tombol Fullscreen di Kanan Bawah
            Positioned(
              right: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: onFullscreen,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

