import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/day_activity.dart';

/// Card Grafik Aktivitas Latihan (Workout Activity) pada Halaman Progress:
/// - Header: "Workout Activity" dengan filter segmented [Week, Month, All]
/// - Sumbu Y: Skala waktu 0, 15 m, 30 m, 45 m, 60 m
/// - Batang Bar Hijau Lime untuk hari aktif & dash abu-abu untuk hari istirahat
class WorkoutActivityChartCard extends StatefulWidget {
  final List<DayActivity>? weeklyData;

  const WorkoutActivityChartCard({super.key, this.weeklyData});

  @override
  State<WorkoutActivityChartCard> createState() => _WorkoutActivityChartCardState();
}

class _WorkoutActivityChartCardState extends State<WorkoutActivityChartCard> {
  int _selectedFilter = 0; // 0: Week, 1: Month, 2: All
  static const _filters = ['Week', 'Month', 'All'];

  List<DayActivity> get _displayData {
    if (widget.weeklyData != null && widget.weeklyData!.isNotEmpty) {
      return widget.weeklyData!;
    }
    return const [
      DayActivity(day: 'Mon', minutes: 35),
      DayActivity(day: 'Tue', minutes: 52),
      DayActivity(day: 'Wed', minutes: 38),
      DayActivity(day: 'Thu', minutes: 48),
      DayActivity(day: 'Fri', minutes: 0),
      DayActivity(day: 'Sat', minutes: 0),
      DayActivity(day: 'Sun', minutes: 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Judul & Segmented Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    size: 20,
                    color: AppColors.darkCharcoal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Workout Activity',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
              _buildFilterPills(),
            ],
          ),
          const SizedBox(height: 20),

          // Area Grafik dengan Sumbu Y & Bar
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sumbu Y Skala Waktu
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _YLabelText('60 m'),
                    _YLabelText('45 m'),
                    _YLabelText('30 m'),
                    _YLabelText('15 m'),
                    _YLabelText('0'),
                  ],
                ),
                const SizedBox(width: 14),

                // Area 7 Kolom Batang
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _displayData.map((data) => _buildDayBar(data)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.cardBorder,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.limeAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _filters[index],
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.darkCharcoal : AppColors.neutral500,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayBar(DayActivity data) {
    const double maxChartMinutes = 60.0;
    const double barMaxHeight = 108.0;

    final hasActivity = data.minutes > 0;
    final barHeight = (data.minutes / maxChartMinutes * barMaxHeight)
        .clamp(0.0, barMaxHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasActivity)
          Container(
            width: 26,
            height: barHeight,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
          )
        else
          Container(
            width: 22,
            height: 4,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(height: 10),
        Text(
          data.day,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.neutral500,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _YLabelText extends StatelessWidget {
  final String text;
  const _YLabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.neutral400,
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
