import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Header atas Home Screen: Sapaan pengguna dan ikon notifikasi
class HomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onNotificationTap;

  const HomeHeader({
    super.key,
    this.userName = 'Adi',
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hi, $userName',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1D1E),
                    fontSize: 24,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('👋', style: TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Let's build muscle and get bigger!",
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF71767B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Notification Bell with Red Badge
        InkWell(
          onTap: onNotificationTap,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF1A1D1E),
                  size: 22,
                ),
              ),
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

