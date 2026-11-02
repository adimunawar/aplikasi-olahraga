import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../today/presentation/screens/today_screen.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';
import '../../../exercises/presentation/screens/exercise_list_screen.dart';
import '../../../nutrition/presentation/screens/nutrition_screen.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      TodayScreen(
        onNavigateToCalendar: () => _onTabTapped(1),
        onNavigateToExercises: () => _onTabTapped(2),
        onNavigateToNutrition: () => _onTabTapped(3),
      ),
      const CalendarScreen(),
      const ExerciseListScreen(),
      const NutritionScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.electricLime,
          unselectedItemColor: AppColors.textDim,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTypography.labelSmall,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.flash_on_rounded),
              activeIcon: Icon(Icons.flash_on_rounded, color: AppColors.electricLime),
              label: 'Hari Ini',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              activeIcon: Icon(Icons.calendar_month_rounded, color: AppColors.electricLime),
              label: 'Program',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              activeIcon: Icon(Icons.fitness_center_rounded, color: AppColors.electricLime),
              label: 'Gerakan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.egg_outlined),
              activeIcon: Icon(Icons.egg_rounded, color: AppColors.electricLime),
              label: 'Nutrisi',
            ),
          ],
        ),
      ),
    );
  }
}

