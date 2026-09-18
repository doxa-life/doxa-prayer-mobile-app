import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'crash_reporting_service.dart';
import 'identity_service.dart';
import 'locale_controller.dart';
import 'reminder_schedule.dart';
import 'subscribed_people_groups_controller.dart';
import 'timezone_resolver.dart';
import 'wizard_completion_controller.dart';

/// Records a prayer commitment to [slug] on the server. The endpoint is an
/// upsert per (subscriber, people group), so calling it once per subscribed
/// group is how the app registers all of them — nothing here moves or replaces
/// an existing subscription.
Future<void> submitAnonSignup({
  required String slug,
  String name = '',
  String email = '',
  bool consentDoxaGeneral = false,
  bool consentPeopleGroupUpdates = false,
}) async {
  final schedule = scheduleForGroup(slug);
  final timezone = await resolveTimezone(logName: 'anon_signup_service');
  final body = jsonEncode({
    'tracking_id': identityController.value?.trackingId ?? '',
    'frequency': schedule.frequency,
    'time': schedule.time,
    'days_of_week': schedule.encodedWeekdays,
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
  final subscriptionId = (json['subscription_id'] as num?)?.toInt();
  await setIdentity(
    trackingId: json['tracking_id'] as String?,
    profileId: json['profile_id'] as String?,
    subscriptionId: subscriptionId,
  );
  // Store the id against the group, not just on the identity: unsubscribing
  // later has to name this exact subscription so the person's email
  // subscriptions for the same group are left alone.
  if (subscriptionId != null) {
    await setPeopleGroupSubscriptionId(slug, subscriptionId);
  }
}

bool _deferredListenerInstalled = false;

void installDeferredAnonSignupListener() {
  if (_deferredListenerInstalled) return;
  _deferredListenerInstalled = true;
  peopleGroupsController.addListener(_maybeFireDeferredSignup);
}

/// Catches the first subscription made before the user finished onboarding —
/// the wizard selects a group before the signup step has run. Groups added
/// afterwards are signed up by the add flow itself, and are skipped here
/// because they already carry a subscription id.
void _maybeFireDeferredSignup() {
  if (!wizardCompletedController.value) return;
  for (final group in peopleGroupsController.value.list) {
    if (group.subscriptionId != null) continue;
    submitAnonSignup(slug: group.slug).catchError((Object e, StackTrace s) {
      developer.log(
        'deferred anon-signup failed',
        name: 'anon_signup_service',
        error: e,
        stackTrace: s,
      );
      // Non-fatal: the user believes they signed up but the request failed.
      reportError(e, s, reason: 'deferred anon-signup failed');
    });
  }
}
