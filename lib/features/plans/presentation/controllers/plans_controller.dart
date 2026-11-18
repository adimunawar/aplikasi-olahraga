import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../profile/data/datasources/user_supabase_datasource.dart';
import '../../../program/data/repositories/programs_repository_impl.dart';
import '../../../program/domain/models/workout_program.dart';
import 'plans_state.dart';

final plansProgramsRepositoryProvider = Provider<ProgramsRepositoryImpl>((ref) {
  return ProgramsRepositoryImpl(database: AppDatabase.instance);
});

final plansUserDatasourceProvider = Provider<UserSupabaseDatasource>((ref) {
  return const UserSupabaseDatasource();
});

final plansControllerProvider =
    StateNotifierProvider<PlansController, PlansState>((ref) {
  return PlansController(
    programsRepo: ref.watch(plansProgramsRepositoryProvider),
    userDatasource: ref.watch(plansUserDatasourceProvider),
    database: AppDatabase.instance,
  );
});

/// Riverpod Controller untuk Halaman Plans
class PlansController extends StateNotifier<PlansState> {
  final ProgramsRepositoryImpl _programsRepo;
  final UserSupabaseDatasource _userDatasource;
  final AppDatabase _database;

  PlansController({
    required this._programsRepo,
    required this._userDatasource,
    required this._database,
  })  : super(const PlansState()) {
    loadPrograms();
  }

  /// Memuat program aktif, daftar program lain, dan status progres hari
  Future<void> loadPrograms() async {
    state = state.copyWith(isLoading: true);
    try {
      final active = await _programsRepo.getActiveProgram();
      final all = await _programsRepo.fetchAllProgramsFromRemote();
      final others = all.where((p) => p.id != active.id).toList();

      final completedDays = await _database.getCompletedDayNumbers(active.id);

      final totalWorkouts = active.totalWeeks * active.daysPerWeek;
      final progress = totalWorkouts > 0
          ? (completedDays.length / totalWorkouts).clamp(0.0, 1.0)
          : 0.37;

      state = state.copyWith(
        activeProgram: active,
        otherPrograms: others,
        completedDayNumbers: completedDays,
        currentWeek: 3,
        selectedWeekNumber: state.selectedWeekNumber,
        progressPercent: progress,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat program: $e',
      );
    }
  }

  /// Mengubah minggu yang sedang ditampilkan di jadwal (Week 1 s.d. Week N)
  void selectWeek(int weekNumber) {
    state = state.copyWith(selectedWeekNumber: weekNumber);
  }

  /// Mengganti program aktif pengguna
  Future<void> switchActiveProgram(WorkoutProgram program) async {
    try {
      await _programsRepo.setActiveProgram(program.id);
      await _userDatasource.updateActiveProgram(program.id);
      await loadPrograms();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal mengganti program: $e');
      rethrow;
    }
  }
}
