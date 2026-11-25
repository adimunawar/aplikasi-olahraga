import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:workout_app/core/router/app_router.dart';
import 'package:workout_app/core/theme/app_colors.dart';
import 'package:workout_app/core/theme/app_typography.dart';
import 'package:workout_app/core/widgets/app_button.dart';
import 'package:workout_app/i18n/strings.g.dart';

import '../widgets/workout_completed_badge.dart';

/// Halaman Selebrasi & Feedback Selesai Latihan dengan animasi dinamis (Mockup 1:1 Resolusi Tinggi)
class WorkoutCompletedScreen extends StatefulWidget {
  final WorkoutCompletedArgs args;

  const WorkoutCompletedScreen({super.key, required this.args});

  @override
  State<WorkoutCompletedScreen> createState() => _WorkoutCompletedScreenState();
}

class _WorkoutCompletedScreenState extends State<WorkoutCompletedScreen>
    with SingleTickerProviderStateMixin {
  // Default: Index 2 ("Just Right")
  int _selectedRatingIndex = 2;

  late final AnimationController _entranceController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _statsFade;
  late final Animation<Offset> _statsSlide;
  late final Animation<double> _statsProgress;
  late final Animation<double> _feedbackFade;
  late final Animation<Offset> _feedbackSlide;
  late final Animation<double> _actionsFade;
  late final Animation<Offset> _actionsSlide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 1. Header (Judul & Subtitle) slide & fade
    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(_headerFade);

    // 2. Stats card slide & fade
    _statsFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );
    _statsSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(_statsFade);

    // 3. Counter angka stats naik secara dinamis
    _statsProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // 4. Rating feedback section
    _feedbackFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.90, curve: Curves.easeOut),
    );
    _feedbackSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_feedbackFade);

    // 5. Bottom buttons
    _actionsFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
    );
    _actionsSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(_actionsFade);

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _onSaveAndContinue() {
    // Navigasi kembali ke Dashboard / Home secara deklaratif
    context.go(AppRoutes.home);
  }

  void _onViewSummary() {
    // Navigasi ke rincian WorkoutSummaryScreen secara deklaratif
    context.go(
      AppRoutes.workoutSummary,
      extra: WorkoutSummaryArgs(
        userName: widget.args.userName,
        workoutTitle: widget.args.workoutTitle,
        weekDayText: widget.args.weekDayText ?? 'Completed Workout',
        durationText: '${widget.args.durationMinutes} min',
        exercisesCountText:
            '${widget.args.exercisesCount} / ${widget.args.exercisesCount}',
        setsCountText:
            widget.args.setsCountText ??
            '${widget.args.result?.completedSets ?? 0}',
        caloriesText: '≈ ${widget.args.caloriesBurned} kcal',
        progressionDecisions: widget.args.progressionDecisions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final completedLocale = t.workoutSession.completedScreen;

    final ratingItems = [
      (icon: Icons.sentiment_neutral_rounded, label: completedLocale.tooEasy),
      (icon: Icons.sentiment_satisfied_rounded, label: completedLocale.easy),
      (
        icon: Icons.sentiment_very_satisfied_rounded,
        label: completedLocale.justRight,
      ),
      (icon: Icons.sentiment_dissatisfied_rounded, label: completedLocale.hard),
      (
        icon: Icons.sentiment_very_dissatisfied_rounded,
        label: completedLocale.tooHard,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // 1. Scalloped Badge with Checkmark & Confetti (memiliki animasi mandiri)
                    const WorkoutCompletedBadge(size: 150),
                    const SizedBox(height: 28),

                    // 2. Heading Title & Subtitle dengan staggered slide-up & fade
                    SlideTransition(
                      position: _headerSlide,
                      child: FadeTransition(
                        opacity: _headerFade,
                        child: Column(
                          children: [
                            Text(
                              completedLocale.title,
                              style: AppTypography.displayMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 26,
                                letterSpacing: -0.5,
                                color: AppColors.darkCharcoal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              completedLocale.subtitle(
                                focus: widget.args.focusText.isNotEmpty
                                    ? widget.args.focusText
                                    : widget.args.workoutTitle,
                              ),
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.neutral500,
                                fontSize: 15,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3. Stats Summary Card dengan animasi counter angka
                    SlideTransition(
                      position: _statsSlide,
                      child: FadeTransition(
                        opacity: _statsFade,
                        child: AnimatedBuilder(
                          animation: _statsProgress,
                          builder: (context, _) =>
                              _buildStatsCard(completedLocale),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // 4. Feedback Rating Section: "How was the workout?"
                    SlideTransition(
                      position: _feedbackSlide,
                      child: FadeTransition(
                        opacity: _feedbackFade,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              completedLocale.howWasWorkout,
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: AppColors.darkCharcoal,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(ratingItems.length, (
                                index,
                              ) {
                                final item = ratingItems[index];
                                final isSelected =
                                    _selectedRatingIndex == index;
                                return _buildRatingItem(
                                  index: index,
                                  icon: item.icon,
                                  label: item.label,
                                  isSelected: isSelected,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 5. Sticky Bottom Action Buttons dengan fade & slide masuk
            SlideTransition(
              position: _actionsSlide,
              child: FadeTransition(
                opacity: _actionsFade,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton.primary(
                        text: completedLocale.saveAndContinue,
                        onPressed: _onSaveAndContinue,
                      ),
                      const SizedBox(height: 12),
                      AppButton.outline(
                        text: completedLocale.viewWorkoutSummary,
                        onPressed: _onViewSummary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(dynamic completedLocale) {
    final progress = _statsProgress.value;
    final displayDuration = (widget.args.durationMinutes * progress).round();
    final displayExercises = (widget.args.exercisesCount * progress).round();
    final displayCalories = (widget.args.caloriesBurned * progress).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral100, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Duration
          Expanded(
            child: _buildStatColumn(
              icon: Icons.access_time_rounded,
              value: '$displayDuration min',
              label: completedLocale.duration,
            ),
          ),
          Container(height: 38, width: 1, color: AppColors.neutral100),
          // Exercises
          Expanded(
            child: _buildStatColumn(
              icon: Icons.fitness_center_rounded,
              value: '$displayExercises',
              label: completedLocale.exercises,
            ),
          ),
          Container(height: 38, width: 1, color: AppColors.neutral100),
          // Est. Calories
          Expanded(
            child: _buildStatColumn(
              icon: Icons.local_fire_department_outlined,
              value: '$displayCalories',
              label: completedLocale.estCalories,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: AppColors.darkCharcoal),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: AppColors.darkCharcoal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.neutral400,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRatingIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tactile scale pop saat emoji dipilih
            AnimatedScale(
              scale: isSelected ? 1.08 : 0.95,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.limeAccent
                      : AppColors.neutral50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.neutral200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.limeAccent.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 28,
                    color: isSelected
                        ? AppColors.darkCharcoal
                        : AppColors.neutral500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? AppColors.darkCharcoal
                    : AppColors.neutral500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
