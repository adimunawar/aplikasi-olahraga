import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import 'onboarding_cta_button.dart';
import 'onboarding_dots_indicator.dart';

/// Step 4 Onboarding: Your Schedule
/// - Pilihan frekuensi: 2, 3, 4, 5 days / week
/// - Pilihan durasi: 15-20 min, 20-30 min, 30-45 min
class OnboardingScheduleStep extends StatelessWidget {
  final int selectedDays;
  final int selectedDurationMin;
  final ValueChanged<int> onDaysSelected;
  final ValueChanged<int> onDurationSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingScheduleStep({
    super.key,
    required this.selectedDays,
    required this.selectedDurationMin,
    required this.onDaysSelected,
    required this.onDurationSelected,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Your Schedule',
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1D1E),
                ),
              ),
              const SizedBox(height: 20),

              // Subheader 1
              Text(
                'How often can you train per week?',
                style: AppTypography.labelLarge.copyWith(
                  color: const Color(0xFF1A1D1E),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Days options: 2, 3, 4, 5
              for (final d in [2, 3, 4, 5]) ...[
                _buildSchedulePill(
                  label: '$d days / week',
                  isSelected: selectedDays == d,
                  onTap: () => onDaysSelected(d),
                ),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 20),

              // Subheader 2
              Text(
                'How long per session?',
                style: AppTypography.labelLarge.copyWith(
                  color: const Color(0xFF1A1D1E),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Duration options: 20, 30, 45
              _buildDurationPill(
                label: '15 – 20 minutes',
                durationMin: 20,
                isSelected: selectedDurationMin == 20,
                onTap: () => onDurationSelected(20),
              ),
              const SizedBox(height: 10),
              _buildDurationPill(
                label: '20 – 30 minutes',
                durationMin: 30,
                isSelected: selectedDurationMin == 30,
                onTap: () => onDurationSelected(30),
              ),
              const SizedBox(height: 10),
              _buildDurationPill(
                label: '30 – 45 minutes',
                durationMin: 45,
                isSelected: selectedDurationMin == 45,
                onTap: () => onDurationSelected(45),
              ),

              const SizedBox(height: 28),

              // Dots Indicator (Step 4: Index 2 dari 5)
              const OnboardingDotsIndicator(activeIndex: 2, totalDots: 5),
              const SizedBox(height: 16),

              // CTA Button: Next → (Reusable)
              OnboardingCtaButton(
                text: 'Next',
                onPressed: onNext,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchedulePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F9EA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFB8E66B) : const Color(0xFFE9ECEF),
            width: isSelected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1D1E),
                fontSize: 14,
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF65A30D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationPill({
    required String label,
    required int durationMin,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F9EA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFB8E66B) : const Color(0xFFE9ECEF),
            width: isSelected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: isSelected ? const Color(0xFF65A30D) : const Color(0xFF71767B),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1D1E),
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF65A30D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
              ),
          ],
        ),
      ),
    );
  }
}

