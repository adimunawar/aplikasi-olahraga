import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';

/// Sticky bottom action bar for onboarding welcome and step navigation.
class OnboardingBottomBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onComplete;
  final VoidCallback? onSignIn;

  const OnboardingBottomBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.isLoading,
    required this.onNext,
    required this.onComplete,
    this.onSignIn,
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
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.primary(
                    text: t.getStarted,
                    size: AppButtonSize.large,
                    onPressed: onNext,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t.alreadyHaveAccount,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            onSignIn ?? () => context.push(AppRoutes.login),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: const Size(48, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          t.signIn,
                          style: AppTypography.labelLarge.copyWith(
                            color: isDark
                                ? colorScheme.primary
                                : AppColors.greenBrand,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
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
