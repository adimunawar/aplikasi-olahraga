import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';

/// Fase overlay full-screen di atas konten Active Workout.
enum WorkoutSessionOverlayPhase {
  /// Persiapan sesi (buat record / restore sesi lama).
  preparing,

  /// Gagal menyiapkan sesi + tombol retry.
  error,

  /// Menyimpan sesi ke database.
  saving,
}

/// Overlay full-screen di atas konten Active Workout.
/// Menutup konten saat persiapan/error/simpan supaya kontrol tidak bisa
/// dipakai sebelum sesi benar-benar siap.
class WorkoutSessionOverlay extends StatelessWidget {
  final WorkoutSessionOverlayPhase phase;
  final String errorMessage;
  final VoidCallback onRetry;

  const WorkoutSessionOverlay({
    super.key,
    required this.phase,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    switch (phase) {
      case WorkoutSessionOverlayPhase.preparing:
        return _BlockingOverlay(
          backgroundColor: Colors.white.withValues(alpha: 0.85),
          label: t.workoutSession.preparingSession,
        );
      case WorkoutSessionOverlayPhase.saving:
        return _BlockingOverlay(
          backgroundColor: Colors.black.withValues(alpha: 0.4),
          label: t.workoutSession.savingSession,
          labelColor: Colors.white,
        );
      case WorkoutSessionOverlayPhase.error:
        return Container(
          color: Colors.white.withValues(alpha: 0.92),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 44,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.darkCharcoal,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppButton.primary(
                    text: t.workoutSession.retry,
                    onPressed: onRetry,
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

class _BlockingOverlay extends StatelessWidget {
  final Color backgroundColor;
  final String label;
  final Color labelColor;

  const _BlockingOverlay({
    required this.backgroundColor,
    required this.label,
    this.labelColor = AppColors.darkCharcoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.limeAccent),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
