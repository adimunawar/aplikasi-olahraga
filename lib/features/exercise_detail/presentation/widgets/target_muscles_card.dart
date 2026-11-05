import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workout_detail/presentation/widgets/muscle_anatomy_viewer.dart';

/// Card diagram "Target Muscles":
/// Menampilkan diagram anatomi tubuh resolusi tinggi berbasis PNG layer transparan
/// dengan legend otot utama & sekunder, serta dialog pembesar interaktif saat diklik.
class TargetMusclesCard extends StatelessWidget {
  final String primaryMuscles;
  final String secondaryMuscles;

  const TargetMusclesCard({
    super.key,
    required this.primaryMuscles,
    required this.secondaryMuscles,
  });

  List<String> get _combinedMuscles {
    final list = <String>[];
    if (primaryMuscles.isNotEmpty) {
      list.addAll(primaryMuscles.split(RegExp(r'[,•/|]')).map((s) => s.trim()));
    }
    if (secondaryMuscles.isNotEmpty) {
      list.addAll(secondaryMuscles.split(RegExp(r'[,•/|]')).map((s) => s.trim()));
    }
    return list.where((s) => s.isNotEmpty).toList();
  }

  void _showFullAnatomyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                MuscleAnatomyViewer(
                  targetMuscles: _combinedMuscles.isNotEmpty ? _combinedMuscles : ['Chest'],
                  height: 320,
                  showViewToggle: true,
                  isCard: false,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final muscles = _combinedMuscles.isNotEmpty ? _combinedMuscles : ['Chest'];

    return GestureDetector(
      onTap: () => _showFullAnatomyModal(context),
      child: Container(
        height: 155,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Target Muscles',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                const Icon(
                  Icons.fullscreen_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // High-Resolution Layered Anatomy Illustration
            Expanded(
              child: Center(
                child: MuscleAnatomyViewer(
                  targetMuscles: muscles,
                  height: 82,
                  showViewToggle: false,
                  showChips: false,
                  isCard: false,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Muscle Legends
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.greenDark, // Primary Lime Green Accent
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Utama: ${primaryMuscles.isNotEmpty ? primaryMuscles : "Dada"}',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCBD5E1), // Secondary Soft Gray Accent
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Sekunder: ${secondaryMuscles.isNotEmpty ? secondaryMuscles : "Triceps, Bahu"}',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
