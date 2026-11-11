import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../exercises/data/datasources/exercise_local_datasource.dart';
import '../../data/datasources/programs_mock_datasource.dart';
import '../../domain/services/dynamic_program_generator.dart';
import 'program_detail_state.dart';

/// Provider Family untuk ProgramDetailController berdasarkan programId
final programDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<ProgramDetailController, ProgramDetailState, String>((ref, programId) {
  return ProgramDetailController(
    programId: programId,
    database: AppDatabase.instance,
    mockDatasource: const ProgramsMockDatasource(),
  );
});

class ProgramDetailController extends StateNotifier<ProgramDetailState> {
  final String _programId;
  final AppDatabase _database;
  final ProgramsMockDatasource _mockDatasource;

  ProgramDetailController({
    required String programId,
    required AppDatabase database,
    required ProgramsMockDatasource mockDatasource,
  })  : _programId = programId,
        _database = database,
        _mockDatasource = mockDatasource,
        super(
          ProgramDetailState(
            program: mockDatasource.getProgramById(programId) ??
                mockDatasource.getAllPrograms().first,
            isLoading: true,
          ),
        ) {
    _init();
  }

  Future<void> _init() async {
    try {
      final program = _mockDatasource.getProgramById(_programId) ??
          _mockDatasource.getAllPrograms().first;
      final activeProgramId = await _database.getActiveProgramId();
      final isCurrentActive = activeProgramId == program.id;

      state = state.copyWith(
        program: program,
        isLoading: false,
        isCurrentActive: isCurrentActive,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectWeek(int week) {
    if (week < 1 || week > state.program.totalWeeks) return;
    state = state.copyWith(selectedWeek: week);
  }

  /// Mengaktifkan program ini sebagai program utama pengguna
  Future<bool> startProgram() async {
    state = state.copyWith(isStartingProgram: true);
    try {
      final program = state.program;

      // 1. Set active program ID di database
      await _database.setActiveProgramId(program.id);

      // 2. Update user profile goal jika sesuai
      final profile = await _database.getUserProfile();
      String mappedGoal = profile.goal;
      if (program.id.contains('strength')) {
        mappedGoal = 'strength';
      } else if (program.id.contains('fat_loss')) {
        mappedGoal = 'fat_loss';
      } else {
        mappedGoal = 'muscle_gain';
      }

      final updatedProfile = profile.copyWith(
        goal: mappedGoal,
        weeklyFrequency: program.daysPerWeek,
      );
      await _database.saveUserProfile(updatedProfile);

      // 3. Sinkronkan kurikulum dinamis ke database
      final exerciseDatasource = ExerciseLocalDatasource(db: _database);
      final catalog = await exerciseDatasource.loadExercises();
      final startingPushId = updatedProfile.experienceLevel == 'advanced'
          ? 'diamond_push_up'
          : updatedProfile.experienceLevel == 'intermediate'
              ? 'push_up'
              : 'knee_push_up';

      final generated = const DynamicProgramGenerator().generate(
        userProfile: updatedProfile,
        catalogExercises: catalog,
        startingPushExerciseId: startingPushId,
      );

      await _database.saveDynamicProgram(
        program: generated.program,
        sessions: generated.sessions,
      );

      state = state.copyWith(
        isStartingProgram: false,
        isCurrentActive: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isStartingProgram: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

