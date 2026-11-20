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
    required this._repository,
    required this._bmiCalculator,
    required this._weightAnalytics,
    required this._userDatasource,
    required this._programsRepo,
  })  : super(const ProgressState()) {
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
      final heightCm = profile?.heightCm ?? 0;
      final profileWeight = profile?.currentWeightKg ?? 0;

      // 3. Ambil riwayat penimbangan
      final history = await _repository.getWeightHistory();
      final weightAnalysis = _weightAnalytics.analyze(
        history,
        defaultWeight: profileWeight,
      );

      // 4. Hitung BMI melalui Application Service
      final currentWeight = weightAnalysis.currentWeight;
      final hasBodyData = currentWeight > 0 && heightCm > 0;
      final bmi = hasBodyData
          ? _bmiCalculator.calculateBmi(weightKg: currentWeight, heightCm: heightCm)
          : 0.0;
      final bmiStatus = hasBodyData ? _bmiCalculator.getBmiStatus(bmi) : '';

      // 5. Ambil riwayat sesi latihan & aktivitas mingguan
      final recents = await _repository.getRecentWorkouts();
      final weekly = await _repository.getWeeklyActivity();
      final movementVol = await _repository.getMovementVolume();
      final milestones = await _repository.getProgressionMilestones();

      // 6. Ambil status program aktif
      final hasActiveProgram = await _programsRepo.hasActiveProgram();
      final activeProgram = hasActiveProgram
          ? await _programsRepo.getActiveProgram()
          : null;
      String programTitle = activeProgram == null
          ? ''
          : (activeProgram.title.en.isNotEmpty
              ? activeProgram.title.en
              : activeProgram.title.id);
      if (activeProgram != null && programTitle.trim().isEmpty) {
        programTitle = activeProgram.id
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
      }
      

      state = state.copyWith(
        metrics: metrics,
        currentWeight: currentWeight,
        weightHistory: history,
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
        hasActiveProgram: hasActiveProgram,
        activeProgramWeek: 0,
        activeProgramTotalWeeks: activeProgram?.totalWeeks ?? 0,
        activeProgramPercent: 0,
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

