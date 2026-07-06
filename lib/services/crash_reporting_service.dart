import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show appFlavor;

import 'device_context_service.dart';
import 'identity_service.dart';

/// Firebase Crashlytics glue. Routes the Flutter/platform error handlers to
/// Crashlytics and enriches every report with *who* (the anon identity) and
/// *where* (flavor + device context), so a crash is actionable rather than a
/// bare stack trace.
///
/// Mirrors [initPushNotifications] in push_notifications_service.dart: a
/// top-level init plus an [identityController] listener that keeps the crash
/// user id in step with the identity as it changes.

bool _initialized = false;

/// Wires up crash reporting. Call once, immediately after
/// `Firebase.initializeApp()` and before the rest of startup, so crashes during
/// the remaining bootstrap are captured too.
Future<void> initCrashReporting() async {
  if (_initialized) return;
  _initialized = true;

  final crashlytics = FirebaseCrashlytics.instance;

  // No crash noise from local dev / hot-reload; collect in profile + release
  // only. Reports queue on disk and upload on the next launch.
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

  // Flutter framework errors (build/layout/gesture) → fatal.
  FlutterError.onError = crashlytics.recordFlutterFatalError;

  // Errors escaping the framework (async gaps, platform channels) → fatal.
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  // The build variant a crash came from (production / staging).
  await crashlytics.setCustomKey('flavor', appFlavor ?? 'none');

  // Who: seed now and keep in sync on every identity change (anon-signup
  // completing, deferred signup, or a reset clearing identity).
  _syncUser(identityController.value);
  identityController.addListener(_onIdentityChanged);

  // Where (device/os/app version) — async and best-effort; don't block startup.
  unawaited(_setDeviceKeys());
}

void _onIdentityChanged() => _syncUser(identityController.value);

/// Sets the Crashlytics user id to the same id push uses ([AnonIdentity.profileId]
/// when present, else the always-present [AnonIdentity.trackingId]), plus
/// queryable custom keys. A null identity (reset) clears the id. Note: the
/// user's email is server-redacted and never reaches the app, so we only ever
/// use ids here — never an email.
void _syncUser(AnonIdentity? identity) {
  final crashlytics = FirebaseCrashlytics.instance;
  if (identity == null) {
    unawaited(crashlytics.setUserIdentifier(''));
    return;
  }

  final profileId = identity.profileId;
  final userId = (profileId != null && profileId.isNotEmpty)
      ? profileId
      : identity.trackingId;
  unawaited(crashlytics.setUserIdentifier(userId));

  unawaited(crashlytics.setCustomKey('tracking_id', identity.trackingId));
  if (profileId != null && profileId.isNotEmpty) {
    unawaited(crashlytics.setCustomKey('profile_id', profileId));
  }
  final subscriptionId = identity.subscriptionId;
  if (subscriptionId != null) {
    unawaited(crashlytics.setCustomKey('subscription_id', subscriptionId));
  }
}

/// Copies the cached device context (platform, os_version, device_model,
/// app_version, app_build, timezone) into Crashlytics custom keys.
Future<void> _setDeviceKeys() async {
  try {
    final context = await gatherDeviceContext();
    final crashlytics = FirebaseCrashlytics.instance;
    for (final entry in context.entries) {
      await crashlytics.setCustomKey(entry.key, entry.value);
    }
  } catch (e, s) {
    developer.log(
      'failed to set Crashlytics device keys',
      name: 'crash_reporting_service',
      error: e,
      stackTrace: s,
    );
  }
}

/// Records a *non-fatal* (handled) error with an optional [reason] for grouping
/// in the console. Use at the best-effort catch sites that currently only
/// `developer.log`. Best-effort itself — never throws back into the caller.
Future<void> reportError(
  Object error,
  StackTrace stack, {
  String? reason,
}) async {
  try {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: false,
    );
  } catch (e) {
    developer.log(
      'failed to record non-fatal error',
      name: 'crash_reporting_service',
      error: e,
    );
  }
}

/// Adds a breadcrumb to the Crashlytics log — the trail of what happened before
/// a crash. Used by the router observer; safe to call from key flows too.
void leaveCrashBreadcrumb(String message) {
  FirebaseCrashlytics.instance.log(message);
}
