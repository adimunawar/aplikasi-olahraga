import 'package:material_ui/material_ui.dart';

import 'package:workout_app/core/widgets/core_widgets.dart';

/// Dekorasi kartu standar yang dipakai seluruh widget Progress,
/// mendelegasikan ke [AppCard.decoration] sebagai single source of truth.
BoxDecoration progressCardDecoration(BuildContext context) {
  return AppCard.decoration(
    context,
    borderRadius: 15,
    borderWidth: 0.8,
  );
}
