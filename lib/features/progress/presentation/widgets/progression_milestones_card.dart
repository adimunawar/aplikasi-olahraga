import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/progression_milestone.dart';

/// Card Pencapaian Tangga Gerakan & Riwayat Adaptasi Coach Adi (Fase 5)
class ProgressionMilestonesCard extends StatelessWidget {
  final List<ProgressionMilestone> milestones;

  const ProgressionMilestonesCard({
    super.key,
    required this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris 1: Icon Otak/Grafik + Judul
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pencapaian Tangga Gerakan',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Riwayat evaluasi adaptasi dari Coach Adi',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (milestones.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.neutral500, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Selesaikan latihan dan catat RIR agar Coach Adi dapat mengevaluasi kenaikan tangga gerakanmu.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...milestones.take(4).map((m) => _buildMilestoneTile(m)),
        ],
      ),
    );
  }

  Widget _buildMilestoneTile(ProgressionMilestone m) {
    Color badgeBg;
    Color badgeText;
    IconData badgeIcon;
    String badgeLabel;

    switch (m.decision.toLowerCase().trim()) {
      case 'progress':
        badgeBg = const Color(0xFFE8F9D7);
        badgeText = const Color(0xFF16A34A);
        badgeIcon = Icons.trending_up_rounded;
        badgeLabel = m.nextExerciseId != null ? 'Naik Variasi' : 'Naik Target';
        break;
      case 'regress':
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFFB45309);
        badgeIcon = Icons.tune_rounded;
        badgeLabel = 'Sesuaikan';
        break;
      case 'recover':
        badgeBg = const Color(0xFFFFEDD5);
        badgeText = const Color(0xFFC2410C);
        badgeIcon = Icons.healing_rounded;
        badgeLabel = 'Deload Aktif';
        break;
      default:
        badgeBg = const Color(0xFFEBF5FF);
        badgeText = const Color(0xFF1D4ED8);
        badgeIcon = Icons.check_circle_rounded;
        badgeLabel = 'Matangkan';
        break;
    }

    final dateStr = '${m.date.day}/${m.date.month}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        m.exerciseNameFormatted,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkCharcoal,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (m.nextExerciseNameFormatted != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF16A34A)),
                      ),
                      Flexible(
                        child: Text(
                          m.nextExerciseNameFormatted!,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF16A34A),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: badgeText, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      badgeLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: badgeText,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            m.reason,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral700,
              fontSize: 11,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

