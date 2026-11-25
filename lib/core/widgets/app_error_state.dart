import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/theme/app_typography.dart';

import 'app_button.dart';
import 'app_card.dart';

/// Error state standar desain sistem (DRY Principle).
///
/// Mendukung tampilan penuh ([useCard] = false) maupun di dalam kartu
/// ([useCard] = true), serta adaptif terhadap Light Mode dan Dark Mode.
class AppErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;
  final bool useCard;
  final double borderRadius;

  const AppErrorState({
    super.key,
    this.icon = Icons.error_outline_rounded,
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    this.useCard = false,
    this.borderRadius = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: useCard ? 48 : 64,
          height: useCard ? 48 : 64,
          decoration: BoxDecoration(
            color: colorScheme.error.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: useCard ? 24 : 30,
            color: colorScheme.error,
          ),
        ),
        SizedBox(height: useCard ? 10 : 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: (useCard ? AppTypography.titleSmall : AppTypography.titleLarge)
              .copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: (useCard ? AppTypography.bodySmall : AppTypography.bodyMedium)
              .copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: useCard ? 14 : 24),
        if (useCard)
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(retryLabel),
          )
        else
          AppButton.primary(
            text: retryLabel,
            onPressed: onRetry,
            isFullWidth: false,
            width: 160,
            size: AppButtonSize.medium,
          ),
      ],
    );

    if (useCard) {
      return SizedBox(
        width: double.infinity,
        child: AppCard(
          borderRadius: borderRadius,
          padding: const EdgeInsets.all(20),
          child: content,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: content,
      ),
    );
  }
}
