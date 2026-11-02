import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/data/datasources/program_local_datasource.dart';
import '../../../program/data/repositories/program_repository_impl.dart';
import '../../../nutrition/domain/models/food_item.dart';
import '../../../nutrition/domain/services/protein_recommendation_engine.dart';
import '../../../exercise_detail/presentation/screens/exercise_detail_screen.dart';
import '../../../workout_session/presentation/screens/workout_session_screen.dart';

class TodayScreen extends StatefulWidget {
  final VoidCallback onNavigateToCalendar;
  final VoidCallback onNavigateToExercises;
  final VoidCallback onNavigateToNutrition;

  const TodayScreen({
    super.key,
    required this.onNavigateToCalendar,
    required this.onNavigateToExercises,
    required this.onNavigateToNutrition,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _programRepo = ProgramRepositoryImpl(ProgramLocalDatasource());
  final _exerciseRepo = ExerciseRepositoryImpl(ExerciseLocalDatasource());

  ProgramDay? _todayProgram;
  List<Exercise> _todayExercises = [];
  bool _isLoading = true;

  // Daily protein intake state (PRD v1.1)
  final double _dailyTargetProteinG = 95.0;
  double _currentProteinG = 58.0;
  final List<String> _loggedFoods = ['egg', 'tempeh'];

  final List<FoodItem> _quickFoods = [
    FoodItem(
      id: 'egg',
      name: const LocalizedString(id: 'Telur', en: 'Egg'),
      portionLabel: const LocalizedString(id: '1 butir', en: '1 egg'),
      portionG: 55,
      proteinG: 6.0,
      costTier: 1,
      allergens: ['egg'],
    ),
    FoodItem(
      id: 'tempeh',
      name: const LocalizedString(id: 'Tempe', en: 'Tempeh'),
      portionLabel: const LocalizedString(id: '50 g', en: '50 g'),
      portionG: 50,
      proteinG: 10.0,
      costTier: 1,
      allergens: ['soy'],
    ),
    FoodItem(
      id: 'chicken_breast',
      name: const LocalizedString(id: 'Dada Ayam', en: 'Chicken Breast'),
      portionLabel: const LocalizedString(id: '100 g', en: '100 g'),
      portionG: 100,
      proteinG: 31.0,
      costTier: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  Future<void> _loadTodayData() async {
    final dayNum = await _programRepo.getCurrentProgramDay();
    final programDay = await _programRepo.getDay(dayNum);
    final allExercises = await _exerciseRepo.getExercises();

    final exercisesMap = {for (final e in allExercises) e.id: e};
    final resolvedExercises = programDay?.items
            .map((item) => exercisesMap[item.exerciseId])
            .whereType<Exercise>()
            .toList() ??
        [];

    if (mounted) {
      setState(() {
        _todayProgram = programDay;
        _todayExercises = resolvedExercises;
        _isLoading = false;
      });
    }
  }

  void _addQuickProtein(FoodItem food) {
    setState(() {
      _currentProteinG += food.proteinG;
      _loggedFoods.add(food.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceRaised,
        behavior: SnackBarBehavior.floating,
        content: Text(
          '+${food.proteinG.toStringAsFixed(0)}g protein dicatat (${food.name.id})',
          style: AppTypography.bodySmall.copyWith(color: AppColors.electricLime),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.electricLime),
        ),
      );
    }

    final day = _todayProgram;
    final remainingProtein = (_dailyTargetProteinG - _currentProteinG).clamp(0.0, 999.0);
    final proteinRatio = (_currentProteinG / _dailyTargetProteinG).clamp(0.0, 1.0);

    final recommendations = ProteinRecommendationEngine.recommend(
      remainingProteinG: remainingProtein,
      availableFoods: _quickFoods,
      userExcludedAllergens: {},
      loggedFoodIdsToday: _loggedFoods.toSet(),
    );

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header: Streak and Day Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HARI INI',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.electricLime,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hari ${day?.day ?? 1} / 30',
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  // Streak Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.warmAmber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.warmAmber,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '1 Hari Streak',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.warmAmber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Weekly Mini Calendar Strip (7 Days)
              _buildWeeklyStrip(day?.day ?? 1),

              const SizedBox(height: 24),

              // 3. Hero Workout Card
              _buildHeroWorkoutCard(day),

              const SizedBox(height: 24),

              // 4. Protein Tracker Card (v1.1)
              _buildProteinCard(remainingProtein, proteinRatio, recommendations),

              const SizedBox(height: 24),

              // 5. Exercise List for Today
              Text(
                'GERAKAN HARI INI',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              if (day?.isRest == true)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bedtime_outlined, color: AppColors.restDay, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Hari ini adalah hari istirahat total. Otot Anda tumbuh dan memulihkan serat protein saat beristirahat!',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _todayExercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final exercise = _todayExercises[index];
                    final workoutItem = day?.items[index];
                    return _buildExerciseListItem(exercise, workoutItem);
                  },
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyStrip(int currentDay) {
    const splitPattern = ['P', 'K', 'C', 'R', 'P', 'F', 'R'];
    final currentDayIndex = (currentDay - 1) % 7;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final isSelected = index == currentDayIndex;
          final code = splitPattern[index];
          final color = AppColors.forWorkoutCode(code);

          return GestureDetector(
            onTap: widget.onNavigateToCalendar,
            child: Column(
              children: [
                Text(
                  'H${index + 1}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? AppColors.electricLime : AppColors.textDim,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceRaised,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      code,
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected ? color : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeroWorkoutCard(ProgramDay? day) {
    if (day == null) return const SizedBox.shrink();

    final typeColor = AppColors.forWorkoutCode(day.type.code);
    final isRest = day.isRest;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout Type Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: typeColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${day.type.code} • ',
                      style: AppTypography.labelCaps.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      day.type.localizedTitle('id'),
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRest)
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '± 30 Menit',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Focus Title
          Text(
            day.focus.id,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isRest
                ? 'Hari ini fokus pemulihan otot dan hidrasi.'
                : '${day.items.length} Gerakan • ${day.items.fold(0, (sum, i) => sum + i.sets)} Total Set • Beban Progresif',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 20),

          // Big Start Workout CTA Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (isRest) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hari ini istirahat! Nikmati pemulihan Anda.')),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutSessionScreen(
                        day: day,
                        exercises: _todayExercises,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRest ? AppColors.surfaceRaised : AppColors.electricLime,
                foregroundColor: isRest ? AppColors.textSecondary : Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRest ? Icons.spa_outlined : Icons.play_arrow_rounded,
                    color: isRest ? AppColors.textSecondary : Colors.black,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRest ? 'HARI ISTIRAHAT' : 'MULAI SESI LATIHAN',
                    style: AppTypography.labelLarge.copyWith(
                      color: isRest ? AppColors.textSecondary : Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProteinCard(
    double remaining,
    double ratio,
    List<FoodCombination> recommendations,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.egg_outlined, color: AppColors.electricLime, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'PANDUAN PROTEIN HARIAN',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.electricLime,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Text(
                '${_currentProteinG.toStringAsFixed(0)} / ${_dailyTargetProteinG.toStringAsFixed(0)} g',
                style: AppTypography.tabularMetricSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.surfaceRaised,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricLime),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            remaining <= 0
                ? 'Target protein harian telah tercapai! Pertahankan hidrasi.'
                : 'Terpenuhi ${_currentProteinG.toStringAsFixed(0)} g, sisa ${remaining.toStringAsFixed(0)} g lagi hari ini.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          // Quick Tap Food Chips
          Text(
            'Catat Cepat Asupan:',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textDim),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickFoods.map((food) {
              return ActionChip(
                backgroundColor: AppColors.surfaceRaised,
                side: BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                label: Text(
                  '+ ${food.name.id} (${food.proteinG.toStringAsFixed(0)}g)',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
                onPressed: () => _addQuickProtein(food),
              );
            }).toList(),
          ),

          if (recommendations.isNotEmpty && remaining > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.iceCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.iceCyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.iceCyan, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Saran hemat: ${recommendations.first.items.map((i) => '${i.portion} ${i.food.name.id}').join(' + ')} (±${recommendations.first.totalProtein.toStringAsFixed(0)}g)',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.iceCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseListItem(Exercise exercise, WorkoutItem? item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseDetailScreen(exercise: exercise),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.electricLime,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name.id,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.primaryMuscles.map((m) => m.id).join(', '),
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textDim),
                  ),
                ],
              ),
            ),
            if (item != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.isDurationBased
                      ? '${item.sets} x ${item.durationSec}s'
                      : '${item.sets} x ${item.reps}',
                  style: AppTypography.tabularMetricSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textDim, size: 20),
          ],
        ),
      ),
    );
  }
}

