import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Screen Animasi Pembuatan Program (Mockup Baris 2, Layar 1):
/// "Creating your personal plan..." dengan checklist bertahap 4 langkah.
class CreatingPlanScreen extends StatefulWidget {
  const CreatingPlanScreen({super.key});

  @override
  State<CreatingPlanScreen> createState() => _CreatingPlanScreenState();
}

class _CreatingPlanScreenState extends State<CreatingPlanScreen> {
  int _activeStepIndex = 0;
  Timer? _timer;

  final List<String> _steps = const [
    'Analyzing your profile',
    'Calculating training volume',
    'Selecting the best exercises',
    'Building your weekly plan',
  ];

  @override
  void initState() {
    super.initState();
    _startAnimationFlow();
  }

  void _startAnimationFlow() {
    _timer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted) return;
      if (_activeStepIndex < _steps.length) {
        setState(() => _activeStepIndex++);
      } else {
        _timer?.cancel();
        // Selesai -> Langsung navigasi ke Layar Plan Ready
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            context.pushReplacement(AppRoutes.planReady);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // Ilustrasi Dokumen & Dumbbell Lime
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F9ED),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0xFFE2EED3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.limeAccent.withOpacity(0.35),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 56,
                      color: Color(0xFF84CC16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 38),

              // Judul & Subtitle
              Center(
                child: Text(
                  'Creating your\npersonal plan...',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    height: 1.2,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Analyzing your goal, body data,\npreferences, and availability.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Checklist Animasi 4 Langkah
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.neutral200, width: 1.2),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: List.generate(_steps.length, (index) {
                    final isChecked = index < _activeStepIndex;
                    final isCurrent = index == _activeStepIndex;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isChecked
                                  ? const Color(0xFF84CC16)
                                  : (isCurrent
                                      ? const Color(0xFFF4F9ED)
                                      : const Color(0xFFF1F5F9)),
                              border: Border.all(
                                color: isChecked
                                    ? const Color(0xFF84CC16)
                                    : (isCurrent
                                        ? const Color(0xFF84CC16)
                                        : AppColors.neutral300),
                                width: 1.5,
                              ),
                            ),
                            child: isChecked
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: AppColors.darkCharcoal,
                                  )
                                : (isCurrent
                                    ? const Center(
                                        child: SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF84CC16),
                                          ),
                                        ),
                                      )
                                    : null),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _steps[index],
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: isChecked || isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13.5,
                              color: isChecked || isCurrent
                                  ? AppColors.darkCharcoal
                                  : AppColors.neutral400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

