import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reminders_notifications.dart';
import 'subscribed_people_groups_controller.dart';

const _storageKey = 'reminders';

class Reminders {
  const Reminders({required this.list});

  final List<Reminder> list;

  /// Reminders belonging to [slug], soonest first — what the reminders screen
  /// labels and what the per-group schedule sync sends to the server.
  List<Reminder> forGroup(String slug) => [
    for (final r in list)
      if (r.slug == slug) r,
  ];

  factory Reminders.fromJson(List<dynamic> json, {String fallbackSlug = ''}) =>
      Reminders(
        list: List<Reminder>.from(
          json.map(
            (r) => Reminder.fromJson(
              r as Map<String, dynamic>,
              fallbackSlug: fallbackSlug,
            ),
          ),
        ),
      );
}

class Reminder {
  const Reminder({
    required this.id,
    required this.slug,
    required this.hour,
    required this.minute,
    required this.weekdays,
    required this.enabled,
  });

  final String id;

  /// The people group this reminder is for. Always set for reminders created
  /// in-app; an empty string only occurs for a pre-multi-group reminder
  /// migrated on a device that had no selection left to inherit from, and is
  /// treated as "no group" everywhere it is read.
  final String slug;
  final int hour;
  final int minute;
  // DateTime weekday convention: Monday=1 ... Sunday=7.
  final List<int> weekdays;
  final bool enabled;

  Reminder copyWith({
    String? id,
    String? slug,
    int? hour,
    int? minute,
    List<int>? weekdays,
    bool? enabled,
  }) => Reminder(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    weekdays: weekdays ?? this.weekdays,
    enabled: enabled ?? this.enabled,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'hour': hour,
    'minute': minute,
    'weekdays': weekdays,
    'enabled': enabled,
  };

  /// [fallbackSlug] adopts pre-multi-group reminders, which carried no group
  /// because there was only ever one. Callers pass the active group's slug.
  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    String fallbackSlug = '',
  }) => Reminder(
    id: json['id'] as String,
    slug: json['slug'] as String? ?? fallbackSlug,
    hour: json['hour'] as int,
    minute: json['minute'] as int,
    weekdays: (json['weekdays'] as List<dynamic>).cast<int>(),
    enabled: json['enabled'] as bool,
  );
}

final ValueNotifier<Reminders?> remindersController = ValueNotifier<Reminders?>(
  null,
);

Future<void> loadReminders() async {
  final prefs = SharedPreferencesAsync();
  final raw = await prefs.getString(_storageKey);
  if (raw == null) {
    remindersController.value = const Reminders(list: []);
  } else {
    final json = jsonDecode(raw) as List<dynamic>;
    // Runs after loadPeopleGroups(), so a reminder stored before this feature
    // adopts the group its owner was praying for.
    remindersController.value = Reminders.fromJson(
      json,
      fallbackSlug: activePeopleGroup?.slug ?? '',
    );
    // Persist the adopted slugs so the migration only happens once.
    if (json.any((r) => (r as Map<String, dynamic>)['slug'] == null)) {
      await _persist(remindersController.value!.list);
    }
  }
  await rescheduleAllReminders(remindersController.value!.list);
}

Future<void> _persist(List<Reminder> list) async {
  remindersController.value = Reminders(list: list);
  final prefs = SharedPreferencesAsync();
  await prefs.setString(
    _storageKey,
    jsonEncode(list.map((r) => r.toJson()).toList()),
  );
}

List<Reminder> _current() =>
    remindersController.value?.list ?? const <Reminder>[];

// All mutations persist first, then reschedule from the full reminder list.
// rescheduleAllReminders dedupes notifications by (group, fire-time), so a slot
// is only dropped when no remaining enabled reminder for that group covers it.

Future<void> addReminder(Reminder reminder) async {
  await _persist([..._current(), reminder]);
  await rescheduleAllReminders(_current());
}

Future<void> updateReminder(Reminder reminder) async {
  await _persist([
    for (final r in _current())
      if (r.id == reminder.id) reminder else r,
  ]);
  await rescheduleAllReminders(_current());
}

Future<void> deleteReminder(String id) async {
  await _persist([
    for (final r in _current())
      if (r.id != id) r,
  ]);
  await rescheduleAllReminders(_current());
}

/// Deletes every reminder belonging to [slug] — the cascade behind removing a
/// people group. Returns how many went, so the caller can say so.
Future<int> deleteRemindersForGroup(String slug) async {
  final remaining = [
    for (final r in _current())
      if (r.slug != slug) r,
  ];
  final removed = _current().length - remaining.length;
  if (removed == 0) return 0;
  await _persist(remaining);
  await rescheduleAllReminders(_current());
  return removed;
}

Future<void> clearReminders() async {
  remindersController.value = const Reminders(list: []);
  final prefs = SharedPreferencesAsync();
  await prefs.remove(_storageKey);
  await rescheduleAllReminders(const []);
}

Future<void> setReminderEnabled(String id, bool enabled) async {
  await _persist([
    for (final r in _current())
      if (r.id == id) r.copyWith(enabled: enabled) else r,
  ]);
  await rescheduleAllReminders(_current());
}

String generateReminderId() =>
    DateTime.now().microsecondsSinceEpoch.toRadixString(36);

class NextReminder {
  const NextReminder({required this.reminder, required this.firesAt});

  final Reminder reminder;
  final DateTime firesAt;
}

/// Returns the soonest enabled firing across all reminders, or null if none.
NextReminder? findNextReminder(List<Reminder> all, {DateTime? now}) {
  final n = now ?? DateTime.now();
  NextReminder? best;
  for (final r in all) {
    if (!r.enabled || r.weekdays.isEmpty) continue;
    for (final w in r.weekdays) {
      final dt = _nextOccurrence(n, w, r.hour, r.minute);
      if (best == null || dt.isBefore(best.firesAt)) {
        best = NextReminder(reminder: r, firesAt: dt);
      }
    }
  }
  return best;
}

DateTime _nextOccurrence(DateTime now, int weekday, int hour, int minute) {
  var dt = DateTime(now.year, now.month, now.day, hour, minute);
  while (dt.weekday != weekday || !dt.isAfter(now)) {
    dt = dt.add(const Duration(days: 1));
  }
  return dt;
}
