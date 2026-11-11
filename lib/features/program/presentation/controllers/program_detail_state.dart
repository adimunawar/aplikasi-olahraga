import 'package:flutter/foundation.dart';
import '../../domain/models/workout_program.dart';

/// State immutable untuk layar Program Detail (sesuai architecture.md)
@immutable
class ProgramDetailState {
  final WorkoutProgram program;
  final int selectedWeek;
  final bool isLoading;
  final bool isStartingProgram;
  final bool isCurrentActive;
  final String? errorMessage;

  const ProgramDetailState({
    required this.program,
    this.selectedWeek = 1,
    this.isLoading = false,
    this.isStartingProgram = false,
    this.isCurrentActive = false,
    this.errorMessage,
  });

  ProgramDetailState copyWith({
    WorkoutProgram? program,
    int? selectedWeek,
    bool? isLoading,
    bool? isStartingProgram,
    bool? isCurrentActive,
    String? errorMessage,
  }) {
    return ProgramDetailState(
      program: program ?? this.program,
      selectedWeek: selectedWeek ?? this.selectedWeek,
      isLoading: isLoading ?? this.isLoading,
      isStartingProgram: isStartingProgram ?? this.isStartingProgram,
      isCurrentActive: isCurrentActive ?? this.isCurrentActive,
      errorMessage: errorMessage,
    );
  }
}

