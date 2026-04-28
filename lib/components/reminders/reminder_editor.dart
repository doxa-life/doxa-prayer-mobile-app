import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_controller.dart';
import '../../services/reminders_format.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/titles.dart';

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

class _ReminderEditorSheet extends StatefulWidget {
  const _ReminderEditorSheet({this.existing});

  final Reminder? existing;

  @override
  State<_ReminderEditorSheet> createState() => _ReminderEditorSheetState();
}

class _ReminderEditorSheetState extends State<_ReminderEditorSheet> {
  late TimeOfDay _time;
  late Set<int> _weekdays;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
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

  bool get _isEditing => widget.existing != null;
  bool get _canSave => _weekdays.isNotEmpty;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final r = widget.existing;
    final next = Reminder(
      id: r?.id ?? generateReminderId(),
      hour: _time.hour,
      minute: _time.minute,
      weekdays: _weekdays.toList()..sort(),
      enabled: r?.enabled ?? true,
    );
    if (r == null) {
      await addReminder(next);
    } else {
      await updateReminder(next);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final r = widget.existing;
    if (r == null) return;
    await deleteReminder(r.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: H2(_isEditing ? l.editReminder : l.newReminder)),
            const SizedBox(height: AppSpacing.xxl),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(28),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l.time,
                  suffixIcon: const Icon(Icons.access_time),
                ),
                child: Text(
                  _time.format(context),
                  style: AppTypography.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l.daysOfWeek, style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _WeekdaySelector(
              selected: _weekdays,
              onChanged: (s) => setState(() => _weekdays = s),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: _isEditing
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if (_isEditing)
                  ActionButton(
                    label: l.delete,
                    color: ActionButtonColor.white,
                    isOutlined: true,
                    onPressed: _delete,
                  ),
                ActionButton(
                  label: l.save,
                  onPressed: _canSave ? _save : null,
                  color: ActionButtonColor.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({required this.selected, required this.onChanged});

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final order = weekdaysInLocaleOrder(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final wd in order)
          _WeekdayCircle(
            weekday: wd,
            selected: selected.contains(wd),
            onTap: () {
              final next = {...selected};
              if (!next.add(wd)) next.remove(wd);
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _WeekdayCircle extends StatelessWidget {
  const _WeekdayCircle({
    required this.weekday,
    required this.selected,
    required this.onTap,
  });

  static const double _diameter = 40;

  final int weekday;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = shortWeekdayLabel(context, weekday);
    return Material(
      color: selected ? AppColors.secondary : AppColors.mutedSurface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: _diameter,
          height: _diameter,
          child: Center(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: selected ? AppColors.onSecondary : AppColors.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
