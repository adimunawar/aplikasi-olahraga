import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

import 'user_avatar.dart';

/// Header Sapaan Pengguna & Notifikasi (Mockup 1:1)
class HomeGreetingHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool hasUnreadNotification;

  const HomeGreetingHeader({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.onNotificationTap,
    this.onProfileTap,
    this.hasUnreadNotification = true,
  });

  String _getGreetingText(Translations t) {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return t.home.greeting.goodMorning(name: userName);
    } else if (hour >= 12 && hour < 17) {
      return t.home.greeting.goodAfternoon(name: userName);
    } else {
      return t.home.greeting.goodEvening(name: userName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // 1. Avatar Pengguna dengan Fallback Inisial Nama (Phase C Point 1)
          UserAvatar(
            displayName: userName,
            avatarUrl: avatarUrl,
            radius: 23,
            onTap: onProfileTap,
          ),
          const SizedBox(width: 12),

          // 2. Greeting Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreetingText(t),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  t.home.greeting.subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 3. Notification Bell Icon with Badge
          InkWell(
            onTap: onNotificationTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 22,
                  ),
                  if (hasUnreadNotification)
                    Positioned(
                      top: 10,
                      right: 11,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.vibrantCoral,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
