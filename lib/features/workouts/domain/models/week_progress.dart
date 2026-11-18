/// Status penyelesaian sebuah minggu program.
enum WeekStatus {
  /// Minggu yang sedang berjalan (selalu ditampilkan sebagai "Current").
  current,

  /// Semua sesi pada minggu tersebut selesai.
  completed,

  /// Sebagian sesi selesai.
  partial,

  /// Minggu sudah lewat tetapi tidak ada sesi yang selesai.
  missed,

  /// Minggu di depan (hanya pratinjau, belum bisa memulai workout).
  upcoming,

  /// Tidak ada sesi terjadwal pada minggu tersebut.
  empty,
}

/// Ringkasan progres satu minggu program.
class WeekProgress {
  final int weekNumber;
  final int completedSessions;
  final int totalSessions;
  final WeekStatus status;

  const WeekProgress({
    required this.weekNumber,
    required this.completedSessions,
    required this.totalSessions,
    required this.status,
  });

  /// 0.0 - 1.0, aman jika tidak ada sesi terjadwal.
  double get completionRate {
    if (totalSessions <= 0) return 0;
    return (completedSessions / totalSessions).clamp(0.0, 1.0);
  }

  @override
  String toString() =>
      'WeekProgress(week: $weekNumber, $completedSessions/$totalSessions, '
      'status: ${status.name})';
}
