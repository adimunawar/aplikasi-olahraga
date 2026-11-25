import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/widgets/core_widgets.dart';

/// State kosong yang konsisten untuk seluruh kartu Progress,
/// mendelegasikan ke [AppEmptyState].
class ProgressEmptyState extends StatelessWidget {
  const ProgressEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: icon,
      title: title,
      message: message,
      compact: compact,
      borderRadius: 15,
    );
  }
}
