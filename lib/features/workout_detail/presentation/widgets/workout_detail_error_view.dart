import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';

/// Error state for Workout Detail when workout data fails to load.
class WorkoutDetailErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const WorkoutDetailErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = Translations.of(context);
    final isId = t.$meta.locale == AppLocale.id;
    final title = isId
        ? 'Gagal memuat detail latihan'
        : 'Workout detail could not be loaded';
    final subtitle = isId
        ? 'Periksa koneksi Anda dan coba lagi.'
        : 'Check your connection and try again.';

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF450A0A)
                      : const Color(0xFFFFF1F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 30,
                  color: isDark
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                text: t.workouts.errorState.retry,
                onPressed: onRetry,
                isFullWidth: false,
                width: 160,
                size: AppButtonSize.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
