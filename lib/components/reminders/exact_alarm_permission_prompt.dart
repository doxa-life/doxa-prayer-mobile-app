import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_notifications.dart';
import '../buttons/action_button.dart';
import '../misc/action_modal.dart';

/// Decides whether to nudge for the exact-alarm permission after a reminder was
/// saved: only for the user's *first* reminder, only when notifications are
/// enabled (otherwise nothing is delivered anyway and the "notifications off"
/// message already covers it), and only when exact alarms aren't already
/// permitted (true on iOS and Android < 12, so those never prompt).
Future<bool> shouldPromptExactAlarms({
  required bool wasFirstReminder,
  required bool notificationsGranted,
}) async {
  if (!wasFirstReminder || !notificationsGranted) return false;
  return !(await exactAlarmsAuthorized());
}

/// One-time rationale dialog shown after the first reminder is created. There
/// is no system pop-up for SCHEDULE_EXACT_ALARM (it's a special app access, not
/// a runtime permission), so accepting deep-links the user to the system
/// "Alarms & reminders" screen via [promptEnableExactAlarms]. Dismissing leaves
/// reminders on inexact scheduling — they still fire, just up to a few minutes
/// late — and the reminders-screen banner remains as a later nudge.
///
/// Callers should gate on [shouldPromptExactAlarms] first.
Future<void> showExactAlarmPermissionPrompt(BuildContext context) async {
  final l = AppLocalizations.of(context)!;
  final allow = await showDialog<bool>(
    context: context,
    builder: (ctx) => ActionModal(
      message: l.exactAlarmsPromptBody,
      actionButtons: [
        ActionButton(
          label: l.notNow,
          onPressed: () => Navigator.of(ctx).pop(false),
          color: ActionButtonColor.white,
        ),
        ActionButton(
          label: l.allow,
          onPressed: () => Navigator.of(ctx).pop(true),
          color: ActionButtonColor.secondaryLight,
          isOutlined: true,
        ),
      ],
    ),
  );
  if (allow == true) await promptEnableExactAlarms();
}
