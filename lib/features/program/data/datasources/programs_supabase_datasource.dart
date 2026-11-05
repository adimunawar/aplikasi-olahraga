import 'package:flutter/foundation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/models/workout_program.dart';
import 'programs_mock_datasource.dart';

/// Data source program latihan berbasis Supabase (Headless CMS):
/// Mengambil data program langsung dari Supabase saat online,
/// dan otomatis fallback ke local mock / SQLite saat offline.
class ProgramsSupabaseDatasource {
  final ProgramsMockDatasource fallbackDatasource;

  const ProgramsSupabaseDatasource({
    this.fallbackDatasource = const ProgramsMockDatasource(),
  });

  /// Mengambil semua program aktif dari tabel 'programs' di Supabase
  Future<List<WorkoutProgram>> fetchAllPrograms() async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return fallbackDatasource.getAllPrograms();
    }

    try {
      final response = await client
          .from('programs')
          .select('''
            *,
            program_weeks (
              *,
              program_days (
                *,
                program_day_exercises (*)
              )
            )
          ''')
          .eq('is_published', true)
          .order('created_at', ascending: false);

      final List<dynamic> dataList = response as List<dynamic>;
      if (dataList.isEmpty) {
        return fallbackDatasource.getAllPrograms();
      }

      return dataList.map((item) {
        final p = WorkoutProgram.fromJson(Map<String, dynamic>.from(item));
        if (p.weeks.isNotEmpty) return p;
        final mock = fallbackDatasource.getProgramById(p.id);
        return mock != null ? p.copyWith(weeks: mock.weeks) : p;
      }).toList();
    } catch (e) {
      debugPrint('[Supabase] Error fetching programs: $e. Menggunakan cache/fallback lokal.');
      return fallbackDatasource.getAllPrograms();
    }
  }

  /// Mengambil detail satu program spesifik berdasarkan ID
  Future<WorkoutProgram?> fetchProgramById(String programId) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return fallbackDatasource.getProgramById(programId);
    }

    try {
      final response = await client
          .from('programs')
          .select('''
            *,
            program_weeks (
              *,
              program_days (
                *,
                program_day_exercises (*)
              )
            )
          ''')
          .eq('id', programId)
          .maybeSingle();

      if (response != null) {
        final program = WorkoutProgram.fromJson(Map<String, dynamic>.from(response));
        if (program.weeks.isNotEmpty) {
          return program;
        }
        final mock = fallbackDatasource.getProgramById(programId);
        return mock != null ? program.copyWith(weeks: mock.weeks) : program;
      }
      return fallbackDatasource.getProgramById(programId);
    } catch (e) {
      debugPrint('[Supabase] Error fetching program $programId: $e');
      return fallbackDatasource.getProgramById(programId);
    }
  }
}

