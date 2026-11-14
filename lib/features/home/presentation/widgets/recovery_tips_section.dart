import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Shared, fully tappable recovery actions used by both Rest Day and Completed states.
class RecoveryTipsSection extends StatelessWidget {
  final VoidCallback onHydrationTap;
  final VoidCallback onSleepTap;
  final VoidCallback onStretchingTap;

  const RecoveryTipsSection({
    super.key,
    required this.onHydrationTap,
    required this.onSleepTap,
    required this.onStretchingTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.home.restDay.recoveryTips,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 15.5,
            color: AppColors.darkCharcoal,
          ),
        ),
        const SizedBox(height: 10),
        _RecoveryTipTile(
          icon: Icons.water_drop_rounded,
          title: t.home.restDay.hydrate,
          onTap: onHydrationTap,
        ),
        const SizedBox(height: 9),
        _RecoveryTipTile(
          icon: Icons.bedtime_rounded,
          title: t.home.restDay.sleep,
          onTap: onSleepTap,
        ),
        const SizedBox(height: 9),
        _RecoveryTipTile(
          icon: Icons.self_improvement_rounded,
          title: t.home.restDay.stretch,
          onTap: onStretchingTap,
        ),
      ],
    );
  }
}

class _RecoveryTipTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _RecoveryTipTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F3F5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(icon, color: const Color(0xFF65A30D), size: 24),
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
            ),
          ),
        ),
      ),
    );
  }
}
