import '../../domain/models/workout_program.dart';
import '../../domain/repositories/programs_repository.dart';
import '../datasources/programs_mock_datasource.dart';
import '../datasources/programs_supabase_datasource.dart';
import '../../../../core/database/app_database.dart';

/// Implementasi ProgramsRepository dengan strategi Offline-First:
/// Mengutamakan sinkronisasi Supabase saat online,
/// dan otomatis beralih ke local fallback saat offline atau sebelum connect.
class ProgramsRepositoryImpl implements ProgramsRepository {
  final ProgramsSupabaseDatasource remoteDatasource;
  final ProgramsMockDatasource localDatasource;
  final AppDatabase database;

  const ProgramsRepositoryImpl({
    this.remoteDatasource = const ProgramsSupabaseDatasource(),
    this.localDatasource = const ProgramsMockDatasource(),
    required this.database,
  });

  @override
  List<WorkoutProgram> getAllPrograms() {
    return localDatasource.getAllPrograms();
  }

  /// Mengambil daftar semua program dari Supabase (asinkron)
  Future<List<WorkoutProgram>> fetchAllProgramsFromRemote() async {
    return await remoteDatasource.fetchAllPrograms();
  }

  @override
  WorkoutProgram? getProgramById(String id) {
    return localDatasource.getProgramById(id);
  }

  @override
  Future<WorkoutProgram> getActiveProgram() async {
    final activeId = await database.getActiveProgramId();

    // Coba ambil dari Supabase terlebih dahulu
    final remoteProgram = await remoteDatasource.fetchProgramById(activeId);
    if (remoteProgram != null) {
      return remoteProgram;
    }

    return localDatasource.getProgramById(activeId) ?? localDatasource.getAllPrograms().first;
  }

  @override
  Future<void> setActiveProgram(String programId) async {
    await database.setActiveProgramId(programId);
  }
}
