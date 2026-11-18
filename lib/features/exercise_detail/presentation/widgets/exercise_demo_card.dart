import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Box 1: Demo Gerakan (Mockup 1:1 Resolusi Tinggi)
///
/// Mematuhi ARCHITECTURE.md:
/// - Presentation Layer murni (Stateless/Stateful UI) tanpa direct DB/I/O
/// - 100% Design Token terstandar (AppColors & AppTypography, zero hardcoded hex)
/// - Target sentuh ergonomis olahraga (minimum 48x48 px hit area)
/// - Pembersihan resource menyeluruh (_controller.dispose())
/// - Fitur Pro: Seamless Studio Blend (tanpa bar hitam), Form Analysis (0.5x Slow-Mo),
///   Looping Progress Bar, dan Glassmorphic Floating Controls
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
  double _playbackSpeed = 1.0;

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
      debugPrint(
        '[ExerciseDemoCard] ℹ️ Video URL tidak tersedia / null, menampilkan gambar demonstrasi.',
      );
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
      await controller.setPlaybackSpeed(_playbackSpeed);
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

  void _toggleSpeed() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      _playbackSpeed = (_playbackSpeed == 1.0) ? 0.5 : 1.0;
      controller.setPlaybackSpeed(_playbackSpeed);
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

    // Rasio proporsional dinamis mengikuti video native (biasanya 16:9),
    // dibatasi clamp(1.2, 1.85) agar tidak terlalu tinggi atau gepeng.
    final videoAspectRatio = hasVideo
        ? _controller!.value.aspectRatio.clamp(1.2, 1.85)
        : (16 / 9);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral800.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  if (hasVideo) {
                    _togglePlayPause();
                  } else {
                    _initializeVideo();
                  }
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.limeAccent,
                      width: 1.2,
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
                          fontSize: 12,
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

          // Tampilan Visual: Video Player Seamless Studio Blend
          AspectRatio(
            aspectRatio: videoAspectRatio,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // Warna putih serasi dengan latar studio video, bebas bar hitam!
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Video Player Utuh (Seamless Blend)
                  if (hasVideo)
                    GestureDetector(
                      onTap: _togglePlayPause,
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    )
                  else
                    _buildFallbackImage(),

                  // 2. Loading Spinner Halus
                  if (_isLoading)
                    Container(
                      color: AppColors.darkCharcoal.withValues(alpha: 0.2),
                      child: const Center(
                        child: SizedBox(
                          width: 34,
                          height: 34,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.limeAccent,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 3. Center Play Icon Overlay saat video dipause
                  if (hasVideo && !isPlaying && !_isLoading)
                    GestureDetector(
                      onTap: _togglePlayPause,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        color: AppColors.darkCharcoal.withValues(alpha: 0.25),
                        child: Center(
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.darkCharcoal.withValues(
                                alpha: 0.75,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.limeAccent,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 4. Floating Action Controls (Glassmorphism Chips)
                  if (hasVideo)
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Chip Kiri: Form Speed Toggle (1.0x / 0.5x Slow-Motion)
                          _buildGlassmorphicButton(
                            icon: _playbackSpeed == 0.5
                                ? Icons.slow_motion_video_rounded
                                : Icons.speed_rounded,
                            label: _playbackSpeed == 0.5 ? '0.5x Slow' : '1.0x',
                            isActive: _playbackSpeed == 0.5,
                            onTap: _toggleSpeed,
                          ),

                          // Chip Kanan: Audio Mute / Unmute
                          _buildGlassmorphicButton(
                            icon: _isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            label: _isMuted ? 'Muted' : 'Audio',
                            isActive: !_isMuted,
                            onTap: _toggleMute,
                          ),
                        ],
                      ),
                    ),

                  // 5. Looping Timeline Progress Bar di tepi paling bawah
                  if (hasVideo)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 3,
                        color: AppColors.neutral200.withValues(alpha: 0.4),
                        child: ValueListenableBuilder<VideoPlayerValue>(
                          valueListenable: _controller!,
                          builder: (context, value, _) {
                            final dur = value.duration.inMilliseconds;
                            final pos = value.position.inMilliseconds;
                            final factor = dur > 0
                                ? (pos / dur).clamp(0.0, 1.0)
                                : 0.0;
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: factor,
                              child: Container(
                                color: AppColors.limeAccent,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tombol chip glassmorphic ergonomis (Touch area 48px sesuai ARCHITECTURE.md)
  Widget _buildGlassmorphicButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.darkCharcoal.withValues(alpha: 0.85)
                : AppColors.darkCharcoal.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? AppColors.limeAccent.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.limeAccent : Colors.white,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isActive ? AppColors.limeAccent : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
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
                const Icon(
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
