import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Loading Shimmer Skeleton untuk Home Screen (Mockup 1:1)
class HomeLoadingSkeleton extends StatelessWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Skeleton
          Row(
            children: [
              _buildBox(width: 46, height: 46, shape: BoxShape.circle),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBox(width: 140, height: 16, radius: 6),
                  const SizedBox(height: 6),
                  _buildBox(width: 180, height: 12, radius: 4),
                ],
              ),
              const Spacer(),
              _buildBox(width: 42, height: 42, shape: BoxShape.circle),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Goal Card Skeleton
          _buildBox(width: double.infinity, height: 175, radius: 24),
          const SizedBox(height: 24),

          // 3. Workout Card Skeleton
          _buildBox(width: 160, height: 18, radius: 6),
          const SizedBox(height: 12),
          _buildBox(width: double.infinity, height: 160, radius: 22),
          const SizedBox(height: 24),

          // 4. This Week Progress Skeleton
          _buildBox(width: 180, height: 18, radius: 6),
          const SizedBox(height: 12),
          _buildBox(width: double.infinity, height: 80, radius: 22),
        ],
      ),
    );
  }

  Widget _buildBox({
    required double width,
    required double height,
    double radius = 12,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral200.withValues(alpha: 0.65),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(radius) : null,
      ),
    );
  }
}
