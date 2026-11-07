import 'package:flutter/material.dart';

class DayScheduleItem {
  final String key;
  final String label;

  const DayScheduleItem({required this.key, required this.label});
}

const List<DayScheduleItem> kWeekDays = [
  DayScheduleItem(key: 'monday', label: 'Mon'),
  DayScheduleItem(key: 'tuesday', label: 'Tue'),
  DayScheduleItem(key: 'wednesday', label: 'Wed'),
  DayScheduleItem(key: 'thursday', label: 'Thu'),
  DayScheduleItem(key: 'friday', label: 'Fri'),
  DayScheduleItem(key: 'saturday', label: 'Sat'),
  DayScheduleItem(key: 'sunday', label: 'Sun'),
];

/// Kartu "Your Schedule" sesuai desain mockup
/// Menampilkan jadwal hari latihan & istirahat mingguan
class YourScheduleCard extends StatelessWidget {
  final List<String> availableDays;
  final int weeklyWorkouts;
  final VoidCallback onEditSchedule;

  const YourScheduleCard({
    super.key,
    required this.availableDays,
    required this.weeklyWorkouts,
    required this.onEditSchedule,
  });

  bool _isTrainingDay(String dayKey) {
    return availableDays.any((d) => d.toLowerCase() == dayKey.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final workoutsCount = weeklyWorkouts > 0
        ? weeklyWorkouts
        : availableDays.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Calendar Icon + Title + Edit Schedule Button
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFF141718),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF141718),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your selected training days • $workoutsCount workouts / week',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Edit Schedule Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEditSchedule,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8D2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 13,
                        color: Color(0xFF3F6212),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Edit Schedule',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3F6212),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 7 Days Strip (Mon - Sun)
        Row(
          children: kWeekDays.map((day) {
            final isTrain = _isTrainingDay(day.key);

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isTrain ? const Color(0xFFE4F8A6) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: isTrain
                      ? null
                      : Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTrain
                          ? Icons.directions_run_rounded
                          : Icons.nightlight_round,
                      size: 18,
                      color: isTrain
                          ? const Color(0xFF141718)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF141718),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTrain ? 'Train' : 'Rest',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isTrain ? FontWeight.w700 : FontWeight.w500,
                        color: isTrain
                            ? const Color(0xFF3F6212)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
