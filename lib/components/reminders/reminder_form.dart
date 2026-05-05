import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/titles.dart';
import 'weekday_selector.dart';

class ReminderForm extends StatefulWidget {
  const ReminderForm({
    super.key,
    this.initialReminder,
    required this.onSaved,
    this.onDelete,
    this.onSkip,
    this.saveLabel,
    this.title,
  });

  final Reminder? initialReminder;
  final Future<void> Function(Reminder) onSaved;
  final Future<void> Function()? onDelete;
  final VoidCallback? onSkip;
  final String? saveLabel;
  final String? title;

  @override
  State<ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<ReminderForm> {
  late TimeOfDay _time;
  late Set<int> _weekdays;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.initialReminder;
    _time = r != null
        ? TimeOfDay(hour: r.hour, minute: r.minute)
        : const TimeOfDay(hour: 8, minute: 0);
    _weekdays = r != null
        ? {...r.weekdays}
        : {
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
          };
  }

  bool get _isEditing => widget.initialReminder != null;
  bool get _canSave => _weekdays.isNotEmpty && !_saving;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    final r = widget.initialReminder;
    final next = Reminder(
      id: r?.id ?? generateReminderId(),
      hour: _time.hour,
      minute: _time.minute,
      weekdays: _weekdays.toList()..sort(),
      enabled: r?.enabled ?? true,
    );
    try {
      await widget.onSaved(next);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final saveLabel = widget.saveLabel ?? l.save;
    final title = widget.title ?? (_isEditing ? l.editReminder : l.newReminder);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: H2(title)),
        const SizedBox(height: AppSpacing.xxl),
        InkWell(
          onTap: _pickTime,
          borderRadius: BorderRadius.circular(28),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l.time,
              suffixIcon: const Icon(Icons.access_time),
            ),
            child: Text(_time.format(context), style: AppTypography.bodyMedium),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l.daysOfWeek, style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        WeekdaySelector(
          selected: _weekdays,
          onChanged: (s) => setState(() => _weekdays = s),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildButtonRow(l, saveLabel),
      ],
    );
  }

  Widget _buildButtonRow(AppLocalizations l, String saveLabel) {
    final saveButton = ActionButton(
      label: saveLabel,
      onPressed: _canSave ? _save : null,
      color: ActionButtonColor.secondary,
    );
    if (widget.onDelete != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionButton(
            label: l.delete,
            color: ActionButtonColor.white,
            isOutlined: true,
            onPressed: _saving ? null : () => widget.onDelete!(),
          ),
          saveButton,
        ],
      );
    }
    if (widget.onSkip != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionButton(
            label: l.skip,
            color: ActionButtonColor.white,
            isOutlined: true,
            onPressed: _saving ? null : widget.onSkip,
          ),
          saveButton,
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [saveButton],
    );
  }
}
