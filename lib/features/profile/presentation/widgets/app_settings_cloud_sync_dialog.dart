import 'package:material_ui/material_ui.dart';

import 'package:workout_app/i18n/strings.g.dart';

Future<bool> showCloudSyncConsentDialog(BuildContext context) async {
  final settingsT = t.profile.appSettings;
  final accepted = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(settingsT.cloudSyncDialogTitle),
      content: Text(settingsT.cloudSyncDialogBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(settingsT.cloudSyncDialogCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(settingsT.cloudSyncDialogConfirm),
        ),
      ],
    ),
  );
  return accepted == true;
}
