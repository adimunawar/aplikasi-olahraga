import 'package:material_ui/material_ui.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../../i18n/strings.g.dart';

/// Error state for Workout Detail when workout data fails to load.
class WorkoutDetailErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const WorkoutDetailErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isId = t.$meta.locale == AppLocale.id;

    return SafeArea(
      child: AppErrorState(
        icon: Icons.wifi_off_rounded,
        title: isId
            ? 'Gagal memuat detail latihan'
            : 'Workout detail could not be loaded',
        message: isId
            ? 'Periksa koneksi Anda dan coba lagi.'
            : 'Check your connection and try again.',
        retryLabel: t.workouts.errorState.retry,
        onRetry: onRetry,
      ),
    );
  }
}
