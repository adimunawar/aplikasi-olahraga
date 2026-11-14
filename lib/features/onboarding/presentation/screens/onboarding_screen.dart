import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';
import '../../../program/presentation/controllers/draft_program_provider.dart';
import '../widgets/onboarding_dots_indicator.dart';
import '../widgets/step_about.dart';
import '../widgets/step_body_target.dart';
import '../widgets/step_equipment.dart';
import '../widgets/step_experience.dart';
import '../widgets/step_goal.dart';
import '../widgets/step_limitations.dart';
import '../widgets/step_schedule.dart';
import '../widgets/step_welcome.dart';

/// Onboarding Master Wrapper (Mockup 1:1 Resolusi Tinggi):
/// Mengelola alur 7 langkah secara terpusat:
/// - Single Header (Back Arrow + "X of 7" + Linear Progress Bar)
/// - Single Sticky Bottom Bar ("Continue" / "Create My Plan") tanpa duplikasi di tiap step
/// - Mengumpulkan semua data profil pengguna secara akurat (Audit Finding P0)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0: Welcome, 1..7: Steps 1..7
  bool _isCreatingPlan = false;

  // --- STATE DATA ONBOARDING LENGKAP ---
  String _goal = 'muscle_gain';
  String _gender = 'male';
  int _age = 28;
  double _heightCm = 170.0;
  double _currentWeightKg = 75.0;
  double _targetWeightKg = 82.0;
  String _level = 'beginner';
  int _daysPerWeek = 4;
  int _durationMin = 45;
  final List<String> _equipments = ['bodyweight'];
  List<String> _limitations = ['none'];

  void _nextStep() {
    if (_currentStep < 7) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  void _toggleEquipment(String id) {
    setState(() {
      if (_equipments.contains(id)) {
        if (_equipments.length > 1) _equipments.remove(id);
      } else {
        _equipments.add(id);
      }
    });
  }

  void _toggleLimitation(String id) {
    setState(() {
      if (id == 'none') {
        _limitations = ['none'];
      } else {
        _limitations.remove('none');
        if (_limitations.contains(id)) {
          _limitations.remove(id);
          if (_limitations.isEmpty) _limitations.add('none');
        } else {
          _limitations.add(id);
        }
      }
    });
  }

  Future<void> _createMyPlan() async {
    setState(() => _isCreatingPlan = true);

    try {
      // 1. Petakan hari latihan sesuai pilihan frekuensi
      List<String> availableDays;
      switch (_daysPerWeek) {
        case 2:
          availableDays = ['tuesday', 'thursday'];
          break;
        case 4:
          availableDays = ['monday', 'tuesday', 'thursday', 'friday'];
          break;
        case 5:
          availableDays = [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
          ];
          break;
        case 6:
          availableDays = [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
          ];
          break;
        case 3:
        default:
          availableDays = ['monday', 'wednesday', 'friday'];
          break;
      }

      // 2. Simpan Profil Pengguna Lengkap ke SQLite Database (Audit Finding P0)
      final db = AppDatabase.instance;
      final currentProfile = await db.getUserProfile();
      final updatedProfile = currentProfile.copyWith(
        gender: _gender,
        age: _age,
        heightCm: _heightCm,
        currentWeightKg: _currentWeightKg,
        targetWeightKg: _targetWeightKg,
        targetTimeframeWeeks: 12,
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

      // Simpan ke Riverpod state agar dapat diakses oleh CreatingPlanScreen
      ref.read(onboardingProfileProvider.notifier).state = updatedProfile;

      // 3. Navigasi ke Layar Proses Nyata "Creating your personal plan..."
      // Catatan: Program BELUM diaktifkan ke DB sebelum disetujui pengguna (Prioritas P0)
      if (mounted) {
        context.pushReplacement(AppRoutes.creatingPlan);
      }
    } catch (e) {
      debugPrint('[Onboarding] Error preparing profile: $e');
      if (mounted) {
        setState(() => _isCreatingPlan = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'We couldn’t save your preferences. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // -------------------------------------------------------------
            // 1. TOP HEADER (Progress "X of 7" & Back Button Terpusat)
            // -------------------------------------------------------------
            _buildTopHeader(),

            // -------------------------------------------------------------
            // 2. PAGE VIEW CONTENT (Hanya Isi Formulir Tiap Step)
            // -------------------------------------------------------------
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 0: Welcome
                  const StepWelcome(),

                  // Step 1: Goal
                  StepGoal(
                    selectedGoal: _goal,
                    onGoalSelected: (val) => setState(() => _goal = val),
                  ),

                  // Step 2: About (Gender & Age)
                  StepAbout(
                    gender: _gender,
                    age: _age,
                    onGenderChanged: (val) => setState(() => _gender = val),
                    onAgeChanged: (val) => setState(() => _age = val),
                  ),

                  // Step 3: Body Metrics & Target (Height, Current & Target Weight)
                  StepBodyTarget(
                    heightCm: _heightCm,
                    currentWeightKg: _currentWeightKg,
                    targetWeightKg: _targetWeightKg,
                    onHeightChanged: (val) => setState(() => _heightCm = val),
                    onCurrentWeightChanged: (val) =>
                        setState(() => _currentWeightKg = val),
                    onTargetWeightChanged: (val) =>
                        setState(() => _targetWeightKg = val),
                  ),


                  // Step 4: Experience Level
                  StepExperience(
                    selectedLevel: _level,
                    onLevelSelected: (val) => setState(() => _level = val),
                  ),

                  // Step 5: Schedule (Frequency & Duration)
                  StepSchedule(
                    daysPerWeek: _daysPerWeek,
                    durationMin: _durationMin,
                    onDaysPerWeekChanged: (val) =>
                        setState(() => _daysPerWeek = val),
                    onDurationMinChanged: (val) =>
                        setState(() => _durationMin = val),
                  ),

                  // Step 6: Equipment
                  StepEquipment(
                    selectedEquipments: _equipments,
                    onToggleEquipment: _toggleEquipment,
                  ),

                  // Step 7: Limitations
                  StepLimitations(
                    selectedLimitations: _limitations,
                    onToggleLimitation: _toggleLimitation,
                  ),
                ],
              ),
            ),

            // -------------------------------------------------------------
            // 3. STICKY BOTTOM BAR (Satu Pembungkus Bersama - Anti Copas)
            // -------------------------------------------------------------
            _buildStickyBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    if (_currentStep == 0) {
      return const SizedBox(height: 12);
    }

    final t = Translations.of(context).onboarding.nav;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.darkCharcoal,
                  size: 24,
                ),
                onPressed: _prevStep,
              ),
              Text(
                t.progress(current: _currentStep, total: 7),
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
        // Progress Bar Horizontal Halus
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep / 7.0).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF84CC16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStickyBottomBar() {
    final t = Translations.of(context).onboarding.nav;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: _currentStep == 0
            ? null
            : const Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
        boxShadow: _currentStep == 0
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: _currentStep == 0
            ? Row(
                children: [
                  const OnboardingDotsIndicator(activeIndex: 0),
                  const Spacer(),
                  AppButton.primary(
                    text: t.getStarted,
                    size: AppButtonSize.large,
                    isFullWidth: false,
                    width: 210,
                    onPressed: _nextStep,
                  ),
                ],
              )
            : AppButton.primary(
                text: _currentStep == 7 ? t.createMyPlan : t.continueCta,
                size: AppButtonSize.large,
                isLoading: _isCreatingPlan,
                onPressed: _currentStep == 7 ? _createMyPlan : _nextStep,
              ),
      ),
    );
  }

}
