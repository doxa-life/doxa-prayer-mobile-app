import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'reminders_controller.dart';

String formatReminderTime(BuildContext context, Reminder r) =>
    TimeOfDay(hour: r.hour, minute: r.minute).format(context);

/// Localized weekday short names ordered by the locale's first day of week.
/// Index by DateTime weekday (1=Mon ... 7=Sun).
List<int> weekdaysInLocaleOrder(BuildContext context) {
  final firstDay = MaterialLocalizations.of(context).firstDayOfWeekIndex;
  // Material's index: 0=Sun ... 6=Sat. DateTime weekday: 1=Mon ... 7=Sun.
  return List.generate(7, (i) {
    final matIndex = (firstDay + i) % 7;
    return matIndex == 0 ? DateTime.sunday : matIndex;
  });
}

String shortWeekdayLabel(BuildContext context, int weekday) {
  // narrowWeekdays is length 7, indexed 0=Sun ... 6=Sat.
  final narrow = MaterialLocalizations.of(context).narrowWeekdays;
  return narrow[weekday == DateTime.sunday ? 0 : weekday];
}

String formatReminderDays(BuildContext context, Reminder r) {
  final l = AppLocalizations.of(context)!;
  if (r.weekdays.isEmpty) return l.noDaysSelected;
  if (r.weekdays.length == 7) return l.everyDay;
  final order = weekdaysInLocaleOrder(context);
  final selected = r.weekdays.toSet();
  return order
      .where(selected.contains)
      .map((w) => shortWeekdayLabel(context, w))
      .join(' · ');
}
