import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_widgets.dart';

/// Screen 8 Mockup: Help & About (Light & Dark Mode)
class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});

  void _showInfoDialog(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            content,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Tutup',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isDark ? colorScheme.primary : AppColors.greenBrand,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Help & About',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get support and app information.',
                style: AppTypography.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              _HelpActionRow(
                icon: Icons.help_outline_rounded,
                title: 'Help Center',
                subtitle: 'FAQs and how to use the app',
                onTap: () => _showInfoDialog(
                  context,
                  'Help Center',
                  'Selamat datang di Pusat Bantuan Home Bulking Coach!\n\n1. Mulai latihan dari tab Home atau Plans.\n2. Catat asupan makanan di menu Nutrisi.\n3. Pantau kenaikan massa otot & berat badan mingguan di tab Progress.',
                ),
              ),
              const SizedBox(height: 12),
              _HelpActionRow(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Send Feedback',
                subtitle: 'Tell us what you think',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Terima kasih! Umpan balik Anda sangat berarti untuk pengembangan aplikasi.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _HelpActionRow(
                icon: Icons.star_outline_rounded,
                title: 'Rate the App',
                subtitle: 'Support us on the store',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Terima kasih atas rating bintang 5 Anda! ⭐⭐⭐⭐⭐',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _HelpActionRow(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'App version, terms, and privacy',
                trailingText: 'v1.0.0',
                onTap: () => _showInfoDialog(
                  context,
                  'About Home Bulking Coach',
                  'Home Bulking Coach v1.0.0 (Release)\n\nAplikasi latihan beban tubuh di rumah terstruktur 30 hari untuk hipertrofi & kekuatan otot.\n\n© 2026 Home Bulking Coach. Hak cipta dilindungi undang-undang.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  const _HelpActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onTap,
      variant: AppCardVariant.flat,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colorScheme.onSurface),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailingText != null) ...[
            Text(
              trailingText!,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}
