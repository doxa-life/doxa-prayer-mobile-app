import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../router.dart';
import 'api_config.dart';
import 'crash_reporting_service.dart';
import 'identity_service.dart';
import 'reminders_notifications.dart';

/// OneSignal push-notification glue. Today the app only *receives* pushes;
/// server-triggered sending is a future step. This service:
///   - initialises the SDK (never prompting for permission — that stays owned
///     by the reminders flow, see [ensureNotificationPermission]),
///   - links the OneSignal `external_id` to our [AnonIdentity]
///     (`profileId`, falling back to `trackingId`),
///   - routes notification taps through the app's existing deep-link /
///     pray-override path so a push can open ANY people group's prayer page,
///   - registers the device's OneSignal subscription id with the campaigns
///     server so the eventual sender is ready to target it.

bool _initialized = false;

/// The external id we last called [OneSignal.login] with — avoids redundant
/// login calls when the identity notifier fires for unrelated field changes.
String? _lastExternalId;

/// `<subscriptionId>|<externalId>` of the last successful (or dev-skipped)
/// server registration — de-dupes repeat POSTs on every notifier tick.
String? _lastRegisteredKey;

Future<void> initPushNotifications() async {
  if (_initialized) return;
  if (!ApiConfig.hasOneSignal) {
    developer.log(
      'OneSignal not configured (no app id) — skipping push init',
      name: 'push_notifications_service',
    );
    return;
  }
  _initialized = true;

  if (kDebugMode) {
    OneSignal.Debug.setLogLevel(OSLogLevel.warn);
  }
  OneSignal.initialize(ApiConfig.oneSignalAppId);

  // NOTE: deliberately no requestPermission() here. The single OS notification
  // permission is shared with flutter_local_notifications and is requested
  // contextually by the reminders flow; that path nudges OneSignal to register
  // its token once granted.

  OneSignal.Notifications.addClickListener(_onNotificationClick);

  // Register/update the server whenever the OneSignal subscription id changes
  // (first token, reinstall, resubscribe).
  OneSignal.User.pushSubscription.addObserver((state) {
    final id = state.current.id;
    if (id != null && id.isNotEmpty) {
      unawaited(_registerPushWithServer(id));
    }
  });

  // Link external id now and on every identity change (anon-signup completing,
  // deferred signup, or a reset clearing identity).
  _syncExternalId(identityController.value);
  identityController.addListener(_onIdentityChanged);

  // Returning user whose token already exists — register it up-front.
  final existingId = OneSignal.User.pushSubscription.id;
  if (existingId != null && existingId.isNotEmpty) {
    unawaited(_registerPushWithServer(existingId));
  }
}

void _onIdentityChanged() => _syncExternalId(identityController.value);

/// Keeps the OneSignal external id in sync with our identity. Uses `profileId`
/// when present (so the future server sender can target by it), falling back to
/// the always-present `trackingId`. A null identity (reset) logs the device out.
void _syncExternalId(AnonIdentity? identity) {
  if (identity == null) {
    if (_lastExternalId != null) {
      _lastExternalId = null;
      _lastRegisteredKey = null;
      OneSignal.logout();
    }
    return;
  }

  final profileId = identity.profileId;
  final external = (profileId != null && profileId.isNotEmpty)
      ? profileId
      : identity.trackingId;
  if (external.isEmpty) return;

  // Tags keep both ids queryable/debuggable even if the external-id switch races.
  OneSignal.User.addTagWithKey('tracking_id', identity.trackingId);
  if (profileId != null && profileId.isNotEmpty) {
    OneSignal.User.addTagWithKey('profile_id', profileId);
  }

  if (external == _lastExternalId) return;
  _lastExternalId = external;
  OneSignal.login(external);

  // Re-register so the server row records the (possibly new) external id.
  final subId = OneSignal.User.pushSubscription.id;
  if (subId != null && subId.isNotEmpty) {
    unawaited(_registerPushWithServer(subId));
  }
}

void _onNotificationClick(OSNotificationClickEvent event) {
  final route = _routeFromData(event.notification.additionalData);
  if (route != null) {
    // Flows through _prayDeepLinkRedirect → setPrayOverride → /pray, so the
    // target group is shown even when the user isn't subscribed to it.
    //
    // On a cold start (app killed, then a notification tapped) this click fires
    // during app bootstrap, before GoRouter has attached and resolved its
    // `initialLocation: '/home'`. A direct go() here would be clobbered by that
    // initial-location resolution and the app would land on Home. Deferring to
    // after the first frame lets the deep link win — mirroring how the local
    // reminders cold-start tap is applied post-frame in AppShell.
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) => appRouter.go(route));
    // A cold-start click can arrive before runApp() has scheduled any frame;
    // request one so the callback above is guaranteed to run.
    binding.scheduleFrame();
    return;
  }
  // Generic "time to pray" push with no target group → user's own group,
  // via the same sink local reminders use.
  reminderTapPayload.value = 'pray';
}

/// Extracts an in-app route from a notification's `additionalData`. Accepts an
/// explicit `route` (e.g. `/<slug>/prayer`) or a bare `slug` (mapped to the
/// prayer deep-link route). Returns null for a slug-less/generic push.
String? _routeFromData(Map<String, dynamic>? data) {
  if (data == null) return null;
  final rawRoute = data['route'];
  if (rawRoute is String && rawRoute.startsWith('/')) return rawRoute;
  final slug = data['slug'];
  if (slug is String && slug.isNotEmpty) return '/$slug/prayer';
  return null;
}

/// Persists the OneSignal subscription (+ external id + platform) against the
/// subscriber on the campaigns server, so the future sender can target it.
/// Best-effort and de-duped; mirrors the anon-signup dev-skip guard.
Future<void> _registerPushWithServer(String subscriptionId) async {
  final identity = identityController.value;
  if (identity == null) return;

  final profileId = identity.profileId;
  final externalId = (profileId != null && profileId.isNotEmpty)
      ? profileId
      : identity.trackingId;
  final key = '$subscriptionId|$externalId';
  if (key == _lastRegisteredKey) return;

  final body = jsonEncode({
    'tracking_id': identity.trackingId,
    if (profileId != null && profileId.isNotEmpty) 'profile_id': profileId,
    'onesignal_subscription_id': subscriptionId,
    'platform': Platform.isIOS ? 'ios' : 'android',
  });
  final uri = ApiConfig.buildUri('/api/push/register');

  if (!kReleaseMode && !ApiConfig.hasAppSecret) {
    developer.log(
      'Skipping push register POST (dev build, no ANON_SIGNUP_SECRET)\n'
      'URL: $uri\nBody: $body',
      name: 'push_notifications_service',
    );
    _lastRegisteredKey = key;
    return;
  }

  try {
    final response = await http.post(
      uri,
      headers: ApiConfig.signupHeaders,
      body: body,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _lastRegisteredKey = key;
    } else {
      developer.log(
        'push register failed (${response.statusCode}): ${response.body}',
        name: 'push_notifications_service',
      );
    }
  } catch (e, s) {
    developer.log(
      'push register error',
      name: 'push_notifications_service',
      error: e,
      stackTrace: s,
    );
    reportError(e, s, reason: 'push register failed');
  }
}
