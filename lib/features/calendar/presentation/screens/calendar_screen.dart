import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/data/datasources/program_local_datasource.dart';
import '../../../program/data/repositories/program_repository_impl.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../workout_session/presentation/screens/workout_session_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _programRepo = ProgramRepositoryImpl(ProgramLocalDatasource());
  final _exerciseRepo = ExerciseRepositoryImpl(ExerciseLocalDatasource());

  List<ProgramDay> _allDays = [];
  Map<String, Exercise> _exercisesMap = {};
  int _currentDay = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgram();
  }

  Future<void> _loadProgram() async {
    final days = await _programRepo.get30DaysProgram();
    final exercises = await _exerciseRepo.getExercises();
    final curDay = await _programRepo.getCurrentProgramDay();

    if (mounted) {
      setState(() {
        _allDays = days;
        _exercisesMap = {for (final e in exercises) e.id: e};
        _currentDay = curDay;
        _isLoading = false;
      });
    }
  }

  void _showDayDetailsSheet(ProgramDay day) {
    final isToday = day.day == _currentDay;
    final color = AppColors.forWorkoutCode(day.type.code);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color),
                        ),
                        child: Text(
                          day.type.code,
                          style: AppTypography.labelLarge.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'HARI ${day.day} / 30',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.electricLime.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'HARI INI',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.electricLime,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                day.focus.id,
                style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
              ),

              const SizedBox(height: 16),

              if (day.isRest)
                Text(
                  'Hari istirahat pemulihan. Tubuh Anda beradaptasi dan membangun kekuatan di saat istirahat.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                )
              else ...[
                Text(
                  'Daftar Gerakan Target:',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textDim),
                ),
                const SizedBox(height: 8),
                ...day.items.map((item) {
                  final ex = _exercisesMap[item.exerciseId];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ex?.name.id ?? item.exerciseId,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        ),
                        Text(
                          item.isDurationBased
                              ? '${item.sets} x ${item.durationSec}s'
                              : '${item.sets} x ${item.reps}',
                          style: AppTypography.tabularMetricSmall.copyWith(
                            color: AppColors.electricLime,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),

              if (!day.isRest)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricLime,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      final resolvedExercises = day.items
                          .map((i) => _exercisesMap[i.exerciseId])
                          .whereType<Exercise>()
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutSessionScreen(
                            day: day,
                            exercises: resolvedExercises,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'MULAI SESI HARI ${day.day}',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: Text(
          'PROGRAM 30 HARI',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Split Pattern Legend
            _buildLegend(),

            const SizedBox(height: 20),

            // 7-Column Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'].map((dayName) {
                return SizedBox(
                  width: 44,
                  child: Center(
                    child: Text(
                      dayName,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textDim,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // 30 Days Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: _allDays.length,
              itemBuilder: (context, index) {
                final day = _allDays[index];
                final isToday = day.day == _currentDay;
                final isPassed = day.day < _currentDay;
                final color = AppColors.forWorkoutCode(day.type.code);

                return GestureDetector(
                  onTap: () => _showDayDetailsSheet(day),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.electricLime.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday
                            ? AppColors.electricLime
                            : color.withValues(alpha: 0.35),
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: AppTypography.bodySmall.copyWith(
                            color: isToday ? AppColors.electricLime : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isPassed
                                ? Icon(Icons.check, size: 14, color: AppColors.electricLime)
                                : Text(
                                    day.type.code,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Milestone Banner (Day 15 & Day 30 Re-test)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.iceCyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_circle_outlined, color: AppColors.iceCyan, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TES EVALUASI BERKALA',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.iceCyan,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hari ke-15 dan ke-30 akan menawarkan tes ulang kemampuan fisik untuk mengkalibrasi target beban Anda.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem('P', 'Dorong', AppColors.pushWorkout),
          _legendItem('K', 'Kaki', AppColors.legsWorkout),
          _legendItem('C', 'Core', AppColors.coreWorkout),
          _legendItem('F', 'Full', AppColors.fullBodyWorkout),
          _legendItem('R', 'Rest', AppColors.restDay),
        ],
      ),
    );
  }

  Widget _legendItem(String code, String name, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          '$code:$name',
          style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textDim),
        ),
      ],
    );
  }
}

