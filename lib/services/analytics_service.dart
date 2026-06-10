import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'api_config.dart';
import 'identity_service.dart';
import 'locale_controller.dart';
import 'selected_people_group_controller.dart';

/// First-party analytics relay for the app. Posts usage events to the
/// campaigns-server `/api/collect/app` endpoint, which forwards them to the
/// analytics backend server-side (keeping the analytics key off the client).
///
/// Identity travels as the device's [AnonIdentity.trackingId] (the
/// `anonymous_hash` the backend issued at anon-signup). Events are best-effort:
/// every call is fire-and-forget and swallows its own errors so analytics can
/// never break a user-facing flow.

const _appOpenEvent = 'app_open';
const _languageSwitchedEvent = 'language_switched';

/// Records an app-open event (cold start and each foreground resume).
void trackAppOpen() {
  _track(
    eventType: _appOpenEvent,
    metadata: <String, dynamic>{
      'people_group_slug': ?selectedPeopleGroupController.value?.slug,
    },
  );
}

/// Records a user-initiated language switch. [language] is the newly selected
/// language code; [previous] (when supplied) is recorded in metadata.
void trackLanguageSwitched(String language, {String? previous}) {
  _track(
    eventType: _languageSwitchedEvent,
    language: language,
    metadata: <String, dynamic>{
      'previous_language': ?previous,
    },
  );
}

/// Posts an event to `/api/collect/app`. Fire-and-forget: callers do not await
/// and never see failures.
void _track({
  required String eventType,
  String? language,
  Map<String, dynamic>? metadata,
}) {
  _send(eventType: eventType, language: language, metadata: metadata)
      .catchError((Object e, StackTrace s) {
    developer.log(
      'analytics event "$eventType" failed',
      name: 'analytics_service',
      error: e,
      stackTrace: s,
    );
  });
}

Future<void> _send({
  required String eventType,
  String? language,
  Map<String, dynamic>? metadata,
}) async {
  final enrichedMetadata = <String, dynamic>{
    ...?metadata,
    'platform': defaultTargetPlatform.name,
    'app_version': await _appVersion(),
  };

  final body = jsonEncode(<String, dynamic>{
    'event_type': eventType,
    'anonymous_hash': identityController.value?.trackingId ?? '',
    'language': language ?? localeController.value.languageCode,
    'metadata': enrichedMetadata,
  });

  final uri = ApiConfig.buildUri('/api/collect/app');

  if (!kReleaseMode && !ApiConfig.hasAppSecret) {
    developer.log(
      'Skipping analytics POST (dev build, no ANON_SIGNUP_SECRET)\n'
      'URL: $uri\n'
      'Body: $body',
      name: 'analytics_service',
    );
    return;
  }

  final response = await http.post(
    uri,
    headers: ApiConfig.signupHeaders,
    body: body,
  );
  // The endpoint acks with 202 Accepted (fire-and-forget on the server too).
  if (response.statusCode != 202) {
    throw Exception('collect/app failed (${response.statusCode})');
  }
}

String? _cachedAppVersion;

Future<String?> _appVersion() async {
  if (_cachedAppVersion != null) return _cachedAppVersion;
  try {
    final info = await PackageInfo.fromPlatform();
    return _cachedAppVersion = info.version;
  } catch (e) {
    developer.log(
      'failed to resolve app version',
      name: 'analytics_service',
      error: e,
    );
    return null;
  }
}
