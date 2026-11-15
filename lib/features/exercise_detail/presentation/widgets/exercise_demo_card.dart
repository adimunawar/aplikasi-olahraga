import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/media_url_resolver.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Box 1: Demo Gerakan (Mockup 1:1)
/// - Menampilkan video demonstrasi gerakan dari Supabase (video_url)
/// - Fallback mulus ke WebP animasi / asset gambar jika video tidak tersedia
/// - Kontrol Play / Pause melalui tombol header atau tap langsung pada video
/// - Fitur Mute / Unmute audio video
class ExerciseDemoCard extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDemoCard({super.key, required this.exercise});

  @override
  State<ExerciseDemoCard> createState() => _ExerciseDemoCardState();
}

class _ExerciseDemoCardState extends State<ExerciseDemoCard> {
  VideoPlayerController? _controller;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isMuted = true;

  String? get _videoUrl => widget.exercise.resolvedVideoUrl;
  String get _imageUrl => widget.exercise.resolvedImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant ExerciseDemoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id ||
        oldWidget.exercise.videoUrl != widget.exercise.videoUrl) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final url = _videoUrl?.trim();
    debugPrint('[ExerciseDemoCard] 🎬 Cek media untuk "${widget.exercise.id}":');
    debugPrint('[ExerciseDemoCard] 👉 Raw video_url: ${widget.exercise.videoUrl}');
    debugPrint('[ExerciseDemoCard] 👉 Resolved Video URL: $url');
    debugPrint('[ExerciseDemoCard] 👉 Poster Image: $_imageUrl');

    if (url == null || url.isEmpty) {
      debugPrint('[ExerciseDemoCard] ℹ️ Video URL tidak tersedia / null, menampilkan gambar demonstrasi.');
      await _disposeController();
      if (mounted) setState(() {});
      return;
    }

    await _disposeController();

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final controller = _createController(url);
      _controller = controller;

      debugPrint('[ExerciseDemoCard] ⏳ Menghubungi server media...');
      await controller.initialize();
      if (!mounted) return;

      await controller.setLooping(true);
      await controller.setVolume(_isMuted ? 0.0 : 1.0);
      await controller.play();

      debugPrint(
        '[ExerciseDemoCard] ✅ Video BERHASIL diputar! Size: ${controller.value.size}, Durasi: ${controller.value.duration}',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('[ExerciseDemoCard] ❌ GAGAL memuat video ($url): $e');
      if (mounted) {
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

  void _toggleMute() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo =
        _controller != null && _controller!.value.isInitialized && !_hasError;
    final isPlaying = hasVideo && (_controller?.value.isPlaying ?? false);

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
                onTap: hasVideo ? _togglePlayPause : null,
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
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        size: 16,
                        color: AppColors.darkCharcoal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPlaying ? 'Pause Demo' : 'Watch Demo',
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

          // Tampilan Visual: Video Player atau Animasi Gambar WebP
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: hasVideo ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5EB), width: 1.2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasVideo)
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  )
                else
                  _buildFallbackImage(),

                // Loading spinner overlay saat buffer video
                if (_isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    child: const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Overlay Play Icon di tengah saat video dipause
                if (hasVideo && !isPlaying && !_isLoading)
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: Center(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Kontrol Audio Mute / Unmute di pojok kanan bawah video
                if (hasVideo)
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: GestureDetector(
                      onTap: _toggleMute,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isMuted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 18,
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

  Widget _buildFallbackImage() {
    return AppSmartImage(
      imagePathOrUrl: _imageUrl,
      fit: BoxFit.contain,
      errorWidget: Image.asset(
        'assets/images/exercises/${widget.exercise.id}.webp',
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) {
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
      ),
    );
  }
}
