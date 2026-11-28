import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';
import 'onboarding_dots_indicator.dart';

/// Sticky bottom action bar for onboarding welcome and step navigation.
class OnboardingBottomBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  const OnboardingBottomBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.isLoading,
    required this.onNext,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context).onboarding.nav;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: currentStep == 0
            ? null
            : Border(top: BorderSide(color: colorScheme.outline, width: 1)),
        boxShadow: currentStep == 0 || isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
      child: SafeArea(
        top: false,
        child: currentStep == 0
            ? Row(
                children: [
                  const OnboardingDotsIndicator(activeIndex: 0),
                  const Spacer(),
                  AppButton.primary(
                    text: t.getStarted,
                    size: AppButtonSize.large,
                    isFullWidth: false,
                    width: 210,
                    onPressed: onNext,
                  ),
                ],
              )
            : AppButton.primary(
                text: currentStep == totalSteps
                    ? t.createMyPlan
                    : t.continueCta,
                size: AppButtonSize.large,
                isLoading: isLoading,
                onPressed: currentStep == totalSteps ? onComplete : onNext,
              ),
      ),
    );
  }
}
