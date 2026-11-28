import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';
import 'step_equipment/step_equipment_widgets.dart';

/// Step 7 of 8: What equipment do you have? (Light & Dark Mode)
class StepEquipment extends StatelessWidget {
  final List<String> selectedEquipments;
  final ValueChanged<String> onToggleEquipment;

  const StepEquipment({
    super.key,
    required this.selectedEquipments,
    required this.onToggleEquipment,
  });

  static const Map<String, String> _assetImages = {
    'bodyweight': 'assets/images/coach_crossed_arms.png',
    'dumbbell': 'assets/images/dumbell.webp',
    'resistance_band': 'assets/images/resistance_band.webp',
    'kettlebell': 'assets/images/kettlebell.webp',
    'pull_up_bar': 'assets/images/pull-up-bar.webp',
    'barbell': 'assets/images/weight-plates.webp',
  };

  static const Map<String, IconData> _fallbackIcons = {
    'bodyweight': Icons.accessibility_new_rounded,
    'dumbbell': Icons.fitness_center_rounded,
    'resistance_band': Icons.all_inclusive_rounded,
    'kettlebell': Icons.sports_gymnastics_rounded,
    'pull_up_bar': Icons.horizontal_rule_rounded,
    'barbell': Icons.line_weight_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.equipment;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: t.options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.24,
            ),
            itemBuilder: (context, index) {
              final opt = t.options[index];
              return EquipmentCard(
                label: opt.label,
                imagePath: _assetImages[opt.id] ?? 'assets/images/dumbell.webp',
                fallbackIcon:
                    _fallbackIcons[opt.id] ?? Icons.fitness_center_rounded,
                isBodyweight: opt.id == 'bodyweight',
                isSelected: selectedEquipments.contains(opt.id),
                onTap: () => onToggleEquipment(opt.id),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
