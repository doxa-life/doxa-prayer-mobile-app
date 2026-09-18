import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'crash_reporting_service.dart';

/// Records a people-group photo that failed to load, so the next one shows up
/// on its own instead of waiting for a tester to mention it.
///
/// `AppImage` draws the same grey placeholder whether a group has no photo at
/// all or its photo failed — deliberately, since both leave the same hole in
/// the layout — which means a failure is invisible from the outside. That is
/// how a whole class of permanently-blank photos went unreported until someone
/// happened to notice.
///
/// Two limits keep this from becoming noise:
///  * a URL is reported once per launch, because `errorWidget` rebuilds every
///    time its card scrolls back into view;
///  * the launch as a whole is capped, because a user who is simply offline
///    would otherwise report every photo they scroll past. The first few
///    already say everything the rest would.
const int _maxPerSession = 10;

final Set<String> _reported = <String>{};

/// The sink failures go to. Swapped in tests; the real one is the Crashlytics
/// non-fatal path.
Future<void> Function(Object, StackTrace, {String? reason}) _report =
    reportError;

@visibleForTesting
set imageFailureReporter(
  Future<void> Function(Object, StackTrace, {String? reason}) reporter,
) => _report = reporter;

@visibleForTesting
void resetImageFailureReports() => _reported.clear();

/// Reports that [url] could not be loaded, with the [error] the image pipeline
/// raised. Best-effort and silent: this runs from a widget's `errorWidget`
/// builder and must never throw back into a build.
void reportImageFailure(String url, Object error) {
  if (_reported.length >= _maxPerSession) return;
  if (!_reported.add(url)) return;

  developer.log(
    'photo failed to load: $url',
    name: 'image_failure_reporter',
    error: error,
  );
  // One call site, so every report groups together in the console; the URL
  // rides in the reason, where it stays readable per report.
  unawaited(
    _report(
      error,
      StackTrace.current,
      reason: 'people-group photo failed to load: $url',
    ),
  );
}
