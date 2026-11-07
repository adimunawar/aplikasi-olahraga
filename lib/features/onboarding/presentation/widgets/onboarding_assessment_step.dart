import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import 'onboarding_cta_button.dart';
import 'onboarding_dots_indicator.dart';

/// Step Onboarding: Initial Baseline Assessment (Sesuai PRD Baru P0)
/// Menentukan titik awal tangga progresi latihan dorong (Incline -> Knee -> Push Up)
class OnboardingAssessmentStep extends StatelessWidget {
  final String selectedCapability;
  final ValueChanged<String> onCapabilitySelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingAssessmentStep({
    super.key,
    required this.selectedCapability,
    required this.onCapabilitySelected,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D1E)),
          onPressed: onBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Initial\nAssessment',
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1D1E),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Berapa banyak Push Up penuh yang bisa kamu lakukan saat ini tanpa berhenti?',
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF71767B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),

              // Option 1: 0 reps
              _buildAssessmentCard(
                id: 'zero',
                title: 'Belum Bisa (0 reps)',
                startingExercise: 'Mulai dari: Incline Push Up (Tumpuan Meja)',
                description: 'Sangat wajar bagi pemula. Kita mulai dari tumpuan tinggi agar otot dada terbiasa tanpa beban berat.',
                icon: Icons.chair_alt_rounded,
                isSelected: selectedCapability == 'zero',
              ),
              const SizedBox(height: 14),

              // Option 2: 1 - 5 reps
              _buildAssessmentCard(
                id: 'few',
                title: 'Mulai Bisa (1 – 5 reps)',
                startingExercise: 'Mulai dari: Knee Push Up (Tumpuan Lutut)',
                description: 'Fondasi ototmu sudah mulai terbentuk. Knee push up akan melipatgandakan repetisimu dengan aman.',
                icon: Icons.fitness_center_rounded,
                isSelected: selectedCapability == 'few',
              ),
              const SizedBox(height: 14),

              // Option 3: 6+ reps
              _buildAssessmentCard(
                id: 'solid',
                title: 'Sudah Kuat (6 – 12+ reps)',
                startingExercise: 'Mulai dari: Standard Push Up',
                description: 'Hebat! Kamu siap langsung mengeksekusi push up penuh di lantai dan meningkatkan daya tahan otot.',
                icon: Icons.bolt_rounded,
                isSelected: selectedCapability == 'solid',
              ),

              const Spacer(),
              const OnboardingDotsIndicator(activeIndex: 4, totalDots: 5),
              const SizedBox(height: 16),
              OnboardingCtaButton(
                text: 'Generate My Plan',
                onPressed: onNext,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentCard({
    required String id,
    required String title,
    required String startingExercise,
    required String description,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onCapabilitySelected(id),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F9EA) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFB8E66B) : const Color(0xFFE9ECEF),
            width: isSelected ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0x1265A30D) : const Color(0x04000000),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD4F19B) : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF33691E) : const Color(0xFF6B7280),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: const Color(0xFF1A1D1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE2F4C4) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      startingExercise,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? const Color(0xFF2E690B) : const Color(0xFF4B5563),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF71767B),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

