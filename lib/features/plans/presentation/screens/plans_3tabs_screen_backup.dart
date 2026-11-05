import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../widgets/plan_tab_bar.dart';
import '../widgets/tab_program_view.dart';
import '../widgets/tab_workouts_view.dart';
import '../widgets/tab_exercises_view.dart';

/// Halaman Workout Plan (Upgrade 3 Tab sesuai Mockup Desain):
/// 1. Tab Program: Hero Card "Bulking Program", Progress Bar 8 Minggu, "This Week" Schedule, & "Tip for Bulking"
/// 2. Tab Workouts: Week 1-8 Selector Pills, & Daftar Sesi Latihan Harian dengan tombol Play cepat
/// 3. Tab Exercises: Pencarian gerakan, Filter Kategori Otot, Ilustrasi Anatomi Merah, & Navigasi Detail Gerakan
class Plans3TabsScreenBackup extends StatefulWidget {
  final int initialTabIndex;

  const Plans3TabsScreenBackup({super.key, this.initialTabIndex = 0});

  @override
  State<Plans3TabsScreenBackup> createState() => _Plans3TabsScreenBackupState();
}

class _Plans3TabsScreenBackupState extends State<Plans3TabsScreenBackup> {
  late int _selectedTabIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _pageController = PageController(initialPage: _selectedTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF141718),
            size: 24,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Workout Plan',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF141718),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: PlanTabBar(
            selectedIndex: _selectedTabIndex,
            onTabChanged: _onTabChanged,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedTabIndex = index),
        children: const [
          TabProgramView(),
          TabWorkoutsView(),
          TabExercisesView(),
        ],
      ),
    );
  }
}
