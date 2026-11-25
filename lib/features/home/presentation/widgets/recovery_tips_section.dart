import 'package:material_ui/material_ui.dart';

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
            color: Theme.of(context).colorScheme.onSurface,
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow
                  .withValues(alpha: 0.02),
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
                    child: Icon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
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
