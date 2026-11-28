import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../../../../i18n/strings.g.dart';

/// Step 0: Welcome Screen Content (Mockup 1:1 Visual Match)
class StepWelcome extends StatelessWidget {
  const StepWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.welcome;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final accentColor = isDark ? colorScheme.primary : const Color(0xFF84CC16);
    final canvasColor = theme.scaffoldBackgroundColor;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //tod: logo will be here
          const SizedBox(height: 12),

          // 2. Hero Coach Image dengan Soft Lime Organic Card Background
          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.46,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Latar Belakang Kartu Hijau Limau Halus dengan Sudut Melengkung
                  Positioned.fill(
                    top: 24,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  colorScheme.primaryContainer,
                                  colorScheme.surfaceContainerHighest,
                                  colorScheme.primaryContainer,
                                ]
                              : const [
                                  Color(0xFFE8F7CD),
                                  Color(0xFFF4FDE5),
                                  Color(0xFFE2F5BE),
                                ],
                        ),
                      ),
                    ),
                  ),

                  // Hero Coach Image
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const AppSmartImage(
                        imagePathOrUrl: 'assets/images/man-half-body.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Soft Fade Gradient di bagian bawah agar menyatu mulus ke kanvas
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            canvasColor.withValues(alpha: 0.0),
                            canvasColor.withValues(alpha: 0.8),
                            canvasColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Judul 2 Warna: Baris 1 & Baris 2 (Lime Green) sesuai Locale
          Builder(
            builder: (context) {
              final titleParts = t.title.split('\n');
              final firstLine = titleParts.isNotEmpty
                  ? titleParts.first
                  : t.title;
              final secondLine = titleParts.length > 1
                  ? titleParts.sublist(1).join('\n')
                  : '';

              return Text.rich(
                TextSpan(
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                  children: [
                    TextSpan(
                      text: '$firstLine\n',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    if (secondLine.isNotEmpty)
                      TextSpan(
                        text: secondLine,
                        style: TextStyle(color: accentColor),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // 4. Subtitle Deskripsi
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF475569),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
