import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/program_day.dart';
import '../../domain/repositories/program_repository.dart';
import '../datasources/program_local_datasource.dart';

class ProgramRepositoryImpl implements ProgramRepository {
  final ProgramLocalDatasource _datasource;
  static const String _prefKeyCurrentDay = 'workout_current_day';

  ProgramRepositoryImpl(this._datasource);

  @override
  Future<List<ProgramDay>> get30DaysProgram() async {
    return _datasource.load30Days();
  }

  @override
  Future<ProgramDay?> getDay(int dayNumber) async {
    final days = await _datasource.load30Days();
    try {
      return days.firstWhere((d) => d.day == dayNumber);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> getCurrentProgramDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefKeyCurrentDay) ?? 1;
  }
}

