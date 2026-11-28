import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../program/presentation/controllers/draft_program_provider.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/onboarding_state.dart';
import '../widgets/onboarding_widgets.dart';

/// Master onboarding flow managing the 8-step setup and profile persistence.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _nextStep() {
    if (ref.read(onboardingControllerProvider.notifier).nextStep()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (ref.read(onboardingControllerProvider.notifier).prevStep()) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createMyPlan() async {
    final updatedProfile = await ref
        .read(onboardingControllerProvider.notifier)
        .createPlan();

    if (!mounted) return;
    if (updatedProfile != null) {
      ref.read(onboardingProfileProvider.notifier).state = updatedProfile;
      context.pushReplacement(AppRoutes.creatingPlan);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('We couldn’t save your preferences. Please try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingTopHeader(
              currentStep: state.currentStep,
              totalSteps: OnboardingState.totalSteps,
              onBack: _prevStep,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const StepWelcome(),
                  StepGoal(
                    selectedGoal: state.goal,
                    onGoalSelected: controller.setGoal,
                  ),
                  StepAbout(
                    gender: state.gender,
                    age: state.age,
                    onGenderChanged: controller.setGender,
                    onAgeChanged: controller.setAge,
                  ),
                  StepHeight(
                    heightCm: state.heightCm,
                    gender: state.gender,
                    onHeightChanged: controller.setHeightCm,
                  ),
                  StepWeight(
                    currentWeightKg: state.currentWeightKg,
                    targetWeightKg: state.targetWeightKg,
                    gender: state.gender,
                    onCurrentWeightChanged: controller.setCurrentWeightKg,
                    onTargetWeightChanged: controller.setTargetWeightKg,
                  ),
                  StepExperience(
                    selectedLevel: state.level,
                    onLevelSelected: controller.setLevel,
                  ),
                  StepSchedule(
                    daysPerWeek: state.daysPerWeek,
                    durationMin: state.durationMin,
                    onDaysPerWeekChanged: controller.setDaysPerWeek,
                    onDurationMinChanged: controller.setDurationMin,
                  ),
                  StepEquipment(
                    selectedEquipments: state.equipments,
                    onToggleEquipment: controller.toggleEquipment,
                  ),
                  StepLimitations(
                    selectedLimitations: state.limitations,
                    onToggleLimitation: controller.toggleLimitation,
                  ),
                ],
              ),
            ),
            OnboardingBottomBar(
              currentStep: state.currentStep,
              totalSteps: OnboardingState.totalSteps,
              isLoading: state.isCreatingPlan,
              onNext: _nextStep,
              onComplete: _createMyPlan,
              onSignIn: () => context.push(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}
