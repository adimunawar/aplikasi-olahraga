import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/core_widgets.dart';
import '../../../../i18n/strings.g.dart';

/// Empty state when a workout session has no exercises assigned.
class WorkoutDetailEmptyState extends StatelessWidget {
  const WorkoutDetailEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isId = t.$meta.locale == AppLocale.id;

    return AppEmptyState(
      icon: Icons.fitness_center_rounded,
      title: isId ? 'Belum ada gerakan latihan' : 'No exercises available',
      message: isId
          ? 'Tidak ada gerakan latihan yang dijadwalkan pada sesi ini.'
          : 'There are no exercises assigned to this workout yet.',
      neutralBadge: true,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
    );
  }
}
