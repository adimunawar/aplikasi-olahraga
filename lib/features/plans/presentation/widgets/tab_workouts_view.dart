import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import 'week_pills_selector.dart';
import 'workout_day_card.dart';

/// Tab 2: Workouts View
/// Menampilkan kurasi menu latihan mingguan (Week 1 - 8) dengan aksi mulai sesi cepat (Play button).
class TabWorkoutsView extends StatefulWidget {
  const TabWorkoutsView({super.key});

  @override
  State<TabWorkoutsView> createState() => _TabWorkoutsViewState();
}

class _TabWorkoutsViewState extends State<TabWorkoutsView> {
  int _selectedWeek = 3;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Week 3 ∨" & "4 Workouts"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _showWeekPicker,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Week $_selectedWeek',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: const Color(0xFF141718),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF141718),
                      size: 24,
                    ),
                  ],
                ),
              ),
              Text(
                '4 Workouts',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal Week Pills
          WeekPillsSelector(
            selectedWeek: _selectedWeek,
            onWeekChanged: (w) => setState(() => _selectedWeek = w),
          ),
          const SizedBox(height: 18),

          // 4 Kartu Sesi Latihan
          WorkoutDayCard(
            dayNumber: (_selectedWeek - 1) * 4 + 1,
            title: 'Day 1 - Upper Body (A)',
            targetMuscles: 'Chest • Back • Shoulder • Arms',
            durationText: '45 min',
            levelText: 'Intermediate',
            thumbnailAsset: 'assets/images/Detail Gerakan.png',
          ),
          const SizedBox(height: 12),

          WorkoutDayCard(
            dayNumber: (_selectedWeek - 1) * 4 + 2,
            title: 'Day 2 - Lower Body (A)',
            targetMuscles: 'Legs • Glutes • Calves',
            durationText: '50 min',
            levelText: 'Intermediate',
            thumbnailAsset: 'assets/images/Hari Ini.png',
          ),
          const SizedBox(height: 12),

          WorkoutDayCard(
            dayNumber: (_selectedWeek - 1) * 4 + 3,
            title: 'Day 3 - Upper Body (B)',
            targetMuscles: 'Back • Chest • Arms • Shoulder',
            durationText: '45 min',
            levelText: 'Intermediate',
            thumbnailAsset: 'assets/images/Kalender 30 Hari.png',
          ),
          const SizedBox(height: 12),

          WorkoutDayCard(
            dayNumber: (_selectedWeek - 1) * 4 + 4,
            title: 'Day 4 - Lower Body (B)',
            targetMuscles: 'Legs • Glutes • Core',
            durationText: '50 min',
            levelText: 'Intermediate',
            thumbnailAsset: 'assets/images/Home Workout Push-Up Guide.png',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showWeekPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Pilih Minggu Latihan',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 8,
                itemBuilder: (_, index) {
                  final week = index + 1;
                  final isCurrent = week == _selectedWeek;
                  return ListTile(
                    title: Text('Week $week'),
                    trailing: isCurrent
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF65A30D))
                        : null,
                    onTap: () {
                      setState(() => _selectedWeek = week);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

