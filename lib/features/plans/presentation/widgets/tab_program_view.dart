import 'package:flutter/material.dart';
import 'program_hero_banner.dart';
import 'program_progress_card.dart';
import 'program_week_schedule_section.dart';
import 'bulking_tip_card.dart';

/// Tab 1: Program View
/// Menampilkan ringkasan program yang sedang berjalan (Bulking Program),
/// kemajuan program 8 minggu, jadwal latihan minggu ini, dan tips nutrisi/bulking.
class TabProgramView extends StatelessWidget {
  const TabProgramView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // 1. Hero Card "Bulking Program"
          ProgramHeroBanner(),
          SizedBox(height: 20),

          // 2. Program Progress Bar
          ProgramProgressCard(
            currentWeek: 3,
            totalWeeks: 8,
            progressPercent: 0.37,
          ),
          SizedBox(height: 22),

          // 3. This Week Schedule List
          ProgramWeekScheduleSection(),
          SizedBox(height: 22),

          // 4. Tip for Bulking Card
          BulkingTipCard(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

