import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

/// Section "Quick Access" di Home Screen:
/// 4 Tombol pintas navigasi cepat (Workouts, Meal Plan, Progress, Learn).
class QuickAccessSection extends StatelessWidget {
  final VoidCallback onWorkoutsTap;
  final VoidCallback onMealPlanTap;
  final VoidCallback onProgressTap;
  final VoidCallback onLearnTap;

  const QuickAccessSection({
    super.key,
    required this.onWorkoutsTap,
    required this.onMealPlanTap,
    required this.onProgressTap,
    required this.onLearnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1D1E),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            // 1. Workouts (Active Lime Highlight)
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.fitness_center_rounded,
                label: 'Workouts',
                isActive: true,
                onTap: onWorkoutsTap,
              ),
            ),
            const SizedBox(width: 10),

            // 2. Meal Plan
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.restaurant_rounded,
                label: 'Meal Plan',
                isActive: false,
                onTap: onMealPlanTap,
              ),
            ),
            const SizedBox(width: 10),

            // 3. Progress
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.insights_rounded,
                label: 'Progress',
                isActive: false,
                onTap: onProgressTap,
              ),
            ),
            const SizedBox(width: 10),

            // 4. Learn
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.menu_book_rounded,
                label: 'Learn',
                isActive: false,
                onTap: onLearnTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE9F5DA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFFB8E66B) : const Color(0xFFE9ECEF),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? const Color(0xFF5B8E1B) : const Color(0xFF1A1D1E),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? const Color(0xFF1A1D1E) : const Color(0xFF71767B),
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

