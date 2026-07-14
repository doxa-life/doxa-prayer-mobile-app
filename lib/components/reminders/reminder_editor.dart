import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_controller.dart';
import '../../services/reminders_notifications.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'exact_alarm_permission_prompt.dart';
import 'reminder_form.dart';

Future<void> showReminderEditor(BuildContext context, {Reminder? existing}) async {
  // The sheet pops with `true` when it just saved the user's first reminder and
  // we should nudge for exact-alarm permission. We show that prompt here — after
  // the sheet has closed — so the dialog lands on the reminders screen rather
  // than stacking over the closing sheet.
  final promptExactAlarms = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ReminderEditorSheet(existing: existing),
  );
  if (promptExactAlarms == true && context.mounted) {
    await showExactAlarmPermissionPrompt(context);
  }
}

class _ReminderEditorSheet extends StatelessWidget {
  const _ReminderEditorSheet({this.existing});

  final Reminder? existing;

  Future<void> _onSaved(BuildContext context, Reminder next) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context)!;
    // Capture before adding: is this the user's very first reminder?
    final wasFirstReminder =
        existing == null && (remindersController.value?.list.isEmpty ?? true);
    final granted = await ensureNotificationPermission();
    if (existing == null) {
      await addReminder(next);
    } else {
      await updateReminder(next);
    }
    if (!context.mounted) return;
    if (!granted) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.notificationsDisabledStatus)),
      );
    }
    final promptExactAlarms = await shouldPromptExactAlarms(
      wasFirstReminder: wasFirstReminder,
      notificationsGranted: granted,
    );
    if (!context.mounted) return;
    Navigator.of(context).pop(promptExactAlarms);
  }

  Future<void> _onDelete(BuildContext context) async {
    final r = existing;
    if (r == null) return;
    await deleteReminder(r.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: ReminderForm(
          initialReminder: existing,
          onSaved: (r) => _onSaved(context, r),
          onDelete: existing == null ? null : () => _onDelete(context),
        ),
      ),
    );
  }
}
