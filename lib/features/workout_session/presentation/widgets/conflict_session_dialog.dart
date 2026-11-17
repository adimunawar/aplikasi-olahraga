import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';

/// Dialog saat ada sesi in_progress lain (program/jadwal berbeda).
///
/// Mengembalikan `'resume'` untuk melanjutkan sesi lama, `'discard'` untuk
/// mengakhirinya dan mulai sesi baru, atau `null` jika user menutup dialog
/// tanpa memilih.
class ConflictSessionDialog extends StatelessWidget {
  final String programTitle;
  final int dayNumber;

  const ConflictSessionDialog({
    super.key,
    required this.programTitle,
    required this.dayNumber,
  });

  static Future<String?> show(
    BuildContext context, {
    required String programTitle,
    required int dayNumber,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ConflictSessionDialog(
        programTitle: programTitle,
        dayNumber: dayNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(t.workoutSession.sessionConflictTitle),
      content: Text(
        t.workoutSession.sessionConflictMessage(
          program: programTitle,
          day: dayNumber,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'resume'),
          child: Text(t.workoutSession.resumePreviousSession),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'discard'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(t.workoutSession.endPreviousSession),
        ),
      ],
    );
  }
}
