import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'crash_reporting_service.dart';
import 'identity_service.dart';
import 'reminder_schedule.dart';
import 'reminders_controller.dart';
import 'subscribed_people_groups_controller.dart';
import 'timezone_resolver.dart';

/// Pushes one people group's reminder schedule to its own subscription row.
/// Each subscribed group has its own `subscription_id` and its own schedule
/// server-side, so there is nothing global to send — a group with no
/// subscription id yet is skipped, and anon-signup will register it instead.
Future<void> submitProfileUpdateForGroup(SubscribedPeopleGroup group) async {
  final identity = identityController.value;
  final profileId = identity?.profileId;
  if (profileId == null || profileId.isEmpty) return;
  final subscriptionId = group.subscriptionId;
  if (subscriptionId == null) return;

  final schedule = scheduleForGroup(group.slug);
  final timezone = await resolveTimezone(logName: 'profile_update_service');

  final payload = <String, dynamic>{
    'subscription_id': subscriptionId,
    'frequency': schedule.frequency,
    'time_preference': schedule.time,
    'days_of_week': schedule.encodedWeekdays,
    'timezone': timezone,
    // Deliberately no `people_group_slug`: that field *moves* a subscription to
    // another group, which is exactly what multi-group subscriptions replaced.
    // Each row stays pointed at the group it was created for.
    if (peopleGroupsController.value.activeSlug == group.slug)
      'consent_people_group_slug': group.slug,
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
    'PUT profile for ${group.slug}\nURL: $uri\nBody: $body',
    name: 'profile_update_service',
  );
  final response = await http.put(
    uri,
    headers: ApiConfig.signupHeaders,
    body: body,
  );
  if (response.statusCode != 200) {
    throw Exception('profile update failed (${response.statusCode})');
  }

  // The server can hand back a different row id if it merged this subscription
  // into an existing one; adopt it so a later unsubscribe names the survivor.
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  final returnedId =
      (json['currentSubscription'] as Map<String, dynamic>?)?['id'];
  if (returnedId is num && returnedId.toInt() != subscriptionId) {
    await setPeopleGroupSubscriptionId(group.slug, returnedId.toInt());
  }
}

/// Signature of what was last accepted by the server for a slug. Comparing
/// against it means a reminder edit syncs only the group it belongs to, rather
/// than issuing one PUT per subscribed group on every change.
final Map<String, String> _lastSent = <String, String>{};

String _signature(String slug) {
  final s = scheduleForGroup(slug);
  return '${s.frequency}|${s.time}|${s.encodedWeekdays.join(',')}';
}

Timer? _debounce;
bool _listenersInstalled = false;

/// Watches the reminder list and the subscription list, and syncs any group
/// whose schedule has actually changed. Safe to call multiple times.
///
/// Call after the initial loads: the current state is taken as already-synced,
/// so a cold start does not re-PUT every group's unchanged schedule.
void installProfileUpdateListeners() {
  if (_listenersInstalled) return;
  _listenersInstalled = true;
  for (final group in peopleGroupsController.value.list) {
    _lastSent[group.slug] = _signature(group.slug);
  }
  remindersController.addListener(_onSyncTrigger);
  peopleGroupsController.addListener(_onSyncTrigger);
}

/// Coalesces the burst of notifier changes a single user action produces —
/// saving a reminder persists, reschedules and may add a group — into one pass.
void _onSyncTrigger() {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), _syncChangedGroups);
}

void _syncChangedGroups() {
  final profileId = identityController.value?.profileId;
  if (profileId == null || profileId.isEmpty) return;

  final groups = peopleGroupsController.value.list;
  _lastSent.removeWhere((slug, _) => !groups.any((g) => g.slug == slug));

  for (final group in groups) {
    final signature = _signature(group.slug);
    if (_lastSent[group.slug] == signature) continue;
    submitProfileUpdateForGroup(group)
        .then((_) => _lastSent[group.slug] = signature)
        .catchError((Object e, StackTrace s) {
          developer.log(
            'profile update failed for ${group.slug}',
            name: 'profile_update_service',
            error: e,
            stackTrace: s,
          );
          // Non-fatal, and deliberately not recorded as sent: the next change
          // retries it.
          reportError(e, s, reason: 'profile update failed');
        });
  }
}

/// Forgets what the server is believed to hold, so the next change re-sends
/// every group. Used by the debug screen's reset.
void resetProfileUpdateState() => _lastSent.clear();
