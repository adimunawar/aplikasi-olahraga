import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import 'onboarding_cta_button.dart';
import 'onboarding_dots_indicator.dart';

/// Step 1 Onboarding: Welcome Screen
/// Direplikasi 1:1 presis sesuai mockup referensi:
/// - Top Bar: Logo (Icon rumah H + teks "Home Bulking Coach") di kiri & Slogan tulisan tangan "Better Stronger You" di kanan.
/// - Background: Ruangan sunlit living room + pita poligon geometris lime-green dinamis di latar belakang.
/// - Coach Karakter: Pose menunjuk ke depan, terpusat proporsional, dengan gradien fade halus ke putih di bagian pinggang/kaki.
/// - Konten Depan: Menggunakan SafeArea + Column + Spacer terstruktur (anti-overflow & anti-tabrakan).
/// - Tipografi Utama: "Build", "Strength" (hijau lime), "at Home." dalam gaya Bold Italic tegas.
/// - Subtitle: "Your journey to a stronger\nbody starts with a simple plan."
/// - Page Indicator: 3 titik di tengah (titik pertama hijau aktif).
/// - Tombol: "Get Started →" kapsul hijau lime penuh di bagian bawah.
class OnboardingWelcomeStep extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  const OnboardingWelcomeStep({
    super.key,
    required this.onGetStarted,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // -------------------------------------------------------------
          // 1. LAYER BACKGROUND FOTO RUANGAN (MEMENUHI SELURUH LAYAR)
          // -------------------------------------------------------------
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_bg.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) =>
                  Container(color: const Color(0xFFF4F6F2)),
            ),
          ),

          // -------------------------------------------------------------
          // 2. LAYER PITA POLIGON HIJAU LIME GEOMETRIS
          // -------------------------------------------------------------
          Positioned.fill(
            child: CustomPaint(painter: _DynamicLimeRibbonsPainter()),
          ),

          // -------------------------------------------------------------
          // 3. LAYER COACH KARAKTER (MENUNJUK KE DEPAN)
          // Diposisikan lebih ke bawah agar pinggangnya berada pas di balik teks
          // -------------------------------------------------------------
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).padding.top + 80,
            bottom: MediaQuery.of(context).size.height * 0.16,
            child: Image.asset(
              'assets/images/coach_pointing.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, _, _) => Image.asset(
                'assets/images/coach_character.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),

          // -------------------------------------------------------------
          // 4. LAYER GRADASI PUTIH TEBAL & PEKAT KE BAWAH
          // Dimulai dari atas kata "Build" ke bawah dengan warna putih pekat (100% solid)
          // sehingga potongan badan coach (buntung) tertutup sempurna & teks terbaca sangat jelas.
          // -------------------------------------------------------------
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.54,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00FFFFFF), // 0% transparan di atas judul
                    Color(0x80FFFFFF), // 50% putih transisi
                    Color(0xE6FFFFFF), // 90% putih tebal
                    Colors.white, // 100% solid putih pekat (menutup badan buntung)
                    Colors.white, // 100% solid putih pekat sampai dasar layar
                  ],
                  stops: [0.0, 0.22, 0.42, 0.60, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------
          // 5. LAYER KONTEN UTAMA (STRUKTUR ANTI-TABRAKAN)
          // Menggunakan SafeArea -> Column -> Spacer -> Bottom Content
          // -------------------------------------------------------------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TOP BAR: Logo di kiri, Slogan di kanan ---
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo Hexagon Rumah + "Home Bulking Coach"
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Home Bulking',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: const Color(0xFF141718),
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'Coach',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: const Color(0xFF65A30D),
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Slogan Tulisan Tangan "Better Stronger You" di Kanan
                      GestureDetector(
                        onTap: onSkip,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Better',
                              style: AppTypography.sloganText(fontSize: 17),
                            ),
                            Text(
                              'Stronger',
                              style: AppTypography.sloganText(fontSize: 18),
                            ),
                            Text(
                              'You',
                              style: AppTypography.sloganText(fontSize: 18),
                            ),
                            Container(
                              width: 32,
                              height: 1.5,
                              margin: const EdgeInsets.only(top: 2),
                              color: const Color(0xFF1E2522),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Spacer dinamis: Menjaga ruang tengah dan mendorong konten teks selalu rapi di bawah
                  const Spacer(),

                  // --- BOTTOM CONTENT: Title, Subtitle, Dots, & Button ---
                  // 1. Title Bold Italic
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Build\n',
                          style: AppTypography.onboardingTitleDisplay(),
                        ),
                        TextSpan(
                          text: 'Strength\n',
                          style: AppTypography.onboardingTitleDisplay(
                            color: const Color(0xFF7CB818),
                          ),
                        ),
                        TextSpan(
                          text: 'at Home.',
                          style: AppTypography.onboardingTitleDisplay(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Subtitle 2 Baris
                  Text(
                    'Your journey to a stronger\nbody starts with a simple plan.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF71767B),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Dots Indicator (Tengah - Reusable)
                  const OnboardingDotsIndicator(activeIndex: 0),
                  const SizedBox(height: 16),

                  // 4. CTA Button: "Get Started →" (Reusable)
                  OnboardingCtaButton(
                    text: 'Get Started',
                    onPressed: onGetStarted,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter untuk pita geometris hijau lime di latar belakang
class _DynamicLimeRibbonsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final limePaint = Paint()
      ..color = const Color(0x66BFEA48)
      ..style = PaintingStyle.fill;

    final limePaintSoft = Paint()
      ..color = const Color(0x4DBFEA48)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Pita Kiri Tengah (Melintang dari tepi kiri miring ke bawah)
    final leftRibbon = Path()
      ..moveTo(0, h * 0.44)
      ..lineTo(w * 0.45, h * 0.32)
      ..lineTo(w * 0.40, h * 0.42)
      ..lineTo(0, h * 0.54)
      ..close();
    canvas.drawPath(leftRibbon, limePaint);

    // 2. Pita Kanan Atas (Melintang dari tepi kanan miring ke arah Coach)
    final rightRibbon = Path()
      ..moveTo(w, h * 0.14)
      ..lineTo(w * 0.60, h * 0.34)
      ..lineTo(w * 0.64, h * 0.40)
      ..lineTo(w, h * 0.24)
      ..close();
    canvas.drawPath(rightRibbon, limePaintSoft);

    // 3. Pita Kanan Bawah
    final bottomRibbon = Path()
      ..moveTo(w * 0.65, h * 0.88)
      ..lineTo(w, h * 0.72)
      ..lineTo(w, h * 0.82)
      ..lineTo(w * 0.75, h * 0.94)
      ..close();
    canvas.drawPath(bottomRibbon, limePaintSoft);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
