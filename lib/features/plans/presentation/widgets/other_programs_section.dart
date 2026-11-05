import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../program/domain/models/workout_program.dart';

/// Section "Other Programs" pada Halaman Plans:
/// - Header: Icon api + "Other Programs" + "See All"
/// - Horizontal scroll program cards:
///   - Menampilkan program yang tersedia dari Supabase CMS / Local Cache
///   - Saat diklik, memicu dialog/sheet detail program untuk ganti program
class OtherProgramsSection extends StatelessWidget {
  final List<WorkoutProgram>? programs;
  final ValueChanged<WorkoutProgram>? onSelectProgram;
  final VoidCallback? onSeeAll;

  const OtherProgramsSection({
    super.key,
    this.programs,
    this.onSelectProgram,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final List<_OtherProgramDisplayData> items;

    if (programs != null && programs!.isNotEmpty) {
      items = programs!.map((p) {
        String title = p.title.en.isNotEmpty ? p.title.en : p.title.id;
        if (title.trim().isEmpty) {
          title = p.id
              .replaceAll('_', ' ')
              .split(' ')
              .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
              .join(' ');
        }
        final schedule = '${p.totalWeeks} Weeks • ${p.daysPerWeek} Days/Week';
        String thumb = p.bannerAsset;
        if (thumb.isEmpty) {
          if (p.id.contains('lower') || p.id.contains('legs')) {
            thumb = 'assets/images/coach_flex.png';
          } else if (p.id.contains('core')) {
            thumb = 'assets/images/coach_hero.png';
          } else {
            thumb = 'assets/images/Home Workout Push-Up Guide.png';
          }
        }

        return _OtherProgramDisplayData(
          program: p,
          title: title,
          scheduleText: schedule,
          thumbnailAsset: thumb,
          fallbackIcon: Icons.fitness_center_rounded,
        );
      }).toList();
    } else {
      items = [
        const _OtherProgramDisplayData(
          title: 'Full Body Bulking',
          scheduleText: '8 Weeks • 4 Days/Week',
          thumbnailAsset: 'assets/images/Home Workout Push-Up Guide.png',
          fallbackIcon: Icons.fitness_center_rounded,
        ),
        const _OtherProgramDisplayData(
          title: 'Lower Body Strength',
          scheduleText: '8 Weeks • 3 Days/Week',
          thumbnailAsset: 'assets/images/coach_flex.png',
          fallbackIcon: Icons.directions_run_rounded,
        ),
        const _OtherProgramDisplayData(
          title: 'Core & Stability',
          scheduleText: '4 Weeks • 3 Days/Week',
          thumbnailAsset: 'assets/images/coach_hero.png',
          fallbackIcon: Icons.sports_gymnastics_rounded,
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Bar (DRY via AppSectionHeader)
        AppSectionHeader.withAction(
          icon: Icons.local_fire_department_rounded,
          title: 'Other Programs',
          actionText: 'See All',
          onActionTap: onSeeAll ?? () {},
        ),
        const SizedBox(height: 12),

        // Horizontal Card Carousel
        SizedBox(
          height: 146,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildProgramCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgramCard(BuildContext context, _OtherProgramDisplayData item) {
    return InkWell(
      onTap: () {
        if (item.program != null && onSelectProgram != null) {
          onSelectProgram!(item.program!);
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 172,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: AppColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Thumbnail dengan Latar Gradien Lime Melengkung
              Container(
                height: 84,
                width: double.infinity,
                color: AppColors.neutral50,
                child: Stack(
                  children: [
                    // Kurva lime di sudut kanan bawah thumbnail
                    Positioned(
                      right: -10,
                      bottom: -15,
                      child: Container(
                        width: 90,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.limeAccent.withOpacity(0.40),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50),
                          ),
                        ),
                      ),
                    ),

                    // Foto Atlet / Thumbnail (DRY via AppSmartImage)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: AppSmartImage(
                          imagePathOrUrl: item.thumbnailAsset,
                          fit: BoxFit.contain,
                          fallbackIcon: item.fallbackIcon,
                          fallbackIconSize: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Teks Judul & Jadwal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: AppColors.darkCharcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.scheduleText,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 11,
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
      ),
    );
  }
}

class _OtherProgramDisplayData {
  final WorkoutProgram? program;
  final String title;
  final String scheduleText;
  final String thumbnailAsset;
  final IconData fallbackIcon;

  const _OtherProgramDisplayData({
    this.program,
    required this.title,
    required this.scheduleText,
    required this.thumbnailAsset,
    required this.fallbackIcon,
  });
}
