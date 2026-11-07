import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class WeeklyDayProgress {
  final String dayName;
  final bool isCompleted;
  final bool isToday;

  const WeeklyDayProgress({
    required this.dayName,
    required this.isCompleted,
    this.isToday = false,
  });
}

/// Kartu "This Week's Progress" dengan 7 Hari Checklist & Circular Gauge (Referensi Baru 1:1)
class ThisWeeksProgressCard extends StatelessWidget {
  final int completedDays;
  final int targetDays;
  final int progressPercent;
  final List<WeeklyDayProgress> days;

  const ThisWeeksProgressCard({
    super.key,
    required this.completedDays,
    required this.targetDays,
    required this.progressPercent,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris: Judul Kiri + Counter Hari & Circular Gauge Kanan
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "This Week's Progress",
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: const Color(0xFF141718),
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$completedDays ',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF65A30D),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: 'of $targetDays days',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Circular Progress Ring (e.g. 75%)
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        value: (progressPercent / 100).clamp(0.0, 1.0),
                        strokeWidth: 5,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF84CC16),
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: const Color(0xFF141718),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Baris 7 Hari (Senin s/d Minggu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) => _buildDayItem(day)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(WeeklyDayProgress day) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lingkaran Centang / Abu-abu
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: day.isCompleted
                ? const Color(0xFF84CC16)
                : const Color(0xFFE5E7EB),
            border: day.isToday && !day.isCompleted
                ? Border.all(color: const Color(0xFF84CC16), width: 2)
                : null,
          ),
          child: Center(
            child: day.isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 17,
                  )
                : (day.isToday
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF84CC16),
                        ),
                      )
                    : null),
          ),
        ),

        const SizedBox(height: 6),

        // Nama Hari (Mon, Tue, etc.)
        Text(
          day.dayName,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 11,
            fontWeight: day.isToday ? FontWeight.w800 : FontWeight.w500,
            color: day.isToday ? const Color(0xFF141718) : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

