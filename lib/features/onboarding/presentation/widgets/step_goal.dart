import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';
import 'step_goal/step_goal_widgets.dart';

/// Step 1 of 8: What's your main goal? (Light & Dark Mode)
class StepGoal extends StatelessWidget {
  final String selectedGoal;
  final ValueChanged<String> onGoalSelected;

  const StepGoal({
    super.key,
    required this.selectedGoal,
    required this.onGoalSelected,
  });

  static const Map<String, String> _assetImages = {
    'muscle_gain': 'assets/images/goal_bulking.webp',
    'fat_loss': 'assets/images/goal_weight_loss.webp',
    'maintenance': 'assets/images/goal_fitness.webp',
  };

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.goal;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 26,
              height: 1.15,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          for (final option in t.options) ...[
            GoalCard(
              option: option,
              imagePath:
                  _assetImages[option.id] ?? 'assets/images/coach_flex.png',
              isSelected: selectedGoal == option.id,
              onTap: () => onGoalSelected(option.id),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
