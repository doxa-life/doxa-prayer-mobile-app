import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/prayer_content.dart';
import 'api_config.dart';
import 'cache_policy.dart';
import 'response_cache.dart';

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Cache key for one day's prayer content. Exposed so the Pray screen can peek
/// the in-memory cache before its first frame (see `CachedDataBuilder`); must
/// match what [fetchPrayerContent] stores under.
String prayerContentCacheKey({
  required String slug,
  required DateTime date,
  required String language,
}) => 'prayer-$slug-${_formatDate(date)}-$language';

/// One day's prayer content for [slug] in [language].
///
/// Cached on disk for [CachePolicy.prayerContent], keyed by group, date and
/// language — so revisiting the Pray tab, or stepping back to a day already
/// read, paints without a network round-trip. A day's content doesn't change
/// once that day has started, so there is no background revalidation here.
/// Pass [forceRefresh] for an explicit user retry.
Future<PrayerContentResponse> fetchPrayerContent({
  required String slug,
  required DateTime date,
  required String language,
  bool forceRefresh = false,
}) {
  final day = _formatDate(date);
  return getJsonCached(
    uri: ApiConfig.buildUri('/api/people-groups/$slug/prayer-content/$day', {
      'language': language,
    }),
    cacheKey: prayerContentCacheKey(slug: slug, date: date, language: language),
    ttl: CachePolicy.prayerContent,
    forceRefresh: forceRefresh,
    decode: (body) => PrayerContentResponse.fromJson(
      jsonDecode(body) as Map<String, dynamic>,
    ),
    errorMessage: (status) => 'Failed to load prayer content ($status)',
  );
}

class PrayerSessionReport {
  const PrayerSessionReport({
    required this.sessionId,
    required this.trackingId,
    required this.duration,
    required this.timestamp,
    this.trackEvent,
  });

  final String sessionId;
  final String trackingId;
  final int duration;
  final String timestamp;

  /// Tells the server to forward this save to the analytics backend. The app
  /// never calls that backend itself — `/session` does it for us, but only when
  /// this flag is set (it allows `prayer_auto_tracked` and `prayer_logged`).
  /// Set it on the explicit Amen only, so the pings a session makes while it is
  /// still running don't each raise an event. Left null, nothing is forwarded.
  final String? trackEvent;

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'tracking_id': trackingId,
    'duration': duration,
    'timestamp': timestamp,
    if (trackEvent != null) 'track_event': trackEvent,
  };
}

Future<void> postPrayerSession({
  required String slug,
  required DateTime date,
  required PrayerSessionReport report,
}) async {
  final uri = ApiConfig.buildUri(
    '/api/people-groups/$slug/prayer-content/${_formatDate(date)}/session',
  );
  final body = jsonEncode(report.toJson());
  if (!kReleaseMode) {
    developer.log(
      'Skipping prayer session POST (non-production build)\n'
      'URL: $uri\n'
      'Body: $body',
      name: 'prayer_content_service',
    );
    return;
  }
  final response = await http.post(
    uri,
    headers: const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: body,
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to log prayer session (${response.statusCode})');
  }
}
