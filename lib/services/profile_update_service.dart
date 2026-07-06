import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'crash_reporting_service.dart';
import 'identity_service.dart';
import 'reminders_controller.dart';
import 'selected_people_group_controller.dart';

Future<void> submitProfileUpdate() async {
  final identity = identityController.value;
  final profileId = identity?.profileId;
  if (profileId == null || profileId.isEmpty) return;

  final reminder = _selectPrayerReminder();
  final timezone = await _resolveTimezone();
  final peopleGroup = selectedPeopleGroupController.value;

  final payload = <String, dynamic>{
    if (identity?.subscriptionId != null) ...{
      'subscription_id': identity!.subscriptionId,
      'frequency': reminder.weekdays.length == 7 ? 'daily' : 'weekly',
      'time_preference': _formatTime(reminder.hour, reminder.minute),
      'days_of_week': _encodeWeekdays(reminder.weekdays),
      'timezone': timezone,
      // Moving the subscription to the now-selected group. Only meaningful
      // alongside subscription_id, so it lives inside this block.
      if (peopleGroup != null) 'people_group_slug': peopleGroup.slug,
    },
    if (peopleGroup != null) 'consent_people_group_slug': peopleGroup.slug,
  };

  final body = jsonEncode(payload);
  final uri = ApiConfig.buildUri('/api/profile/$profileId');

  if (!kReleaseMode && !ApiConfig.hasAppSecret) {
    developer.log(
      'Skipping profile PUT (dev build, no ANON_SIGNUP_SECRET)\n'
      'URL: $uri\n'
      'Body: $body',
      name: 'profile_update_service',
    );
    return;
  }

  developer.log(
    'PUT profile\nURL: $uri\nBody: $body',
    name: 'profile_update_service',
  );
  final response = await http.put(
    uri,
    headers: ApiConfig.signupHeaders,
    body: body,
  );
  developer.log(
    'profile PUT response\nStatus: ${response.statusCode}\nBody: ${response.body}',
    name: 'profile_update_service',
  );
  if (response.statusCode != 200) {
    throw Exception('profile update failed (${response.statusCode})');
  }

  // A group move usually keeps the same subscription_id (repointed in place),
  // but when the server merges into a pre-existing row the id changes. Adopt the
  // returned id so the cached identity stays in sync.
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  final returnedId = (json['currentSubscription'] as Map<String, dynamic>?)?['id'];
  if (returnedId is num && returnedId.toInt() != identity?.subscriptionId) {
    await setIdentity(subscriptionId: returnedId.toInt());
  }
}

class _PrayerReminder {
  const _PrayerReminder({
    required this.hour,
    required this.minute,
    required this.weekdays,
  });
  final int hour;
  final int minute;
  final List<int> weekdays;
}

_PrayerReminder _selectPrayerReminder() {
  final all = remindersController.value?.list ?? const <Reminder>[];
  if (all.isEmpty) {
    return const _PrayerReminder(
      hour: 8,
      minute: 0,
      weekdays: <int>[1, 2, 3, 4, 5, 6, 7],
    );
  }
  int rank(Reminder r) => r.hour * 60 + r.minute;
  final enabled = all.where((r) => r.enabled).toList()
    ..sort((a, b) => rank(a).compareTo(rank(b)));
  final timeSource = enabled.isNotEmpty
      ? enabled.first
      : (all.toList()..sort((a, b) => rank(a).compareTo(rank(b)))).first;
  // Union the weekdays of every enabled reminder so the server learns every
  // day the user has any reminder for. Fall back to the time source's days
  // when nothing is enabled, so we still send a usable schedule.
  final weekdays = <int>{
    for (final r in enabled) ...r.weekdays,
  };
  if (weekdays.isEmpty) weekdays.addAll(timeSource.weekdays);
  return _PrayerReminder(
    hour: timeSource.hour,
    minute: timeSource.minute,
    weekdays: weekdays.toList()..sort(),
  );
}

Future<String> _resolveTimezone() async {
  try {
    return (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (e) {
    developer.log(
      'failed to resolve local timezone, falling back to UTC',
      name: 'profile_update_service',
      error: e,
    );
    return 'UTC';
  }
}

String _formatTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

// Converts Flutter's DateTime weekdays (Mon=1..Sun=7) to the JS backend's
// convention (Sun=0..Sat=6). Mon..Sat are unchanged by `% 7`; Sun (7) folds to 0.
List<int> _encodeWeekdays(List<int> weekdays) {
  final converted = weekdays.map((w) => w % 7).toSet().toList()..sort();
  return converted;
}

bool _listenersInstalled = false;

/// Installs listeners on the reminders + selected-people-group controllers so
/// that any change after the user has a `profile_id` is synced to the server
/// via PUT /api/profile/{id}. Safe to call multiple times.
void installProfileUpdateListeners() {
  if (_listenersInstalled) return;
  _listenersInstalled = true;
  remindersController.addListener(_onSyncTrigger);
  selectedPeopleGroupController.addListener(_onSyncTrigger);
}

void _onSyncTrigger() {
  final profileId = identityController.value?.profileId;
  if (profileId == null || profileId.isEmpty) return;
  submitProfileUpdate().catchError((Object e, StackTrace s) {
    developer.log(
      'profile update failed',
      name: 'profile_update_service',
      error: e,
      stackTrace: s,
    );
    // Non-fatal: the user's profile change silently failed to sync.
    reportError(e, s, reason: 'profile update failed');
  });
}
