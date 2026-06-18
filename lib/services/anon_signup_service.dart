import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'identity_service.dart';
import 'locale_controller.dart';
import 'reminders_controller.dart';
import 'selected_people_group_controller.dart';
import 'wizard_completion_controller.dart';

Future<void> submitAnonSignup({
  required String slug,
  String name = '',
  String email = '',
  bool consentDoxaGeneral = false,
  bool consentPeopleGroupUpdates = false,
}) async {
  final reminder = _selectPrayerReminder();
  final timezone = await _resolveTimezone();
  final body = jsonEncode({
    'tracking_id': identityController.value?.trackingId ?? '',
    'frequency': reminder.weekdays.length == 7 ? 'daily' : 'weekly',
    'time': _formatTime(reminder.hour, reminder.minute),
    'days_of_week': _encodeWeekdays(reminder.weekdays),
    'timezone': timezone,
    'language': localeController.value.languageCode,
    'email': email,
    'name': name,
    'consent_doxa_general': consentDoxaGeneral,
    'consent_people_group_updates': consentPeopleGroupUpdates,
  });

  final uri = ApiConfig.buildUri('/api/people-groups/$slug/anon-signup');

  if (!kReleaseMode && !ApiConfig.hasAppSecret) {
    developer.log(
      'Skipping anon-signup POST (dev build, no ANON_SIGNUP_SECRET)\n'
      'URL: $uri\n'
      'Body: $body',
      name: 'anon_signup_service',
    );
    return;
  }

  final response = await http.post(
    uri,
    headers: ApiConfig.signupHeaders,
    body: body,
  );
  if (response.statusCode != 200) {
    throw Exception('anon-signup failed (${response.statusCode})');
  }
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  await setIdentity(
    trackingId: json['tracking_id'] as String?,
    profileId: json['profile_id'] as String?,
    subscriptionId: (json['subscription_id'] as num?)?.toInt(),
  );
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
      name: 'anon_signup_service',
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

bool _deferredListenerInstalled = false;

void installDeferredAnonSignupListener() {
  if (_deferredListenerInstalled) return;
  _deferredListenerInstalled = true;
  selectedPeopleGroupController.addListener(_maybeFireDeferredSignup);
}

void _maybeFireDeferredSignup() {
  final group = selectedPeopleGroupController.value;
  if (group == null) return;
  if (!wizardCompletedController.value) return;
  if (identityController.value?.subscriptionId != null) return;
  submitAnonSignup(slug: group.slug).catchError((Object e, StackTrace s) {
    developer.log(
      'deferred anon-signup failed',
      name: 'anon_signup_service',
      error: e,
      stackTrace: s,
    );
  });
}
