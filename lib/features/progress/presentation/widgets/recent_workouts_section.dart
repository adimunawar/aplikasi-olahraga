import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../domain/models/workout_history_item.dart';

/// Section "Recent Workouts" pada Halaman Progress:
/// - Header: "Recent Workouts" dengan tombol "See All" warna hijau lime
/// - Daftar riwayat sesi latihan terbaru dengan thumbnail, tanggal, durasi, kalori,
///   serta badge centang hijau dan panah chevron navigasi
class RecentWorkoutsSection extends StatelessWidget {
  final List<WorkoutHistoryItem>? workouts;
  final VoidCallback? onSeeAll;

  const RecentWorkoutsSection({
    super.key,
    this.workouts,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final List<WorkoutHistoryItem> items = (workouts != null && workouts!.isNotEmpty)
        ? workouts!
        : const [
            WorkoutHistoryItem(
              id: '1',
              title: 'Day 2 - Pull',
              dateText: 'Nov 4, 2026',
              durationText: '40 minutes',
              caloriesText: '320 kcal',
              thumbnailAsset: 'assets/images/Home Workout Push-Up Guide.png',
            ),
            WorkoutHistoryItem(
              id: '2',
              title: 'Day 1 - Push',
              dateText: 'Nov 3, 2026',
              durationText: '45 minutes',
              caloriesText: '380 kcal',
              thumbnailAsset: 'assets/images/Home Workout Push-Up Guide.png',
            ),
            WorkoutHistoryItem(
              id: '3',
              title: 'Day 3 - Legs',
              dateText: 'Nov 1, 2026',
              durationText: '35 minutes',
              caloriesText: '290 kcal',
              thumbnailAsset: 'assets/images/coach_flex.png',
            ),
          ];

    return AppCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Judul & See All (DRY via AppSectionHeader)
          AppSectionHeader.withAction(
            icon: Icons.calendar_month_outlined,
            title: 'Recent Workouts',
            actionText: 'See All',
            onActionTap: onSeeAll ?? () {},
          ),
          const SizedBox(height: 14),

          // Daftar Riwayat Latihan
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Divider(color: AppColors.cardBorder, height: 1),
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildWorkoutRow(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutRow(WorkoutHistoryItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Thumbnail Atlet (DRY via AppSmartImage)
          AppSmartImage(
            imagePathOrUrl: item.thumbnailAsset,
            width: 52,
            height: 42,
            borderRadius: BorderRadius.circular(10),
            fallbackIcon: Icons.fitness_center_rounded,
          ),
          const SizedBox(width: 12),

          // Info Teks (Judul & Metadata)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.dateText}  •  ${item.durationText}  •  ${item.caloriesText}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Centang Hijau Terverifikasi Selesai
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.darkCharcoal,
              size: 15,
            ),
          ),
          const SizedBox(width: 6),

          // Chevron Panah Kanan
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.neutral400,
            size: 20,
          ),
        ],
      ),
    );
  }
}
