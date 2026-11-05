/// Service Logika Bisnis untuk Estimasi Kalori Terbakar (Application Layer)
class CalorieCalculatorService {
  const CalorieCalculatorService();

  /// Menghitung estimasi kalori terbakar berdasarkan durasi dan jumlah set
  /// Rata-rata latihan beban/kalistenik membakar ~6.5 - 8 kcal per menit.
  int calculateCaloriesBurned({
    required int durationSeconds,
    required int completedSets,
    double userWeightKg = 67.5,
  }) {
    final durationMinutes = durationSeconds / 60.0;
    if (durationMinutes <= 0) return 0;

    // MET (Metabolic Equivalent of Task) untuk latihan kekuatan kalistenik moderat ~ 5.5
    final met = 5.5;
    final calories = durationMinutes * (met * 3.5 * userWeightKg) / 200;

    // Tambahan pembakaran per set completed (~3 kcal/set)
    final setBonus = completedSets * 2.5;

    final total = (calories + setBonus).round();
    return total > 20 ? total : 45;
  }
}

