import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';

/// Kartu "Today's Workout" dengan Dua State Cerdas:
/// 1. State Normal: Sebelum latihan (Ajakan mulai latihan hari ini)
/// 2. State Completed / Rest: Setelah latihan selesai (Apresiasi tuntas + opsi sesi berikutnya jika ada energi ekstra)
class TodaysWorkoutCard extends StatelessWidget {
  final String sessionTitle;
  final int durationMinutes;
  final int exerciseCount;
  final VoidCallback onStartWorkout;
  final String exerciseImageAsset;
  final bool isCompletedToday;
  final int todayCompletedMinutes;

  const TodaysWorkoutCard({
    super.key,
    required this.sessionTitle,
    this.durationMinutes = 25,
    this.exerciseCount = 5,
    required this.onStartWorkout,
    this.exerciseImageAsset = 'assets/images/exercises/push_up.webp',
    this.isCompletedToday = false,
    this.todayCompletedMinutes = 25,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompletedToday) {
      return _buildCompletedTodayCard(context);
    }
    return _buildActiveWorkoutCard(context);
  }

  /// 1. State Normal (Belum Latihan Hari Ini)
  Widget _buildActiveWorkoutCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.limeCardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.limeCardBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Background/Right: Foto Pose Gerakan dengan fade lembut
          Positioned(
            right: 0,
            bottom: 0,
            top: 10,
            width: 180,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Color(0x99FFFFFF), Colors.white],
                  stops: [0.0, 0.35, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                exerciseImageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.bottomRight,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tag Atas: 📅 Today's Workout
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: AppColors.greenDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Today's Workout",
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.greenDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Judul Workout
                SizedBox(
                  width: 170,
                  child: Text(
                    sessionTitle,
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.darkCharcoal,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),

                // Meta Info: ⏱ ± 20 min   🏋 3 exercises
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '± $durationMinutes min',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.fitness_center_rounded,
                      size: 13,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$exerciseCount exercises',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tombol Kompak Menggunakan AppButton.primary (Sesuai architecture.md)
                AppButton.primary(
                  text: 'Start Workout',
                  icon: Icons.play_arrow_rounded,
                  size: AppButtonSize.small,
                  isFullWidth: false,
                  onPressed: onStartWorkout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. State Completed / Rest (Latihan Hari Ini Sudah Tuntas)
  Widget _buildCompletedTodayCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Soft green tint
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Badge Status Selesai
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppBadge(
                label: 'HARI INI TUNTAS ✓',
                variant: AppBadgeVariant.success,
                fontSize: 11,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  size: 18,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Judul Apresiasi
          Text(
            'Kerja Luar Biasa Hari Ini! 🎉',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),

          // Edukasi Recovery / Pesan Coach
          Text(
            'Target latihan harianmu sudah tercapai. Otot bertumbuh saat kamu tidur & istirahat. Istirahatlah dengan baik dan penuhi kebutuhan proteinmu.',
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF4B5563),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Ringkasan Mini Selesai
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 6),
                Text(
                  'Selesai ± ${todayCompletedMinutes > 0 ? todayCompletedMinutes : durationMinutes} min',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.darkCharcoal,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 14,
                  color: const Color(0xFFCBD5E1),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.nightlight_round,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  'Fase Pemulihan',
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // Punya Energi Ekstra? (Tombol Lanjut ke Sesi Berikutnya)
          Row(
            children: [
              Expanded(
                child: Text(
                  'Punya energi ekstra? Lanjut $sessionTitle',
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              AppButton.outline(
                text: 'Lanjut ➔',
                size: AppButtonSize.small,
                isFullWidth: false,
                onPressed: () => _confirmExtraWorkout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmExtraWorkout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.bolt_rounded, color: Color(0xFFEAB308), size: 24),
            SizedBox(width: 8),
            Text(
              'Latihan Ekstra?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Kamu sudah menuntaskan latihan hari ini. Pemulihan otot sangat penting, namun jika kamu merasa bugar dan berenergi, kamu bisa lanjut ke sesi $sessionTitle.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal & Istirahat'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.limeAccent,
              foregroundColor: AppColors.darkCharcoal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onStartWorkout();
            },
            child: const Text(
              'Tetap Lanjut',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
