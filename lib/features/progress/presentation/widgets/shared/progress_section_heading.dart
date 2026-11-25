import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/widgets/core_widgets.dart';

/// Heading bagian di dalam tab Progress, mendelegasikan ke [AppSectionHeader].
class ProgressSectionHeading extends StatelessWidget {
  const ProgressSectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSectionHeader(
      title: title,
      subtitle: subtitle,
      titleSize: 16,
      titleWeight: FontWeight.w600,
      trailing: trailing != null
          ? Icon(trailing, size: 15, color: colorScheme.onSurfaceVariant)
          : null,
    );
  }
}
