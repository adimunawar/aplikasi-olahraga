import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../program/domain/services/dynamic_program_generator.dart';
import '../widgets/onboarding_welcome_step.dart';
import '../widgets/onboarding_goal_step.dart';
import '../widgets/onboarding_level_step.dart';
import '../widgets/onboarding_schedule_step.dart';
import '../widgets/onboarding_equipment_limitations_step.dart';
import '../widgets/onboarding_assessment_step.dart';
import '../widgets/onboarding_plan_ready_step.dart';

/// OnboardingScreen:
/// Mengelola alur onboarding terarah & adaptif (Sesuai PRD Baru P0):
/// 1. Welcome / Build Strength at Home
/// 2. What's Your Goal?
/// 3. What's Your Experience Level?
/// 4. Your Schedule (Days & Duration)
/// 5. Equipment & Limitations
/// 6. Initial Baseline Assessment (Push Up Test)
/// 7. Your Plan Is Ready!
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  String _goal = 'muscle_gain';
  String _level = 'beginner';
  int _daysPerWeek = 3;
  int _durationMin = 20;
  List<String> _equipments = ['bodyweight', 'mat', 'stable_surface', 'doorframe'];
  List<String> _limitations = ['none'];
  String _baselineCapability = 'zero'; // 'zero' (0 reps), 'few' (1-5 reps), 'solid' (6-12+ reps)

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  String _getStartingExerciseName() {
    switch (_baselineCapability) {
      case 'few':
        return 'Knee Push Up';
      case 'solid':
        return 'Standard Push Up';
      case 'zero':
      default:
        return 'Incline Push Up';
    }
  }

  Future<void> _completeOnboarding() async {
    // 1. Simpan preferensi ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    // 2. Tentukan hari yang tersedia sesuai pilihan frekuensi
    List<String> availableDays;
    switch (_daysPerWeek) {
      case 2:
        availableDays = ['tuesday', 'thursday'];
        break;
      case 4:
        availableDays = ['monday', 'tuesday', 'thursday', 'friday'];
        break;
      case 5:
        availableDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
        break;
      case 3:
      default:
        availableDays = ['monday', 'wednesday', 'friday'];
        break;
    }

    // 3. Simpan profil ke Local SQLite Database
    final db = AppDatabase.instance;
    final currentProfile = await db.getUserProfile();
    final updatedProfile = currentProfile.copyWith(
      goal: _goal,
      experienceLevel: _level,
      preferredDaysPerWeek: _daysPerWeek,
      weeklyFrequency: _daysPerWeek,
      preferredDurationMin: _durationMin,
      availableDays: availableDays,
      equipments: _equipments,
      trainingLimitations: _limitations,
    );
    await db.saveUserProfile(updatedProfile);

    // 4. Generate Program Latihan Dinamis via DynamicProgramGenerator
    try {
      final exerciseDatasource = ExerciseLocalDatasource(db: db);
      final catalog = await exerciseDatasource.loadExercises();

      final startingPushId = _baselineCapability == 'solid'
          ? 'push_up'
          : _baselineCapability == 'few'
              ? 'knee_push_up'
              : 'incline_push_up';

      final generated = const DynamicProgramGenerator().generate(
        userProfile: updatedProfile,
        catalogExercises: catalog,
        startingPushExerciseId: startingPushId,
      );

      await db.saveDynamicProgram(
        program: generated.program,
        sessions: generated.sessions,
      );
    } catch (e) {
      debugPrint('[Onboarding] Error generating initial program: $e');
    }

    // 5. Pindah ke Home Dashboard
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Terarah lewat tombol
        children: [
          // Step 1: Welcome
          OnboardingWelcomeStep(
            onGetStarted: _nextPage,
            onSkip: _completeOnboarding,
          ),

          // Step 2: Goal
          OnboardingGoalStep(
            selectedGoal: _goal,
            onGoalSelected: (val) => setState(() => _goal = val),
            onNext: _nextPage,
            onBack: _previousPage,
          ),

          // Step 3: Level
          OnboardingLevelStep(
            selectedLevel: _level,
            onLevelSelected: (val) => setState(() => _level = val),
            onNext: _nextPage,
            onBack: _previousPage,
          ),

          // Step 4: Schedule (Days & Duration)
          OnboardingScheduleStep(
            selectedDays: _daysPerWeek,
            selectedDurationMin: _durationMin,
            onDaysSelected: (val) => setState(() => _daysPerWeek = val),
            onDurationSelected: (val) => setState(() => _durationMin = val),
            onNext: _nextPage,
            onBack: _previousPage,
          ),

          // Step 5: Equipment & Limitations (PRD Baru)
          OnboardingEquipmentLimitationsStep(
            selectedEquipments: _equipments,
            selectedLimitations: _limitations,
            onEquipmentsChanged: (val) => setState(() => _equipments = val),
            onLimitationsChanged: (val) => setState(() => _limitations = val),
            onNext: _nextPage,
            onBack: _previousPage,
          ),

          // Step 6: Initial Baseline Assessment (PRD Baru)
          OnboardingAssessmentStep(
            selectedCapability: _baselineCapability,
            onCapabilitySelected: (val) => setState(() => _baselineCapability = val),
            onNext: _nextPage,
            onBack: _previousPage,
          ),

          // Step 7: Plan Ready
          OnboardingPlanReadyStep(
            daysPerWeek: _daysPerWeek,
            durationMin: _durationMin,
            level: _level,
            goal: _goal,
            startingExercise: _getStartingExerciseName(),
            onStartMyPlan: _completeOnboarding,
            onBack: _previousPage,
          ),
        ],
      ),
    );
  }
}

