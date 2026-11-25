import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';

/// Card Identitas Pengguna pada Halaman Profile (Light & Dark Mode).
class UserIdentityHeroCard extends StatelessWidget {
  final String name;
  final String status;
  final VoidCallback? onEdit;

  const UserIdentityHeroCard({
    super.key,
    this.name = 'Adi Munawar',
    this.status = 'Bulking journey • Beginner',
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final pillBg = isDark
        ? colorScheme.primaryContainer
        : AppColors.limeCardSurface;
    final pillFg = isDark
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return AppCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/coach_hero.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, _, _) => Image.asset(
                  'assets/images/coach_character.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status,
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 14, color: pillFg),
                        const SizedBox(width: 6),
                        Text(
                          'Edit Profile',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: pillFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
