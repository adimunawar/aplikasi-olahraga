import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Screen 8 Mockup: Help & About
/// - Help Center (FAQs & guide)
/// - Send Feedback
/// - Rate the App
/// - About (v1.0.0, terms, privacy)
class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: const Color(0xFF141718),
            ),
          ),
          content: Text(
            content,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.greenBrand,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF141718),
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Help & About',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF141718),
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
                  color: AppColors.neutral500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Help Center
              _buildActionRow(
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

              // 2. Send Feedback
              _buildActionRow(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Send Feedback',
                subtitle: 'Tell us what you think',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Terima kasih! Umpan balik Anda sangat berarti untuk pengembangan aplikasi.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.darkCharcoal,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // 3. Rate the App
              _buildActionRow(
                icon: Icons.star_outline_rounded,
                title: 'Rate the App',
                subtitle: 'Support us on the store',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terima kasih atas rating bintang 5 Anda! ⭐⭐⭐⭐⭐'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.darkCharcoal,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // 4. About
              _buildActionRow(
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

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF141718)),
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
                      color: const Color(0xFF141718),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

