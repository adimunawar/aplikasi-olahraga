import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/exercise.dart';
import '../../data/datasources/exercise_local_datasource.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../../exercise_detail/presentation/screens/exercise_detail_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final _exerciseRepo = ExerciseRepositoryImpl(ExerciseLocalDatasource());
  List<Exercise> _allExercises = [];
  ExerciseCategory? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final list = await _exerciseRepo.getExercises();
    if (mounted) {
      setState(() {
        _allExercises = list;
        _isLoading = false;
      });
    }
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

    final filteredExercises = _selectedCategory == null
        ? _allExercises
        : _allExercises.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: Text(
          'KATALOG GERAKAN',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(null, 'Semua (${_allExercises.length})'),
                const SizedBox(width: 8),
                _buildFilterChip(ExerciseCategory.push, 'Dorong (Push)'),
                const SizedBox(width: 8),
                _buildFilterChip(ExerciseCategory.legs, 'Kaki (Legs)'),
                const SizedBox(width: 8),
                _buildFilterChip(ExerciseCategory.core, 'Core'),
                const SizedBox(width: 8),
                _buildFilterChip(ExerciseCategory.fullBody, 'Full Body'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Exercise List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: filteredExercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ex = filteredExercises[index];
                return _buildExerciseCard(ex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ExerciseCategory? cat, String label) {
    final isSelected = _selectedCategory == cat;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedCategory = cat),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.electricLime,
      side: BorderSide(
        color: isSelected ? AppColors.electricLime : AppColors.divider,
      ),
      label: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: isSelected ? Colors.black : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise ex) {
    final diffColor = ex.difficulty == ExerciseDifficulty.beginner
        ? AppColors.electricLime
        : ex.difficulty == ExerciseDifficulty.advanced
            ? AppColors.coral
            : AppColors.warmAmber;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseDetailScreen(exercise: ex),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.electricLime,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ex.name.id,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ex.difficulty.localizedName('id'),
                          style: AppTypography.labelSmall.copyWith(
                            color: diffColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Target: ${ex.primaryMuscles.map((m) => m.id).join(', ')}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textDim),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textDim, size: 22),
          ],
        ),
      ),
    );
  }
}

