import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../buttons/button_bar_wrap.dart';
import '../inputs/adaptive_time_picker.dart';
import '../misc/titles.dart';
import 'weekday_selector.dart';

class ReminderForm extends StatefulWidget {
  const ReminderForm({
    super.key,
    this.initialReminder,
    this.onSaved,
    this.onDelete,
    this.onChanged,
    this.saveLabel,
    this.title,
  });

  final Reminder? initialReminder;
  final Future<void> Function(Reminder)? onSaved;
  final Future<void> Function()? onDelete;
  final ValueChanged<Reminder?>? onChanged;
  final String? saveLabel;
  final String? title;

  @override
  State<ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<ReminderForm> {
  late final String _id;
  late TimeOfDay _time;
  late Set<int> _weekdays;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.initialReminder;
    _id = r?.id ?? generateReminderId();
    _time = r != null
        ? TimeOfDay(hour: r.hour, minute: r.minute)
        : const TimeOfDay(hour: 8, minute: 0);
    _weekdays = r != null
        ? {...r.weekdays}
        : {
            DateTime.sunday,
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
            DateTime.saturday,
          };
    if (widget.onChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged!(_currentValid());
      });
    }
  }

  bool get _isEditing => widget.initialReminder != null;
  bool get _canSave => _weekdays.isNotEmpty && !_saving;

  Reminder? _currentValid() {
    if (_weekdays.isEmpty) return null;
    final r = widget.initialReminder;
    return Reminder(
      id: _id,
      hour: _time.hour,
      minute: _time.minute,
      weekdays: _weekdays.toList()..sort(),
      enabled: r?.enabled ?? true,
    );
  }

  void _emitChanged() => widget.onChanged?.call(_currentValid());

  Future<void> _pickTime() async {
    final picked = await showAdaptiveTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      setState(() => _time = picked);
      _emitChanged();
    }
  }

  Future<void> _save() async {
    final onSaved = widget.onSaved;
    if (!_canSave || onSaved == null) return;
    final next = _currentValid();
    if (next == null) return;
    setState(() => _saving = true);
    try {
      await onSaved(next);
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
        if (title.isNotEmpty) const SizedBox(height: AppSpacing.xxl),
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
          onChanged: (s) {
            setState(() => _weekdays = s);
            _emitChanged();
          },
        ),
        if (widget.onSaved != null) ...[
          const SizedBox(height: AppSpacing.xxl),
          _buildButtonRow(l, saveLabel),
        ],
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
      // A button bar so delete + save sit side by side when they fit and stack
      // full width (instead of overflowing) when a large font scale widens
      // their labels.
      return ButtonBarWrap(
        leading: ActionButton(
          label: l.delete,
          color: ActionButtonColor.white,
          isOutlined: true,
          onPressed: _saving ? null : () => widget.onDelete!(),
        ),
        trailing: saveButton,
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [saveButton],
    );
  }
}
