import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';

/// Bottom sheet opsi Active Workout: restart timer rest, akhiri sesi sekarang,
/// atau keluar tanpa menyimpan.
///
/// Widget ini hanya UI — semua aksi dieksekusi lewat callback pemanggil.
class WorkoutOptionsSheet extends StatelessWidget {
  final VoidCallback onRestartRestTimer;
  final VoidCallback onFinishNow;
  final VoidCallback onExit;

  const WorkoutOptionsSheet({
    super.key,
    required this.onRestartRestTimer,
    required this.onFinishNow,
    required this.onExit,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRestartRestTimer,
    required VoidCallback onFinishNow,
    required VoidCallback onExit,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => WorkoutOptionsSheet(
        onRestartRestTimer: onRestartRestTimer,
        onFinishNow: onFinishNow,
        onExit: onExit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: Text(t.workoutSession.restartRestTimer),
            onTap: () {
              Navigator.pop(context);
              onRestartRestTimer();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF65A30D),
            ),
            title: Text(
              t.workoutSession.finishSessionNow,
              style: const TextStyle(
                color: Color(0xFF65A30D),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onFinishNow();
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
            title: Text(
              t.workoutSession.exitWithoutSaving,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              onExit();
            },
          ),
        ],
      ),
    );
  }
}
