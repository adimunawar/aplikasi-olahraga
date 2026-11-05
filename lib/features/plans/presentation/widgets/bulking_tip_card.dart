import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Card Edukasi "Tip for Bulking" di bagian bawah Tab Program
class BulkingTipCard extends StatelessWidget {
  const BulkingTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F9EA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EED0), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Dumbbell bulat hijau
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFC7F135),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Color(0xFF141718),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Teks Tip
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip for Bulking',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: const Color(0xFF141718),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Be consistent, eat enough protein, and focus on progressive overload.',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF52525B),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Info icon
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF71717A),
            size: 20,
          ),
        ],
      ),
    );
  }
}

