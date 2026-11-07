import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../profile/data/datasources/user_supabase_datasource.dart';
import '../../../program/data/repositories/programs_repository_impl.dart';
import '../../../program/domain/repositories/programs_repository.dart';
import '../../application/bmi_calculator_service.dart';
import '../../application/weight_analytics_service.dart';
import '../../data/datasources/progress_supabase_datasource.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/repositories/progress_repository.dart';
import 'progress_state.dart';

// --- Dependency Injection Providers ---
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl(
    remoteDatasource: const ProgressSupabaseDatasource(),
    localDatabase: AppDatabase.instance,
  );
});

final bmiCalculatorServiceProvider = Provider<BmiCalculatorService>((ref) {
  return const BmiCalculatorService();
});

final weightAnalyticsServiceProvider = Provider<WeightAnalyticsService>((ref) {
  return const WeightAnalyticsService();
});

final userProfileDatasourceProvider = Provider<UserSupabaseDatasource>((ref) {
  return const UserSupabaseDatasource();
});

final programsRepositoryProvider = Provider<ProgramsRepository>((ref) {
  return ProgramsRepositoryImpl(database: AppDatabase.instance);
});

final progressControllerProvider =
    StateNotifierProvider<ProgressController, ProgressState>((ref) {
  return ProgressController(
    repository: ref.watch(progressRepositoryProvider),
    bmiCalculator: ref.watch(bmiCalculatorServiceProvider),
    weightAnalytics: ref.watch(weightAnalyticsServiceProvider),
    userDatasource: ref.watch(userProfileDatasourceProvider),
    programsRepo: ref.watch(programsRepositoryProvider),
  );
});

/// Controller untuk orkestrasi State Halaman Progress (Riverpod StateNotifier)
class ProgressController extends StateNotifier<ProgressState> {
  final ProgressRepository _repository;
  final BmiCalculatorService _bmiCalculator;
  final WeightAnalyticsService _weightAnalytics;
  final UserSupabaseDatasource _userDatasource;
  final ProgramsRepository _programsRepo;

  ProgressController({
    required ProgressRepository repository,
    required BmiCalculatorService bmiCalculator,
    required WeightAnalyticsService weightAnalytics,
    required UserSupabaseDatasource userDatasource,
    required ProgramsRepository programsRepo,
  })  : _repository = repository,
        _bmiCalculator = bmiCalculator,
        _weightAnalytics = weightAnalytics,
        _userDatasource = userDatasource,
        _programsRepo = programsRepo,
        super(const ProgressState()) {
    loadProgress();
  }

  /// Memuat dan menyinkronkan data progres secara asinkron
  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true);
    try {
      // 1. Ambil data metrik utama
      final metrics = await _repository.getMetrics();

      // 2. Ambil data profil (tinggi dan berat badan)
      final profile = await _userDatasource.fetchProfileFromSupabase();
      final heightCm = profile?.heightCm ?? state.heightCm;
      final profileWeight = profile?.currentWeightKg ?? state.currentWeight;

      // 3. Ambil riwayat penimbangan
      final history = await _repository.getWeightHistory();
      final weightAnalysis = _weightAnalytics.analyze(
        history,
        defaultWeight: profileWeight,
      );

      // 4. Hitung BMI melalui Application Service
      final currentWeight = weightAnalysis.currentWeight;
      final bmi = _bmiCalculator.calculateBmi(weightKg: currentWeight, heightCm: heightCm);
      final bmiStatus = _bmiCalculator.getBmiStatus(bmi);

      // 5. Ambil riwayat sesi latihan & aktivitas mingguan
      final recents = await _repository.getRecentWorkouts();
      final weekly = await _repository.getWeeklyActivity();
      final movementVol = await _repository.getMovementVolume();
      final milestones = await _repository.getProgressionMilestones();

      // 6. Ambil status program aktif
      final activeProgram = await _programsRepo.getActiveProgram();
      String programTitle = activeProgram.title.en.isNotEmpty
          ? activeProgram.title.en
          : activeProgram.title.id;
      if (programTitle.trim().isEmpty) {
        programTitle = activeProgram.id
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
      }
      if (programTitle.isEmpty) programTitle = 'Upper Body Strength';

      state = state.copyWith(
        metrics: metrics,
        currentWeight: currentWeight,
        heightCm: heightCm,
        weightChange: weightAnalysis.weightChange,
        startLabel: weightAnalysis.startLabel,
        endLabel: weightAnalysis.endLabel,
        bmiValue: bmi,
        bmiStatus: bmiStatus,
        recentWorkouts: recents,
        weeklyActivity: weekly,
        movementVolume: movementVol,
        milestones: milestones,
        activeProgramTitle: programTitle,
        activeProgramWeek: 3,
        activeProgramTotalWeeks: activeProgram.totalWeeks,
        activeProgramPercent: 37,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat progres: $e',
      );
    }
  }

  /// Alias untuk loadProgress
  Future<void> loadAllProgressData() => loadProgress();

  /// Mencatat penimbangan berat badan baru
  Future<void> recordWeight(double newWeight) async {
    try {
      await _repository.recordWeight(newWeight);
      // Reload setelah pencatatan berhasil
      await loadProgress();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal mencatat berat badan: $e');
    }
  }
}

