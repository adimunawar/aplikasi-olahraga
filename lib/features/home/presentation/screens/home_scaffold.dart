import 'package:material_ui/material_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../progress/presentation/screens/progress_screen.dart';
import '../../../workouts/presentation/screens/workouts_screen.dart';
import 'home_screen.dart';

/// HomeScaffold - Bottom Navigation Bar dengan dukungan penuh Light Mode & Dark Mode:
/// Mendukung GoRouter StatefulNavigationShell dan fallback IndexedStack.
class HomeScaffold extends StatefulWidget {
  final StatefulNavigationShell? navigationShell;

  const HomeScaffold({
    super.key,
    this.navigationShell,
  });

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _currentIndex = 0;

  int get _activeTab =>
      widget.navigationShell?.currentIndex ?? _currentIndex;

  void _onTabTapped(int index) {
    if (widget.navigationShell != null) {
      widget.navigationShell!.goBranch(
        index,
        initialLocation: index == widget.navigationShell!.currentIndex,
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final List<Widget> screens = [
      HomeScreen(
        onNavigateToCalendar: () => _onTabTapped(1),
        onNavigateToExercises: () => _onTabTapped(1),
        onNavigateToNutrition: () => _onTabTapped(2),
        onNavigateToProgress: () => _onTabTapped(2),
      ),
      const WorkoutsScreen(),
      const WorkoutsScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: widget.navigationShell ??
          IndexedStack(
            index: _activeTab,
            children: screens,
          ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outline, width: 1.2),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.fitness_center_rounded,
                label: 'Workouts',
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.bar_chart_rounded,
                label: 'Progress',
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _activeTab == index;

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? (isDark ? colorScheme.primary : AppColors.greenDark)
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected
                    ? (isDark
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface)
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
