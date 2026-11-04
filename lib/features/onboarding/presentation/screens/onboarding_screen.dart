import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../home/presentation/screens/home_scaffold.dart';
import '../widgets/onboarding_welcome_step.dart';
import '../widgets/onboarding_goal_step.dart';
import '../widgets/onboarding_level_step.dart';
import '../widgets/onboarding_schedule_step.dart';
import '../widgets/onboarding_plan_ready_step.dart';

/// OnboardingScreen:
/// Mengelola alur 5 langkah onboarding terarah (PRD Bagian 9.1 & 10.1):
/// 1. Welcome / Build Strength at Home
/// 2. What's Your Goal?
/// 3. What's Your Experience Level?
/// 4. Your Schedule (Days & Duration)
/// 5. Your Plan Is Ready!
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

  Future<void> _completeOnboarding() async {
    // 1. Simpan preferensi ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    // 2. Simpan profil ke Local SQLite Database
    final db = AppDatabase.instance;
    final currentProfile = await db.getUserProfile();
    final updatedProfile = currentProfile.copyWith(
      goal: _goal,
      experienceLevel: _level,
      preferredDaysPerWeek: _daysPerWeek,
      preferredDurationMin: _durationMin,
    );
    await db.saveUserProfile(updatedProfile);

    // 3. Pindah ke Home Dashboard
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScaffold()),
      );
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

          // Step 4: Schedule
          OnboardingScheduleStep(
            selectedDays: _daysPerWeek,
            selectedDurationMin: _durationMin,
            onDaysSelected: (val) => setState(() => _daysPerWeek = val),
            onDurationSelected: (val) => setState(() => _durationMin = val),
            onNext: _nextPage,
            onBack: _previousPage,
          ),

          // Step 5: Plan Ready
          OnboardingPlanReadyStep(
            daysPerWeek: _daysPerWeek,
            durationMin: _durationMin,
            level: _level,
            goal: _goal,
            onStartMyPlan: _completeOnboarding,
            onBack: _previousPage,
          ),
        ],
      ),
    );
  }
}

