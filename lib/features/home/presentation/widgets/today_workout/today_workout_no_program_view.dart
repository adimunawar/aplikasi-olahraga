import 'package:material_ui/material_ui.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../i18n/strings.g.dart';

/// Tampilan Empty State ketika belum ada Program Latihan (Mockup 1:1)
class TodayWorkoutNoProgramView extends StatelessWidget {
  final VoidCallback onCreateProgram;

  const TodayWorkoutNoProgramView({
    super.key,
    required this.onCreateProgram,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.2),
              ),
              child: Center(
                child: Icon(
                  Icons.assignment_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.home.noProgram.title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              t.home.noProgram.subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12.5,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onCreateProgram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  t.home.noProgram.createProgram,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
