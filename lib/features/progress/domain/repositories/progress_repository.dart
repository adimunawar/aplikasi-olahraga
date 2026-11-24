import '../models/progress_metrics.dart';
import '../models/weight_record.dart';
import '../models/workout_history_item.dart';
import '../models/day_activity.dart';
import '../models/movement_volume_data.dart';
import '../models/progression_milestone.dart';

/// Abstract Contract untuk repositori progres & analitik latihan.
/// Lapisan Domain tidak bergantung pada Flutter UI atau implementasi database spesifik.
abstract class ProgressRepository {
  /// Mengambil metrik utama latihan (jumlah workout, total kalori, menit, streak)
  Future<ProgressMetrics> getMetrics();

  /// Mengambil riwayat catatan berat badan berurutan dari waktu ke waktu
  Future<List<WeightRecord>> getWeightHistory();

  /// Mengambil daftar riwayat sesi latihan terbaru yang telah selesai
  Future<List<WorkoutHistoryItem>> getRecentWorkouts({int limit = 5});

  /// Mengambil durasi latihan per hari dalam seminggu (Mon - Sun)
  Future<List<DayActivity>> getWeeklyActivity();

  /// Mengambil akumulasi volume latihan mingguan (Sets & Reps) per movement pattern
  Future<List<MovementVolumeData>> getMovementVolume();

  /// Mengambil daftar rekomendasi keputusan adaptasi terbaru dari Coach Adi untuk milestone
  Future<List<ProgressionMilestone>> getProgressionMilestones({int limit = 5});

  /// Mencatat entri penimbangan berat badan baru ke database lokal & cloud
  Future<void> recordWeight(double weightKg);
}

