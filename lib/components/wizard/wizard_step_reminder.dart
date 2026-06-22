import 'package:doxa_prayer_mobile_app/components/misc/titles.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_controller.dart';
import '../../services/reminders_notifications.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../reminders/reminder_form.dart';

class WizardStepReminder extends StatefulWidget {
  const WizardStepReminder({super.key, required this.controller});

  final WizardController controller;

  @override
  State<WizardStepReminder> createState() => _WizardStepReminderState();
}

class _WizardStepReminderState extends State<WizardStepReminder> {
  Reminder? _current;
  bool _saving = false;

  Future<void> _save() async {
    final r = _current;
    if (r == null || _saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      final granted = await ensureNotificationPermission();
      await addReminder(r);
      if (!mounted) return;
      if (!granted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l.notificationsDisabledStatus)),
        );
      }
      widget.controller.next();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final canSave = _current != null && !_saving;
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          H1(l.wizardSetReminderTitle, textAlign: TextAlign.center),
          Text(
            l.wizardSetReminderBody,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ReminderForm(
            title: '',
            onChanged: (r) => setState(() => _current = r),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(child: SizedBox.shrink()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionButton(
                label: l.skip,
                color: ActionButtonColor.white,
                isOutlined: true,
                onPressed: _saving ? null : widget.controller.next,
              ),
              ActionButton(
                label: l.saveAndContinue,
                color: ActionButtonColor.secondary,
                onPressed: canSave ? _save : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
