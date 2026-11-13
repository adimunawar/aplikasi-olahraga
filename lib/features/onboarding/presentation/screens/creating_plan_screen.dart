import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../program/domain/services/dynamic_program_generator.dart';
import '../../../program/presentation/controllers/draft_program_provider.dart';

/// Screen Proses Nyata Pembuatan Program (Prioritas P0 & Mockup Baris 2, Layar 1):
/// "Creating your personal plan..."
/// Menjalankan komputasi aktual generator berdasarkan input profil pengguna nyata,
/// memperbarui status checklist langkah demi langkah, dan menyimpan hasil sebagai Draft
/// TANPA mengaktifkan atau menyimpannya ke database sebelum disetujui pengguna.
class CreatingPlanScreen extends ConsumerStatefulWidget {
  const CreatingPlanScreen({super.key});

  @override
  ConsumerState<CreatingPlanScreen> createState() => _CreatingPlanScreenState();
}

class _CreatingPlanScreenState extends ConsumerState<CreatingPlanScreen> {
  int _activeStepIndex = 0;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _runGenerationPipeline();
  }

  @override
  void dispose() {
    _isCancelled = true;
    super.dispose();
  }

  Future<void> _runGenerationPipeline() async {
    try {
      final db = AppDatabase.instance;

      // -------------------------------------------------------------
      // Tahap 1: Analyzing your profile
      // -------------------------------------------------------------
      if (!mounted || _isCancelled) return;
      setState(() => _activeStepIndex = 0);

      var profile = ref.read(onboardingProfileProvider);
      profile ??= await db.getUserProfile();

      final exerciseDatasource = ExerciseLocalDatasource(db: db);
      final catalog = await exerciseDatasource.loadExercises();
      await Future.delayed(const Duration(milliseconds: 600));

      // -------------------------------------------------------------
      // Tahap 2: Calculating training volume
      // -------------------------------------------------------------
      if (!mounted || _isCancelled) return;
      setState(() => _activeStepIndex = 1);

      final startingPushId = profile.experienceLevel == 'advanced'
          ? 'diamond_push_up'
          : (profile.experienceLevel == 'intermediate'
              ? 'push_up'
              : 'knee_push_up');
      await Future.delayed(const Duration(milliseconds: 650));

      // -------------------------------------------------------------
      // Tahap 3: Selecting the best exercises
      // -------------------------------------------------------------
      if (!mounted || _isCancelled) return;
      setState(() => _activeStepIndex = 2);

      final generated = const DynamicProgramGenerator().generate(
        userProfile: profile,
        catalogExercises: catalog,
        startingPushExerciseId: startingPushId,
      );
      await Future.delayed(const Duration(milliseconds: 700));

      // -------------------------------------------------------------
      // Tahap 4: Building your weekly plan (Draft Program)
      // -------------------------------------------------------------
      if (!mounted || _isCancelled) return;
      setState(() => _activeStepIndex = 3);

      // Simpan hasil ke Riverpod Draft State (Bukan DB!)
      ref.read(draftProgramProvider.notifier).state = generated;
      await Future.delayed(const Duration(milliseconds: 600));

      // Selesai -> Semua checklist tercentang
      if (!mounted || _isCancelled) return;
      setState(() => _activeStepIndex = 4);
      await Future.delayed(const Duration(milliseconds: 450));

      if (mounted && !_isCancelled) {
        context.pushReplacement(AppRoutes.planReady);
      }
    } catch (e) {
      debugPrint('[CreatingPlanScreen] Error in real generation pipeline: $e');
      if (mounted && !_isCancelled) {
        context.pushReplacement(AppRoutes.planReady);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.creating;

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
                  t.title,
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
                  t.subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Checklist Animasi Proses Nyata 4 Langkah
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.neutral200, width: 1.2),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: List.generate(t.steps.length, (index) {
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
                            t.steps[index],
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
