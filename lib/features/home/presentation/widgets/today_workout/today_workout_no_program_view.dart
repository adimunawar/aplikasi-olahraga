import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../i18n/strings.g.dart';

/// Tampilan Empty State ketika belum ada Program Latihan (Mockup 1:1)
class TodayWorkoutNoProgramView extends StatelessWidget {
  final VoidCallback onCreateProgram;

  const TodayWorkoutNoProgramView({
    super.key,
    required this.onCreateProgram,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.neutral200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFF4FBEB),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD4EBA8), width: 1.2),
              ),
              child: const Center(
                child: Icon(
                  Icons.assignment_outlined,
                  color: Color(0xFF65A30D),
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.home.noProgram.title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: AppColors.darkCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              t.home.noProgram.subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutral500,
                fontSize: 12.5,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onCreateProgram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF84CC16),
                  foregroundColor: AppColors.darkCharcoal,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  t.home.noProgram.createProgram,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
