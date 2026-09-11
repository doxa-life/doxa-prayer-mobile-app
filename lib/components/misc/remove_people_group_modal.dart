import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../buttons/action_button.dart';
import 'action_modal.dart';

/// Confirms that the user wants to stop praying for a people group, naming the
/// reminders that go with it. Removing is not undoable in-app — it deletes
/// those reminders and unsubscribes on the server — so the count is spelled out
/// rather than left for the user to remember.
///
/// Returns true when the user confirms.
Future<bool> showRemovePeopleGroupModal(
  BuildContext context, {
  required String name,
  required int reminderCount,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final message = [
    l10n.removePeopleGroupTitle(name),
    if (reminderCount > 0) l10n.removePeopleGroupReminders(reminderCount),
    l10n.removePeopleGroupBody,
  ].join('\n\n');

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => ActionModal(
      message: message,
      // Cancel is deliberately the *trailing* button: ButtonBarWrap treats
      // trailing as the primary action, giving it the right-hand slot side by
      // side and the top slot once the labels are long enough to stack. For a
      // destructive confirm the safe choice is the one that should sit there,
      // and the solid white fill makes it read as the default.
      actionButtons: [
        ActionButton(
          label: l10n.stopPraying,
          onPressed: () => Navigator.of(ctx).pop(true),
          color: ActionButtonColor.secondaryLight,
          isOutlined: true,
        ),
        ActionButton(
          label: l10n.cancel,
          onPressed: () => Navigator.of(ctx).pop(false),
          color: ActionButtonColor.white,
        ),
      ],
    ),
  );
  return confirmed == true;
}
