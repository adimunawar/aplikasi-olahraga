import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/workout_summary_hero_section.dart';
import '../widgets/workout_summary_stats_card.dart';
import '../widgets/coach_motivation_quote_card.dart';
import '../widgets/coach_adi_progression_card.dart';
import '../widgets/workout_summary_actions.dart';
import '../../../progression/domain/models/progression_models.dart';

/// Layar Workout Summary / Workout Completed (Mockup 1:1 Resolusi Tinggi):
/// - Header: Back arrow & "Workout Summary"
/// - Hero: Foto Coach Adi perayaan, badge checklist hijau, "Workout Completed!", ucapan personal
/// - Stats Card: "Upper Body Strength", "Week 3 • Day 1", Durasi (25 min), Gerakan (5/5), Sets (15), Kalori (185 kcal)
/// - Quote Card: Foto Coach Adi menunjuk, tanda kutip hijau, & kata-kata motivasi konsistensi bulking
/// - Aksi: Tombol hijau lime "Done" & Tombol outline "View Progress"
class WorkoutSummaryScreen extends StatelessWidget {
  final String userName;
  final String workoutTitle;
  final String weekDayText;
  final String durationText;
  final String exercisesCountText;
  final String setsCountText;
  final String caloriesText;
  final String quoteText;
  final List<ProgressionDecision> progressionDecisions;

  const WorkoutSummaryScreen({
    super.key,
    this.userName = 'Adi',
    this.workoutTitle = 'Upper Body Strength',
    this.weekDayText = 'Week 3 • Day 1',
    this.durationText = '25 min',
    this.exercisesCountText = '5 / 5',
    this.setsCountText = '15',
    this.caloriesText = '≈ 185 kcal',
    this.quoteText =
        'Latihan yang konsisten seperti ini akan membantu kamu membangun massa otot dan tubuh yang lebih kuat. Pertahankan!',
    this.progressionDecisions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF141718),
            size: 24,
          ),
          onPressed: () => _navigateToHome(context),
        ),
        title: Text(
          'Workout Summary',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF141718),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // 1. Hero Selebrasi
            WorkoutSummaryHeroSection(
              userName: userName,
              workoutTitle: workoutTitle,
            ),
            const SizedBox(height: 20),

            // 2. Card Statistik Sesi
            WorkoutSummaryStatsCard(
              workoutTitle: workoutTitle,
              weekDayText: weekDayText,
              durationText: durationText,
              exercisesCountText: exercisesCountText,
              setsCountText: setsCountText,
              caloriesText: caloriesText,
            ),
            const SizedBox(height: 18),

            // 3. Card Evaluasi Adaptif Coach Adi (Fase 4: Progression Engine)
            CoachAdiProgressionCard(
              decisions: progressionDecisions,
            ),
            const SizedBox(height: 18),

            // 4. Card Motivasi Coach Adi
            CoachMotivationQuoteCard(
              quoteText: quoteText,
            ),
            const SizedBox(height: 24),

            // 4. Tombol Aksi: Done & View Progress
            WorkoutSummaryActions(
              onDone: () => _navigateToHome(context),
              onViewProgress: () => _navigateToProgress(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  void _navigateToProgress(BuildContext context) {
    context.go(AppRoutes.progress);
  }
}

