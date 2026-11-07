import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import 'onboarding_cta_button.dart';

/// Step 5 Onboarding: Your Plan Is Ready!
/// Menampilkan rekap konfigurasi starter program dan CTA "Start My Plan →".
class OnboardingPlanReadyStep extends StatelessWidget {
  final int daysPerWeek;
  final int durationMin;
  final String level;
  final String goal;
  final String startingExercise;
  final VoidCallback onStartMyPlan;
  final VoidCallback onBack;

  const OnboardingPlanReadyStep({
    super.key,
    required this.daysPerWeek,
    required this.durationMin,
    required this.level,
    required this.goal,
    this.startingExercise = 'Incline Push Up',
    required this.onStartMyPlan,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final levelText = level == 'beginner'
        ? 'Beginner level'
        : level == 'intermediate'
            ? 'Intermediate level'
            : 'Advanced level';

    final goalText = goal == 'muscle_gain'
        ? 'Build Muscle (Bulking)'
        : goal == 'strength'
            ? 'Get Stronger'
            : 'Improve Fitness';

    final durationText = durationMin <= 20
        ? '15 – 20 minutes / session'
        : durationMin <= 30
            ? '20 – 30 minutes / session'
            : '30 – 45 minutes / session';

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
            children: [
              const SizedBox(height: 10),

              // Calendar Ready Badge with Glow
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F9EA),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFB8E66B), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F65A30D),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.event_available_rounded,
                    color: Color(0xFF65A30D),
                    size: 46,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Your Plan\nIs Ready!',
                textAlign: TextAlign.center,
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1D1E),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                'A personalized no-equipment program to build muscle, get stronger, and improve your fitness at home.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF71767B),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Summary Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      icon: Icons.calendar_today_rounded,
                      text: '$daysPerWeek days / week',
                    ),
                    const Divider(height: 22, color: Color(0xFFF1F5F9)),
                    _buildSummaryRow(
                      icon: Icons.access_time_rounded,
                      text: durationText,
                    ),
                    const Divider(height: 22, color: Color(0xFFF1F5F9)),
                    _buildSummaryRow(
                      icon: Icons.signal_cellular_alt_rounded,
                      text: levelText,
                    ),
                    const Divider(height: 22, color: Color(0xFFF1F5F9)),
                    _buildSummaryRow(
                      icon: Icons.fitness_center_rounded,
                      text: goalText,
                    ),
                    const Divider(height: 22, color: Color(0xFFF1F5F9)),
                    _buildSummaryRow(
                      icon: Icons.play_circle_outline_rounded,
                      text: 'Start exercise: $startingExercise',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // CTA Button: Start My Plan → (Reusable)
              OnboardingCtaButton(
                text: 'Start My Plan',
                onPressed: onStartMyPlan,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F9EA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF65A30D), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1D1E),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

