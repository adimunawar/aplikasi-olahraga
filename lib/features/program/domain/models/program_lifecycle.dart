/// Siklus hidup sebuah program latihan.
///
/// Dipisahkan dari [currentWeek] karena nomor minggu hanya berguna sebagai
/// indeks tampilan. Status lifecycle menentukan apakah program masih berjalan,
/// sudah tuntas, atau berakhir tanpa diselesaikan.
enum ProgramLifecycle {
  /// Hari ini masih sebelum tanggal mulai program.
  notStarted,

  /// Program sedang berjalan sesuai durasinya.
  active,

  /// Semua sesi tuntas, atau program ditandai selesai di database.
  completed,

  /// Durasi program sudah habis tetapi masih ada sesi yang belum selesai.
  expired,
}

/// Ringkasan lifecycle program pada tanggal tertentu.
class ProgramLifecycleInfo {
  final ProgramLifecycle state;
  final DateTime startDate;

  /// Hari terakhir program (inklusif).
  final DateTime endDate;
  final int totalWeeks;

  /// Indeks minggu untuk UI, selalu di-clamp ke 1..[totalWeeks].
  final int currentWeek;
  final int completedSessions;
  final int totalSessions;

  /// Sisa hari program. 0 jika program belum mulai atau sudah berakhir.
  final int daysRemaining;

  const ProgramLifecycleInfo({
    required this.state,
    required this.startDate,
    required this.endDate,
    required this.totalWeeks,
    required this.currentWeek,
    required this.completedSessions,
    required this.totalSessions,
    required this.daysRemaining,
  });

  bool get isFinished =>
      state == ProgramLifecycle.completed || state == ProgramLifecycle.expired;

  bool get canStartWorkout => state == ProgramLifecycle.active;

  double get completionRate {
    if (totalSessions <= 0) return 0;
    return (completedSessions / totalSessions).clamp(0.0, 1.0);
  }

  @override
  String toString() =>
      'ProgramLifecycleInfo(state: ${state.name}, week: $currentWeek/'
      '$totalWeeks, $completedSessions/$totalSessions)';
}
