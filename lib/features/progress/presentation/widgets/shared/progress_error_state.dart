import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/widgets/core_widgets.dart';
import 'package:workout_app/i18n/strings.g.dart';

/// State error untuk halaman Progress beserta aksi coba lagi,
/// mendelegasikan ke [AppErrorState].
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: context.t.core.progress.error.title,
      message: message,
      retryLabel: context.t.core.progress.error.retry,
      onRetry: onRetry,
      useCard: true,
      borderRadius: 15,
    );
  }
}
