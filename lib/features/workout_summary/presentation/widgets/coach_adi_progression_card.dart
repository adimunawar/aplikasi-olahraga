import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../progression/domain/models/progression_models.dart';

/// Card Evaluasi Adaptif Coach Adi (Fase 4: Progression Engine UI)
/// Menampilkan hasil keputusan objektif dan transparan per gerakan latihan
class CoachAdiProgressionCard extends StatelessWidget {
  final List<ProgressionDecision> decisions;

  const CoachAdiProgressionCard({
    super.key,
    required this.decisions,
  });

  String _formatExerciseName(String id) {
    return id
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon Otak Coach + Judul + Subtitle
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Evaluasi Coach Adi',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: const Color(0xFF141718),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F9D7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'AI Adaptif',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF22C55E),
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rekomendasi beban & repetisi sesi berikutnya',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF6C7278),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F3F5)),
          const SizedBox(height: 14),

          // Daftar Keputusan Per Gerakan
          if (decisions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF6C7278), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Selesaikan latihan dengan mencatat repetisi & RIR untuk mendapatkan evaluasi adaptif personal dari Coach Adi.',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF6C7278),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...decisions.map((decision) => _buildDecisionItem(decision)),
        ],
      ),
    );
  }

  Widget _buildDecisionItem(ProgressionDecision decision) {
    Color badgeBg;
    Color badgeText;
    IconData badgeIcon;
    String badgeLabel;

    switch (decision.action) {
      case ProgressionAction.progress:
        badgeBg = const Color(0xFFE8F9D7);
        badgeText = const Color(0xFF16A34A);
        badgeIcon = Icons.trending_up_rounded;
        badgeLabel = decision.suggestedExerciseId != null
            ? 'Naik Kelas Variasi'
            : 'Tingkatkan Target';
        break;
      case ProgressionAction.maintain:
        badgeBg = const Color(0xFFEBF5FF);
        badgeText = const Color(0xFF1D4ED8);
        badgeIcon = Icons.task_alt_rounded;
        badgeLabel = 'Pertahankan Ritme';
        break;
      case ProgressionAction.regress:
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFFB45309);
        badgeIcon = Icons.tune_rounded;
        badgeLabel = 'Sesuaikan Variasi';
        break;
      case ProgressionAction.recover:
        badgeBg = const Color(0xFFFFEDD5);
        badgeText = const Color(0xFFC2410C);
        badgeIcon = Icons.healing_rounded;
        badgeLabel = 'Pemulihan / Deload';
        break;
      case ProgressionAction.reassess:
        badgeBg = const Color(0xFFF3E8FF);
        badgeText = const Color(0xFF7E22CE);
        badgeIcon = Icons.sync_rounded;
        badgeLabel = 'Evaluasi Ulang';
        break;
    }

    final p = decision.nextPrescription;
    final nextTargetText = decision.suggestedExerciseId != null
        ? 'Variasi baru: ${_formatExerciseName(decision.suggestedExerciseId!)} (${p.minReps}-${p.maxReps} reps)'
        : '${p.targetSets} sets × ${p.minReps}-${p.maxReps} reps (RIR ${p.targetRir})';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Nama Gerakan & Badge Aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _formatExerciseName(decision.exerciseId),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF141718),
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: badgeText, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: badgeText,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Baris 2: Bubble Alasan Coach Adi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFECEFF1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.format_quote_rounded,
                    color: Color(0xFF22C55E),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    decision.reason,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF343A40),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Baris 3: Next Target Preview
          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                color: Color(0xFF6C7278),
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Target sesi depan: $nextTargetText',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF6C7278),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
