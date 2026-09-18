import 'reminders_controller.dart';

/// The reminder schedule the server is told about for one people group.
/// The server stores a single (frequency, time, days) per subscription, so a
/// group's several reminders have to collapse into one shape.
class GroupSchedule {
  const GroupSchedule({
    required this.hour,
    required this.minute,
    required this.weekdays,
  });

  final int hour;
  final int minute;
  final List<int> weekdays;

  String get frequency => weekdays.length == 7 ? 'daily' : 'weekly';

  String get time =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Flutter's weekdays (Mon=1..Sun=7) in the JS backend's convention
  /// (Sun=0..Sat=6). Mon..Sat are unchanged by `% 7`; Sun (7) folds to 0.
  List<int> get encodedWeekdays =>
      weekdays.map((w) => w % 7).toSet().toList()..sort();

  /// What a group with no reminders of its own reports: a daily commitment at
  /// 8am, matching what the app has always sent for a user who never set one.
  static const fallback = GroupSchedule(
    hour: 8,
    minute: 0,
    weekdays: <int>[1, 2, 3, 4, 5, 6, 7],
  );
}

/// Derives [slug]'s schedule from that group's reminders alone: the earliest
/// enabled reminder supplies the time, and the weekdays are the union across
/// every enabled reminder for the group, so the server learns every day the
/// user expects to pray for them.
GroupSchedule scheduleForGroup(String slug) {
  final all = remindersController.value?.forGroup(slug) ?? const <Reminder>[];
  if (all.isEmpty) return GroupSchedule.fallback;

  int rank(Reminder r) => r.hour * 60 + r.minute;
  final enabled = all.where((r) => r.enabled).toList()
    ..sort((a, b) => rank(a).compareTo(rank(b)));
  final timeSource = enabled.isNotEmpty
      ? enabled.first
      : (all.toList()..sort((a, b) => rank(a).compareTo(rank(b)))).first;

  // Fall back to the time source's days when nothing is enabled, so we still
  // send a usable schedule rather than an empty week.
  final weekdays = <int>{for (final r in enabled) ...r.weekdays};
  if (weekdays.isEmpty) weekdays.addAll(timeSource.weekdays);

  return GroupSchedule(
    hour: timeSource.hour,
    minute: timeSource.minute,
    weekdays: weekdays.toList()..sort(),
  );
}
