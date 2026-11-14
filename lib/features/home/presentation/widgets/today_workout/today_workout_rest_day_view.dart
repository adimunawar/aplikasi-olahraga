import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../i18n/strings.g.dart';

/// Tampilan Rest Day (Hari Istirahat) pada Home Screen (Mockup 1:1)
class TodayWorkoutRestDayView extends StatelessWidget {
  const TodayWorkoutRestDayView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Rest Day Hero (Langsung di atas kanvas tanpa card putih luar)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Sofa Icon Container (Soft lime organic circle with 2D styled sofa)
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1FADC),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft glow
                        Container(
                          width: 48,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF84CC16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Sofa Outline & Cushion
                        const Icon(
                          Icons.weekend_rounded,
                          color: Color(0xFF84CC16),
                          size: 38,
                        ),
                        const Icon(
                          Icons.weekend_outlined,
                          color: AppColors.darkCharcoal,
                          size: 38,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Title: Today is a Rest Day
                Text(
                  t.home.restDay.title,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    color: AppColors.darkCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // Subtitle: Time to recover, let your muscles repair and grow.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    t.home.restDay.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // B. Recovery Tips Section
          Text(
            t.home.restDay.recoveryTips,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 10),

          // Tile 1: Stay Hydrated (Water drop filled with lime + dark outline)
          _buildRecoveryTipTile(
            icon: Stack(
              alignment: Alignment.center,
              children: const [
                Icon(
                  Icons.water_drop_rounded,
                  color: Color(0xFFC7F135),
                  size: 24,
                ),
                Icon(
                  Icons.water_drop_outlined,
                  color: AppColors.darkCharcoal,
                  size: 24,
                ),
              ],
            ),
            title: t.home.restDay.hydrate,
          ),
          const SizedBox(height: 9),

          // Tile 2: Sleep 7-9 hours (Bed filled with lime + dark outline)
          _buildRecoveryTipTile(
            icon: Stack(
              alignment: Alignment.center,
              children: const [
                Icon(
                  Icons.bed_rounded,
                  color: Color(0xFF84CC16),
                  size: 24,
                ),
                Icon(
                  Icons.bed_outlined,
                  color: AppColors.darkCharcoal,
                  size: 24,
                ),
              ],
            ),
            title: t.home.restDay.sleep,
          ),
          const SizedBox(height: 9),

          // Tile 3: Stretching or mobility (Yoga figure filled with lime + dark outline)
          _buildRecoveryTipTile(
            icon: Stack(
              alignment: Alignment.center,
              children: const [
                Icon(
                  Icons.self_improvement_rounded,
                  color: Color(0xFF84CC16),
                  size: 26,
                ),
                Icon(
                  Icons.self_improvement_outlined,
                  color: AppColors.darkCharcoal,
                  size: 26,
                ),
              ],
            ),
            title: t.home.restDay.stretch,
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryTipTile({
    required Widget icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F3F5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Center(child: icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: AppColors.darkCharcoal,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.darkCharcoal,
          ),
        ],
      ),
    );
  }
}
