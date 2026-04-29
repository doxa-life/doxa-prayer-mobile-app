import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

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

String formatNextReminderWhen(BuildContext context, DateTime firesAt) {
  final l = AppLocalizations.of(context)!;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final fireDay = DateTime(firesAt.year, firesAt.month, firesAt.day);
  final daysAhead = fireDay.difference(today).inDays;
  final time = TimeOfDay(
    hour: firesAt.hour,
    minute: firesAt.minute,
  ).format(context);
  if (daysAhead == 0) return l.nextReminderToday(time);
  if (daysAhead == 1) return l.nextReminderTomorrow(time);
  final weekday = intl.DateFormat.EEEE(
    Localizations.localeOf(context).toString(),
  ).format(firesAt);
  return l.nextReminderOn(weekday, time);
}
