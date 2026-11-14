import 'package:flutter/foundation.dart';
import '../../../../core/database/models/dynamic_program_entity.dart';
import '../../../../core/database/models/user_profile_entity.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../../program/domain/models/program_day.dart';
import '../widgets/today_workout/today_workout_section.dart';
import '../widgets/weekly_progress_calendar_card.dart';

/// Jenis Error pada Halaman Home untuk diferensiasi penanganan error
enum HomeErrorType {
  none,
  database,
  programGeneration,
  network,
}

/// State representasi data lengkap untuk Halaman Home Utama
@immutable
class HomeState {
  final bool isLoading;
  final HomeErrorType errorType;
  final String? errorMessage;
  final String lastSyncedTime;

  final UserProfileEntity? userProfile;
  final TrainingProgramEntity? activeProgram;
  final ProgramDay? todayProgram;
  final List<Exercise> todayExercises;

  final String programTitle;
  final String sessionFocus;
  final String targetMuscles;
  final int sessionDurationMinutes;
  final int estimatedCalories;

  final int currentWeek;
  final int totalWeeks;
  final List<DayProgressData> weeklyDays;

  final WorkoutCardState workoutCardState;
  final bool hasProgram;
  final bool isTodayRestDay;
  final bool isCompletedToday;
  final DateTime? lastLoadedAt;

  const HomeState({
    this.isLoading = true,
    this.errorType = HomeErrorType.none,
    this.errorMessage,
    this.lastSyncedTime = 'Today, 10:30 AM',
    this.userProfile,
    this.activeProgram,
    this.todayProgram,
    this.todayExercises = const [],
    this.programTitle = 'Gain Weight & Build Muscle',
    this.sessionFocus = 'Upper Body (Push)',
    this.targetMuscles = 'Chest, Shoulders, Triceps',
    this.sessionDurationMinutes = 45,
    this.estimatedCalories = 280,
    this.currentWeek = 1,
    this.totalWeeks = 12,
    this.weeklyDays = const [],
    this.workoutCardState = WorkoutCardState.active,
    this.hasProgram = true,
    this.isTodayRestDay = false,
    this.isCompletedToday = false,
    this.lastLoadedAt,
  });

  HomeState copyWith({
    bool? isLoading,
    HomeErrorType? errorType,
    String? errorMessage,
    String? lastSyncedTime,
    UserProfileEntity? userProfile,
    TrainingProgramEntity? activeProgram,
    ProgramDay? todayProgram,
    List<Exercise>? todayExercises,
    String? programTitle,
    String? sessionFocus,
    String? targetMuscles,
    int? sessionDurationMinutes,
    int? estimatedCalories,
    int? currentWeek,
    int? totalWeeks,
    List<DayProgressData>? weeklyDays,
    WorkoutCardState? workoutCardState,
    bool? hasProgram,
    bool? isTodayRestDay,
    bool? isCompletedToday,
    DateTime? lastLoadedAt,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorType: errorType ?? this.errorType,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncedTime: lastSyncedTime ?? this.lastSyncedTime,
      userProfile: userProfile ?? this.userProfile,
      activeProgram: activeProgram ?? this.activeProgram,
      todayProgram: todayProgram ?? this.todayProgram,
      todayExercises: todayExercises ?? this.todayExercises,
      programTitle: programTitle ?? this.programTitle,
      sessionFocus: sessionFocus ?? this.sessionFocus,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      sessionDurationMinutes:
          sessionDurationMinutes ?? this.sessionDurationMinutes,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      currentWeek: currentWeek ?? this.currentWeek,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      workoutCardState: workoutCardState ?? this.workoutCardState,
      hasProgram: hasProgram ?? this.hasProgram,
      isTodayRestDay: isTodayRestDay ?? this.isTodayRestDay,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
    );
  }
}
