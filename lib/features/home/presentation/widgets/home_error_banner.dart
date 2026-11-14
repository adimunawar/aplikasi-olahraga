import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';

/// Banner Peringatan Gangguan Koneksi / Offline Cache (Mockup 1:1)
class HomeErrorBanner extends StatelessWidget {
  final String lastSyncedTime;
  final VoidCallback onRetry;

  const HomeErrorBanner({
    super.key,
    required this.lastSyncedTime,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE047), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 20,
                color: Color(0xFFB45309),
              ),
              const SizedBox(width: 8),
              Text(
                t.home.error.connectionIssue,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: const Color(0xFF78350F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t.home.error.connectionDesc,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF92400E),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.home.error.lastSynced(time: lastSyncedTime),
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFFB45309),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    t.home.error.retry,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF15803D),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
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
