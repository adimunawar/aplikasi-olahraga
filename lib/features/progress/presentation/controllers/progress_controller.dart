import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
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

final progressControllerProvider =
    StateNotifierProvider<ProgressController, ProgressState>((ref) {
  return ProgressController(
    repository: ref.watch(progressRepositoryProvider),
    bmiCalculator: ref.watch(bmiCalculatorServiceProvider),
    weightAnalytics: ref.watch(weightAnalyticsServiceProvider),
    database: AppDatabase.instance,
  );
});

/// Controller untuk orkestrasi State Halaman Progress (Riverpod StateNotifier)
class ProgressController extends StateNotifier<ProgressState> {
  final ProgressRepository _repository;
  final BmiCalculatorService _bmiCalculator;
  final WeightAnalyticsService _weightAnalytics;
  final AppDatabase _database;

  ProgressController({
    required ProgressRepository repository,
    required BmiCalculatorService bmiCalculator,
    required WeightAnalyticsService weightAnalytics,
    required AppDatabase database,
  })  : _repository = repository,
        _bmiCalculator = bmiCalculator,
        _weightAnalytics = weightAnalytics,
        _database = database,
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
      // Profil onboarding bersifat local-first sampai user melakukan sync.
      // Jangan bergantung pada Supabase untuk data awal Progress.
      final profile = await _database.getUserProfile();
      final heightCm = profile.heightCm;
      final profileWeight = profile.currentWeightKg;

      // 3. Ambil riwayat penimbangan. Berat awal dari onboarding perlu
      // dijadikan baseline agar grafik punya titik pertama sebelum user
      // mencatat penimbangan berikutnya.
      var history = await _repository.getWeightHistory();
      if (history.isEmpty && profileWeight > 0) {
        await _database.recordBodyWeight(profileWeight);
        history = await _repository.getWeightHistory();
      }
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

      // 6. Ambil program hasil generator dari local-first database.
      // Program onboarding disimpan ke training_programs, bukan user_programs.
      final localProfile = await _database.getUserProfile();
      final userId = localProfile.id.isNotEmpty ? localProfile.id : 'default_user';
      var activeProgram = await _database.getActiveTrainingProgram(userId);
      activeProgram ??= await _database.getActiveTrainingProgram('default_user');

      final hasActiveProgram = activeProgram != null;
      final programTitle = activeProgram?.name ?? '';
      final totalProgramWeeks = activeProgram?.durationWeeks ?? 0;
      final elapsedDays = activeProgram == null
          ? 0
          : DateTime.now()
                .difference(DateTime(
                  activeProgram.startDate.year,
                  activeProgram.startDate.month,
                  activeProgram.startDate.day,
                ))
                .inDays;
      final activeProgramWeek = activeProgram == null
          ? 0
          : ((elapsedDays < 0 ? 0 : elapsedDays) ~/ 7) + 1;
      final clampedProgramWeek = totalProgramWeeks > 0
          ? activeProgramWeek.clamp(1, totalProgramWeeks).toInt()
          : activeProgramWeek;
      final activeProgramPercent = totalProgramWeeks > 0
          ? ((clampedProgramWeek / totalProgramWeeks) * 100).round()
          : 0;


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
        activeProgramWeek: clampedProgramWeek,
        activeProgramTotalWeeks: totalProgramWeeks,
        activeProgramPercent: activeProgramPercent,
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

