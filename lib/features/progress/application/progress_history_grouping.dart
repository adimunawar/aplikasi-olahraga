/// Date grouping and parsing helpers for the Progress history timeline.
class ProgressHistoryGrouping {
  const ProgressHistoryGrouping();

  String groupFor(DateTime date, {required DateTime now}) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final daysAgo = today.difference(day).inDays;
    if (daysAgo >= 0 && daysAgo < 7) return 'This Week';
    if (daysAgo >= 7 && daysAgo < 14) return 'Last Week';
    return 'Earlier';
  }

  DateTime parseWorkoutDate(String value, {required DateTime now}) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'hari ini' || normalized == 'today') return now;
    if (normalized == 'kemarin' || normalized == 'yesterday') {
      return now.subtract(const Duration(days: 1));
    }
    final ago = RegExp(r'^(\d+) hari lalu').firstMatch(normalized);
    if (ago != null) return now.subtract(Duration(days: int.parse(ago.group(1)!)));
    final parts = value.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        final parsed = DateTime(year, month, day);
        if (parsed.year == year && parsed.month == month && parsed.day == day) return parsed;
      }
    }
    return DateTime(2000);
  }
}
