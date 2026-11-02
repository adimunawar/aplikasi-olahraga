import '../models/program_day.dart';

abstract class ProgramRepository {
  Future<List<ProgramDay>> get30DaysProgram();
  Future<ProgramDay?> getDay(int dayNumber);
  Future<int> getCurrentProgramDay();
}

