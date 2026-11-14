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
  String? _errorMessage;

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

      // Step 1: Read the actual onboarding profile and exercise catalog.
      if (!mounted || _isCancelled) return;
      setState(() => _activeStepIndex = 0);
      await WidgetsBinding.instance.endOfFrame;

      var profile = ref.read(onboardingProfileProvider);
      profile ??= await db.getUserProfile();

      final exerciseDatasource = ExerciseLocalDatasource(db: db);
      final catalog = await exerciseDatasource.loadExercises();
      if (catalog.isEmpty) {
        throw StateError('The exercise library is empty. Please try again.');
      }

      // Step 2: Resolve the initial movement variation from the user's level.
      if (!mounted || _isCancelled) return;
      setState(() => _activeStepIndex = 1);
      await WidgetsBinding.instance.endOfFrame;

      final startingPushId = profile.experienceLevel == 'advanced'
          ? 'diamond_push_up'
          : (profile.experienceLevel == 'intermediate'
              ? 'push_up'
              : 'knee_push_up');

      // Step 3: Run the real program generator.
      if (!mounted || _isCancelled) return;
      setState(() => _activeStepIndex = 2);
      await WidgetsBinding.instance.endOfFrame;

      final generated = const DynamicProgramGenerator().generate(
        userProfile: profile,
        catalogExercises: catalog,
        startingPushExerciseId: startingPushId,
      );
      if (generated.sessions.isEmpty) {
        throw StateError(
          'No workout sessions could be generated. Please review your preferences.',
        );
      }

      // Step 4: Keep the generated result in memory as a draft only.
      if (!mounted || _isCancelled) return;
      setState(() => _activeStepIndex = 3);
      await WidgetsBinding.instance.endOfFrame;

      ref.read(draftProgramProvider.notifier).state = generated;

      if (!mounted || _isCancelled) return;
      setState(() => _activeStepIndex = 4);
      await WidgetsBinding.instance.endOfFrame;

      if (mounted && !_isCancelled) {
        context.pushReplacement(AppRoutes.planReady);
      }
    } catch (e) {
      debugPrint('[CreatingPlanScreen] Error in real generation pipeline: $e');
      ref.read(draftProgramProvider.notifier).state = null;
      if (mounted && !_isCancelled) {
        setState(() {
          _errorMessage =
              'We couldn’t create a suitable plan with the current exercise library. Please try again or review your preferences.';
        });
      }
    }
  }

  Future<void> _retryGeneration() async {
    if (!mounted) return;
    _isCancelled = false;
    ref.read(draftProgramProvider.notifier).state = null;
    setState(() {
      _activeStepIndex = 0;
      _errorMessage = null;
    });
    await _runGenerationPipeline();
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 38,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'We couldn’t create your plan',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _retryGeneration,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.limeAccent,
                    foregroundColor: AppColors.darkCharcoal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go(AppRoutes.onboarding),
                child: const Text('Review my preferences'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.creating;

    if (_errorMessage != null) {
      return _buildErrorState(context);
    }

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
                        color: AppColors.limeAccent.withValues(alpha: 0.35),
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
