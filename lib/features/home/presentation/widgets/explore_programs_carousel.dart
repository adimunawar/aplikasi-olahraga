import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class ExploreProgramItem {
  final String id;
  final String title;
  final String durationText;
  final String levelText;
  final String imageAsset;

  const ExploreProgramItem({
    required this.id,
    required this.title,
    this.durationText = '4 Minggu',
    this.levelText = 'Beginner',
    this.imageAsset = 'assets/images/coach_hero.png',
  });
}

/// Carousel "Jelajahi Program" (Mockup Referensi 1:1)
class ExploreProgramsCarousel extends StatelessWidget {
  final List<ExploreProgramItem> programs;
  final VoidCallback? onSeeAll;
  final ValueChanged<ExploreProgramItem>? onProgramTap;

  const ExploreProgramsCarousel({
    super.key,
    required this.programs,
    this.onSeeAll,
    this.onProgramTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Baris: Jelajahi Program & Lihat Semua ➔
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jelajahi Program',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: const Color(0xFF141718),
              ),
            ),
            InkWell(
              onTap: onSeeAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Semua',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Color(0xFF16A34A),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Horizontal List Cards
        SizedBox(
          height: 155,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: programs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = programs[index];
              return _buildCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, ExploreProgramItem item) {
    return InkWell(
      onTap: () => onProgramTap?.call(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Atas
            Container(
              height: 90,
              width: double.infinity,
              color: const Color(0xFF2A2E2B),
              child: Image.asset(
                item.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.fitness_center_rounded, color: Colors.white54, size: 30),
                ),
              ),
            ),

            // Info Bawah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: const Color(0xFF141718),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.durationText} • ${item.levelText}',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 10,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

