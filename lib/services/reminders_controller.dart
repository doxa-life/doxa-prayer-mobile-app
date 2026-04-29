import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reminders_notifications.dart';

const _storageKey = 'reminders';

class Reminders {
  const Reminders({required this.list});

  final List<Reminder> list;

  factory Reminders.fromJson(List<dynamic> json) => Reminders(
    list: List<Reminder>.from(
      json.map((r) => Reminder.fromJson(r as Map<String, dynamic>)),
    ),
  );
}

class Reminder {
  const Reminder({
    required this.id,
    required this.hour,
    required this.minute,
    required this.weekdays,
    required this.enabled,
  });

  final String id;
  final int hour;
  final int minute;
  // DateTime weekday convention: Monday=1 ... Sunday=7.
  final List<int> weekdays;
  final bool enabled;

  Reminder copyWith({
    String? id,
    int? hour,
    int? minute,
    List<int>? weekdays,
    bool? enabled,
  }) => Reminder(
    id: id ?? this.id,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    weekdays: weekdays ?? this.weekdays,
    enabled: enabled ?? this.enabled,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': hour,
    'minute': minute,
    'weekdays': weekdays,
    'enabled': enabled,
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'] as String,
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
    remindersController.value = Reminders.fromJson(json);
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

Reminder? _find(String id) {
  for (final r in _current()) {
    if (r.id == id) return r;
  }
  return null;
}

Future<void> addReminder(Reminder reminder) async {
  await _persist([..._current(), reminder]);
  if (reminder.enabled) await scheduleReminder(reminder);
}

Future<void> updateReminder(Reminder reminder) async {
  final old = _find(reminder.id);
  if (old != null) await cancelReminder(old);
  await _persist([
    for (final r in _current())
      if (r.id == reminder.id) reminder else r,
  ]);
  if (reminder.enabled) await scheduleReminder(reminder);
}

Future<void> deleteReminder(String id) async {
  final old = _find(id);
  if (old != null) await cancelReminder(old);
  await _persist([for (final r in _current()) if (r.id != id) r]);
}

Future<void> setReminderEnabled(String id, bool enabled) async {
  final old = _find(id);
  await _persist([
    for (final r in _current())
      if (r.id == id) r.copyWith(enabled: enabled) else r,
  ]);
  if (old != null) {
    if (enabled) {
      await scheduleReminder(old.copyWith(enabled: true));
    } else {
      await cancelReminder(old);
    }
  }
}

String generateReminderId() =>
    DateTime.now().microsecondsSinceEpoch.toRadixString(36);
