import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';

/// Loading Shimmer Skeleton dengan Animasi Halus untuk Home Screen (Mockup 1:1)
class HomeLoadingSkeleton extends StatefulWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  State<HomeLoadingSkeleton> createState() => _HomeLoadingSkeletonState();
}

class _HomeLoadingSkeletonState extends State<HomeLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.45, end: 0.85).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        final opacity = _shimmerAnimation.value;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Skeleton
              Row(
                children: [
                  _buildBox(
                    width: 46,
                    height: 46,
                    shape: BoxShape.circle,
                    opacity: opacity,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBox(
                        width: 140,
                        height: 16,
                        radius: 6,
                        opacity: opacity,
                      ),
                      const SizedBox(height: 6),
                      _buildBox(
                        width: 180,
                        height: 12,
                        radius: 4,
                        opacity: opacity,
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildBox(
                    width: 42,
                    height: 42,
                    shape: BoxShape.circle,
                    opacity: opacity,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Goal Card Skeleton
              _buildBox(
                width: double.infinity,
                height: 175,
                radius: 24,
                opacity: opacity,
              ),
              const SizedBox(height: 24),

              // 3. Workout Card Skeleton
              _buildBox(
                width: 160,
                height: 18,
                radius: 6,
                opacity: opacity,
              ),
              const SizedBox(height: 12),
              _buildBox(
                width: double.infinity,
                height: 160,
                radius: 22,
                opacity: opacity,
              ),
              const SizedBox(height: 24),

              // 4. This Week Progress Skeleton
              _buildBox(
                width: 180,
                height: 18,
                radius: 6,
                opacity: opacity,
              ),
              const SizedBox(height: 12),
              _buildBox(
                width: double.infinity,
                height: 80,
                radius: 22,
                opacity: opacity,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBox({
    required double width,
    required double height,
    double radius = 12,
    BoxShape shape = BoxShape.rectangle,
    required double opacity,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral200.withValues(alpha: opacity),
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(radius) : null,
      ),
    );
  }
}
