import '../models/workout_program.dart';

abstract class ProgramsRepository {
  List<WorkoutProgram> getAllPrograms();
  WorkoutProgram? getProgramById(String id);
  Future<WorkoutProgram> getActiveProgram();
  Future<bool> hasActiveProgram();
  Future<void> setActiveProgram(String programId);
}
