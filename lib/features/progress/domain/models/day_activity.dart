/// Immutable Domain Model untuk durasi aktivitas latihan per hari (Senin - Minggu)
class DayActivity {
  final String day;
  final int minutes;

  const DayActivity({
    required this.day,
    required this.minutes,
  });

  DayActivity copyWith({
    String? day,
    int? minutes,
  }) {
    return DayActivity(
      day: day ?? this.day,
      minutes: minutes ?? this.minutes,
    );
  }
}

