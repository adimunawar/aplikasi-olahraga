import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../plans/presentation/screens/plans_screen.dart';
import '../../../plans/presentation/widgets/plans_overview_tab.dart';
import '../../../plans/presentation/widgets/plans_workout_split_tab.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/domain/services/dynamic_program_generator.dart';
import '../../../program/presentation/controllers/draft_program_provider.dart';

/// Screen "Plan Preview" Onboarding (Prioritas P0 & P1):
/// - Menampilkan program aktual hasil kalkulasi generator (bukan dummy/hardcode)
/// - HANYA memiliki 2 Tab: "Overview" dan "Workout Split" (TANPA Tab Progress fiktif)
/// - Program BELUM aktif di database sebelum pengguna menyetujuinya
/// - Pengguna memeriksa seluruh jadwal & kurikulum latihan sebelum aktivasi
class PlanPreviewScreen extends ConsumerStatefulWidget {
  const PlanPreviewScreen({super.key});

  @override
  ConsumerState<PlanPreviewScreen> createState() => _PlanPreviewScreenState();
}

class _PlanPreviewScreenState extends ConsumerState<PlanPreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfileEntity? _profile;
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final cached = ref.read(onboardingProfileProvider);
    if (cached != null) {
      setState(() => _profile = cached);
      return;
    }
    final p = await AppDatabase.instance.getUserProfile();
    if (mounted) setState(() => _profile = p);
  }

  /// Menampilkan detail gerakan di dalam suatu sesi saat ditekan di tab Workout Split
  void _showSessionDetails(SessionWithDetail s) {
    final t = Translations.of(context).onboarding.preview;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.session.name.isNotEmpty
                              ? s.session.name
                              : t.sessionFallbackName(n: s.session.dayNumber),
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          s.session.focusLabel,
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F9ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      t.sessionDuration(n: s.session.targetDurationMinutes),
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF16A34A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF3F4F6), height: 1),
              const SizedBox(height: 12),
              Text(
                t.exercisesInSession(count: s.detail.exercises.length),
                style: AppTypography.labelSmall.copyWith(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: s.detail.exercises.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = s.detail.exercises[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4F836),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: Color(0xFF141718),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.exercise.name.en.isNotEmpty
                                      ? item.exercise.name.en
                                      : item.exercise.name.id,
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.prescription(
                                    sets: item.prescription.targetSets,
                                    reps: item.prescription.minReps,
                                    rests: item.prescription.restSeconds,
                                  ),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Aktivasi Program & Langsung Mulai Workout Sesi 1
  Future<void> _activateAndStartWorkout(GeneratedProgramResult draft) async {
    if (_isActivating) return;
    setState(() => _isActivating = true);

    try {
      final db = AppDatabase.instance;

      // 1. Simpan program dinamis ke SQLite Database secara resmi
      await db.saveDynamicProgram(
        program: draft.program,
        sessions: draft.sessions,
      );

      // 2. Tandai onboarding selesai
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);
      ref.read(hasCompletedOnboardingProvider.notifier).state = true;

      // 3. Siapkan argumen Workout Session 1
      if (draft.sessions.isNotEmpty) {
        final firstSession = draft.sessions.first;
        final exercises = firstSession.exercises
            .map((e) => e.exercise)
            .toList();
        final workoutItems = firstSession.exercises.map((e) {
          return WorkoutItem(
            exerciseId: e.exercise.id,
            sets: e.prescription.targetSets,
            reps: e.prescription.minReps,
            restSeconds: e.prescription.restSeconds,
            isMain: e.prescription.stage == 'main',
            stage: e.prescription.stage,
          );
        }).toList();

        final programDay = ProgramDay(
          day: firstSession.session.dayNumber,
          week: 1,
          type: WorkoutTypeCode.f,
          focus: LocalizedString(
            id: firstSession.session.focusLabel,
            en: firstSession.session.focusLabel,
          ),
          isRest: false,
          isRetestMilestone: false,
          items: workoutItems,
        );

        if (mounted) {
          // Navigasi ke Workout Session
          context.go(AppRoutes.home);
          context.push(
            AppRoutes.workoutSession,
            extra: WorkoutSessionArgs(day: programDay, exercises: exercises),
          );
        }
      } else {
        if (mounted) context.go(AppRoutes.home);
      }
    } catch (e) {
      debugPrint('[PlanPreviewScreen] Error activating program: $e');
      if (mounted) {
        setState(() => _isActivating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('We couldn’t activate your plan. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Aktivasi Program & Masuk ke Dashboard Utama
  Future<void> _activateAndGoHome(GeneratedProgramResult draft) async {
    if (_isActivating) return;
    setState(() => _isActivating = true);

    try {
      final db = AppDatabase.instance;
      await db.saveDynamicProgram(
        program: draft.program,
        sessions: draft.sessions,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);
      ref.read(hasCompletedOnboardingProvider.notifier).state = true;

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      debugPrint('[PlanPreviewScreen] Error activating program: $e');
      if (mounted) {
        setState(() => _isActivating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('We couldn’t activate your plan. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.preview;
    final draft = ref.watch(draftProgramProvider);

    // Drafts are intentionally in-memory only. Recover if app state was lost.
    if (draft == null) {
      return Scaffold(
        backgroundColor: Colors.white,
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
                    color: Color(0xFFF4F9ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF65A30D),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Your plan preview has expired',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your draft is no longer available. Create your plan again to review it before activation.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.onboarding),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.limeAccent,
                      foregroundColor: AppColors.darkCharcoal,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Create My Plan Again'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Mapping sesi draft ke SessionWithDetail
    final List<SessionWithDetail> sessions = draft.sessions.map((s) {
      return SessionWithDetail(session: s.session, detail: s);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF141718)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.pushReplacement(AppRoutes.planReady);
            }
          },
        ),
        title: Text(
          t.title,
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: const Color(0xFF141718),
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF84CC16),
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF141718),
              unselectedLabelColor: const Color(0xFF9CA3AF),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              // HANYA 2 TAB (Prioritas P1: Hilangkan Progress tab dari preview!)
              tabs: [
                Tab(text: t.tabOverview),
                Tab(text: t.tabWorkoutSplit),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton.primary(
              text: t.activateStart,
              size: AppButtonSize.large,
              isLoading: _isActivating,
              onPressed: () => _activateAndStartWorkout(draft),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _isActivating ? null : () => _activateAndGoHome(draft),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                child: Text(
                  t.activateDashboard,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Overview
          PlansOverviewTab(profile: _profile, program: draft.program),

          // Tab 2: Workout Split (Menampilkan kurikulum aktual dari generator)
          PlansWorkoutSplitTab(
            profile: _profile,
            program: draft.program,
            sessions: sessions,
            onSessionTap: _showSessionDetails,
          ),
        ],
      ),
    );
  }
}
