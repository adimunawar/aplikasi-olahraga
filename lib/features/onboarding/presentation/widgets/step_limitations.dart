import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/strings.g.dart';
import 'step_limitations/step_limitations_widgets.dart';

/// Step 8 of 8: Any limitations or considerations? (Light & Dark Mode)
class StepLimitations extends StatelessWidget {
  final List<String> selectedLimitations;
  final ValueChanged<String> onToggleLimitation;

  const StepLimitations({
    super.key,
    required this.selectedLimitations,
    required this.onToggleLimitation,
  });

  static const Map<String, String> _assetImages = {
    'none': 'assets/images/normal.webp',
    'knee': 'assets/images/lutut.webp',
    'back': 'assets/images/punggung.webp',
    'shoulder': 'assets/images/bahu.webp',
    'wrist': 'assets/images/hand.webp',
    'other': 'assets/images/more.webp',
  };

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.limitations;
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
          for (final opt in t.options) ...[
            LimitationCard(
              label: opt.label,
              imagePath: _assetImages[opt.id],
              isSelected: selectedLimitations.contains(opt.id),
              onTap: () => onToggleLimitation(opt.id),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
