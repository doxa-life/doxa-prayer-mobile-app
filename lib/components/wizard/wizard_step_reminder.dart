import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_controller.dart';
import '../../services/reminders_notifications.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../reminders/reminder_form.dart';

class WizardStepReminder extends StatelessWidget {
  const WizardStepReminder({super.key, required this.controller});

  final WizardController controller;

  Future<void> _onSaved(BuildContext context, Reminder r) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context)!;
    final granted = await ensureNotificationPermission();
    await addReminder(r);
    if (!context.mounted) return;
    if (!granted) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.reminderPermissionDenied)),
      );
    }
    controller.next();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.wizardSetReminderBody,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ReminderForm(
            title: l.wizardSetReminderTitle,
            onSaved: (r) => _onSaved(context, r),
            onSkip: controller.next,
            saveLabel: l.saveAndContinue,
          ),
        ],
      ),
    );
  }
}
