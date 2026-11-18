import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/media_url_resolver.dart';
import '../../../../core/widgets/app_smart_image.dart';

/// Container Video / Demonstrasi Gerakan Latihan:
/// - Memutar video demonstrasi (video_url dari Supabase) secara looping & muted
/// - Fallback mulus ke gambar poster jika video belum tersedia / gagal dimuat
/// - Dilengkapi tombol Play/Pause dan Fullscreen expand
class ActiveWorkoutVideoCard extends StatefulWidget {
  final String? videoUrl;
  final String imageAsset;
  final VoidCallback onFullscreen;
  final bool autoPlay;

  const ActiveWorkoutVideoCard({
    super.key,
    this.videoUrl,
    required this.imageAsset,
    required this.onFullscreen,
    this.autoPlay = true,
  });

  @override
  State<ActiveWorkoutVideoCard> createState() => _ActiveWorkoutVideoCardState();
}

class _ActiveWorkoutVideoCardState extends State<ActiveWorkoutVideoCard> {
  VideoPlayerController? _controller;
  int _initGeneration = 0;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant ActiveWorkoutVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final int currentGeneration = ++_initGeneration;
    final rawUrl = widget.videoUrl?.trim();
    final url = MediaUrlResolver.resolve(rawUrl);

    if (url == null || url.isEmpty) {
      await _disposeController();
      if (mounted && currentGeneration == _initGeneration) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
      return;
    }

    await _disposeController();

    if (!mounted || currentGeneration != _initGeneration) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final controller = _createController(url);

    try {
      await controller.initialize();
      if (!mounted || currentGeneration != _initGeneration) {
        await controller.dispose();
        return;
      }

      await controller.setLooping(true);
      await controller.setVolume(
        0.0,
      ); // Muted agar tidak bentrok dengan audio pengguna
      if (widget.autoPlay) {
        await controller.play();
      }

      if (mounted && currentGeneration == _initGeneration) {
        _controller = controller;
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      } else {
        await controller.dispose();
      }
    } catch (e) {
      await controller.dispose();
      if (mounted && currentGeneration == _initGeneration) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  VideoPlayerController _createController(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return VideoPlayerController.networkUrl(Uri.parse(url));
    }
    return VideoPlayerController.asset(url);
  }

  Future<void> _disposeController() async {
    final oldController = _controller;
    _controller = null;
    if (oldController != null) {
      await oldController.dispose();
    }
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  @override
  void dispose() {
    _initGeneration++;
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasInitializedVideo =
        _controller != null && _controller!.value.isInitialized && !_hasError;

    return Container(
      height: 215,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral800.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player saat video tersedia & siap diputar
            if (hasInitializedVideo)
              GestureDetector(
                onTap: _togglePlayPause,
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
              )
            else
              // Fallback Poster Image
              AppSmartImage(
                imagePathOrUrl: widget.imageAsset,
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

            // Loading overlay halus saat memuat video
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),

            // Kontrol Play / Pause di Sudut Kiri Bawah saat video aktif
            if (hasInitializedVideo)
              Positioned(
                left: 12,
                bottom: 12,
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    // 48x48: target sentuh minimal untuk penggunaan saat latihan.
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

            // Tombol Fullscreen di Sudut Kanan Bawah
            Positioned(
              right: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: widget.onFullscreen,
                child: Container(
                  // 48x48: target sentuh minimal untuk penggunaan saat latihan.
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 24,
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
