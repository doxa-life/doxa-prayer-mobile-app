import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// How many people are in a prayer session right now, across the app and the
/// web prayer pages. Drives the "X people praying with you" line on the Pray
/// screen.
///
/// Deliberately NOT routed through `response_cache.dart`: that layer falls back
/// to an expired copy when a refetch fails, which is right for prayer content
/// and wrong here — a stale "812 people praying with you" from yesterday is
/// worse than showing nothing. The server already caches this for ~5 minutes.
///
/// Returns null on any failure, and callers hide the line rather than
/// substituting a zero.
Future<int?> fetchPrayingNow() async {
  final uri = ApiConfig.buildUri('/api/people-groups/statistics');
  try {
    final response = await http.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) return null;
    final value = json['praying_now'];
    return value is num ? value.toInt() : null;
  } catch (e, s) {
    developer.log(
      'failed to fetch praying-now count',
      name: 'prayer_stats_service',
      error: e,
      stackTrace: s,
    );
    return null;
  }
}

/// The most recently fetched "praying now" count, or null before the first
/// successful fetch. Drives the banner on the Pray screen.
///
/// A controller rather than per-widget state because the Pray tab lives in an
/// `IndexedStack` — its widgets are never disposed, so a `initState` fetch would
/// run once for the app's whole lifetime. Refreshing is therefore driven by the
/// session lifecycle (see `_startSession`), not by mounting.
final ValueNotifier<int?> prayingNowController = ValueNotifier<int?>(null);

/// Refetches the count and publishes it to [prayingNowController].
///
/// A failed fetch leaves the previous value in place rather than clearing it:
/// the banner hides on null, and blinking out on one dropped request reads worse
/// than briefly showing the last known figure.
Future<void> refreshPrayingNow() async {
  final count = await fetchPrayingNow();
  if (count == null) return;
  prayingNowController.value = count;
}
