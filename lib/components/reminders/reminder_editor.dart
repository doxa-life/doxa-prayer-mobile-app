import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_controller.dart';
import '../../services/reminders_notifications.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'reminder_form.dart';

Future<void> showReminderEditor(BuildContext context, {Reminder? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ReminderEditorSheet(existing: existing),
  );
}

class _ReminderEditorSheet extends StatelessWidget {
  const _ReminderEditorSheet({this.existing});

  final Reminder? existing;

  Future<void> _onSaved(BuildContext context, Reminder next) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context)!;
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
    Navigator.of(context).pop();
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
