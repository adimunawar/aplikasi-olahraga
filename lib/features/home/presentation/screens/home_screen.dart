import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../../exercises/data/repositories/exercise_repository_impl.dart';
import '../../../program/domain/models/program_day.dart';
import '../../../program/data/datasources/program_local_datasource.dart';
import '../../../program/data/repositories/program_repository_impl.dart';
import '../../../workout_session/presentation/screens/workout_session_screen.dart';
import '../widgets/home_header.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/your_progress_section.dart';
import '../widgets/next_workout_section.dart';
import '../widgets/quick_access_section.dart';

/// Halaman Home Utama (v2) - Bersih, modular, dan terhubung ke Local Database.
class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToCalendar;
  final VoidCallback onNavigateToExercises;
  final VoidCallback onNavigateToNutrition;
  final VoidCallback? onNavigateToProgress;

  const HomeScreen({
    super.key,
    required this.onNavigateToCalendar,
    required this.onNavigateToExercises,
    required this.onNavigateToNutrition,
    this.onNavigateToProgress,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _programRepo = ProgramRepositoryImpl(ProgramLocalDatasource());
  final _exerciseRepo = ExerciseRepositoryImpl(ExerciseLocalDatasource());
  final _db = AppDatabase.instance;

  ProgramDay? _todayProgram;
  List<Exercise> _todayExercises = [];
  UserProfileEntity? _userProfile;
  int _completedWorkouts = 6;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  Future<void> _loadTodayData() async {
    final dayNum = await _programRepo.getCurrentProgramDay();
    final programDay = await _programRepo.getDay(dayNum);
    final allExercises = await _exerciseRepo.getExercises();
    final profile = await _db.getUserProfile();
    final completedCount = await _db.getCompletedSessionsCount();

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
        _userProfile = profile;
        if (completedCount > 0) {
          _completedWorkouts = completedCount;
        }
        _isLoading = false;
      });
    }
  }

  void _startWorkoutSession() {
    final day = _todayProgram;
    if (day != null && !day.isRest) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutSessionScreen(
            day: day,
            exercises: _todayExercises,
          ),
        ),
      );
    } else {
      widget.onNavigateToCalendar();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB8E66B)),
        ),
      );
    }

    final day = _todayProgram;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Sapaan "Hi, Adi 👋" & Notifikasi
              HomeHeader(
                userName: _userProfile?.displayName ?? 'Adi',
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Belum ada notifikasi baru.')),
                  );
                },
              ),

              const SizedBox(height: 28),

              // 2. Hero Banner: Bulking Program dengan Karakter Coach
              HomeHeroBanner(
                onStartToday: _startWorkoutSession,
              ),

              const SizedBox(height: 24),

              // 3. Your Progress: Workouts, Calories, Weight
              YourProgressSection(
                completedWorkouts: _completedWorkouts,
                currentWeightKg: _userProfile?.currentWeightKg ?? 67.5,
              ),

              const SizedBox(height: 24),

              // 4. Next Workout: Upper Body (A)
              NextWorkoutSection(
                programDay: day,
                exercises: _todayExercises,
                onStartWorkout: _startWorkoutSession,
              ),

              const SizedBox(height: 24),

              // 5. Quick Access: Workouts, Meal Plan, Progress, Learn
              QuickAccessSection(
                onWorkoutsTap: widget.onNavigateToCalendar,
                onMealPlanTap: widget.onNavigateToNutrition,
                onProgressTap: widget.onNavigateToProgress ?? () {},
                onLearnTap: widget.onNavigateToExercises,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

