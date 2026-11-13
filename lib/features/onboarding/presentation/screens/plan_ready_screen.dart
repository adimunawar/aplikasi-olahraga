import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_smart_image.dart';

/// Screen "Your plan is ready! 🎉" (Mockup Baris 2, Layar 2)
class PlanReadyScreen extends StatefulWidget {
  const PlanReadyScreen({super.key});

  @override
  State<PlanReadyScreen> createState() => _PlanReadyScreenState();
}

class _PlanReadyScreenState extends State<PlanReadyScreen> {
  UserProfileEntity? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await AppDatabase.instance.getUserProfile();
    if (mounted) setState(() => _profile = p);
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    final isBulking = p?.goal.contains('muscle') == true;
    final isCutting = p?.goal.contains('fat_loss') == true;

    final programTitle = isBulking
        ? 'Bulking Program'
        : (isCutting ? 'Fat Loss & Conditioning' : 'Maintain & Stay Fit');
    final programSubtitle = isBulking
        ? 'Muscle Gain & Strength'
        : (isCutting ? 'Fat Loss & Tone' : 'Strength & General Fitness');

    final freq = p?.weeklyFrequency ?? 4;
    final dur = p?.preferredDurationMin ?? 45;
    final level = p?.experienceLevel.toUpperCase() ?? 'BEGINNER';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Icon Checklist Hijau Berpendar di Atas
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 30,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Your plan is ready! 🎉',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: AppColors.darkCharcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'A personalized program based on\nyour goal, profile, and preferences.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 13,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Program Hero Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.neutral200, width: 1.2),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar Coach
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFF4F9ED),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: const AppSmartImage(
                              imagePathOrUrl: 'assets/images/coach_flex.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Judul & Badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                programTitle,
                                style: AppTypography.headlineSmall.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                programSubtitle,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.neutral500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const AppBadge(
                                label: '⭐ 12 Weeks',
                                variant: AppBadgeVariant.limeAccent,
                                fontSize: 11,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.neutral200),
                    const SizedBox(height: 14),

                    // Meta Row: Days / Week | Min / Session | Level
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetaItem(
                          icon: Icons.calendar_today_rounded,
                          topText: '$freq',
                          bottomText: 'Days / Week',
                        ),
                        Container(width: 1, height: 28, color: AppColors.neutral200),
                        _buildMetaItem(
                          icon: Icons.access_time_rounded,
                          topText: '$dur',
                          bottomText: 'Minutes / Session',
                        ),
                        Container(width: 1, height: 28, color: AppColors.neutral200),
                        _buildMetaItem(
                          icon: Icons.fitness_center_rounded,
                          topText: level,
                          bottomText: 'Level',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Checklist Fitur Program
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: const [
                    _FeatureItem(text: 'Build muscle and increase body weight'),
                    SizedBox(height: 8),
                    _FeatureItem(text: 'Progressive overload (gradual increase)'),
                    SizedBox(height: 8),
                    _FeatureItem(text: 'Designed for home training'),
                    SizedBox(height: 8),
                    _FeatureItem(text: 'Adapted to your schedule and equipment'),
                  ],
                ),
              ),

              const Spacer(),

              // Tombol View My Plan (Tetap di dalam flow Onboarding)
              AppButton.primary(
                text: 'View My Plan',
                size: AppButtonSize.large,
                onPressed: () {
                  context.push(AppRoutes.onboardingPlan);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String topText,
    required String bottomText,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.greenDark),
            const SizedBox(width: 4),
            Text(
              topText,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          bottomText,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.neutral500,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: Color(0xFF16A34A),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

