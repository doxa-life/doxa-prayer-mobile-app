import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/prayer_content.dart';

const _host = 'pray.doxa.life';

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

Future<PrayerContentResponse> fetchPrayerContent({
  required String slug,
  required DateTime date,
  required String language,
}) async {
  final uri = Uri.https(
    _host,
    '/api/people-groups/$slug/prayer-content/${_formatDate(date)}',
    {'language': language},
  );
  final response = await http.get(
    uri,
    headers: const {'Accept': 'application/json'},
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to load prayer content (${response.statusCode})');
  }
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  return PrayerContentResponse.fromJson(body);
}

class PrayerSessionReport {
  const PrayerSessionReport({
    required this.sessionId,
    required this.trackingId,
    required this.duration,
    required this.timestamp,
  });

  final String sessionId;
  final String trackingId;
  final int duration;
  final String timestamp;

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'trackingId': trackingId,
    'duration': duration,
    'timestamp': timestamp,
  };
}

Future<void> postPrayerSession({
  required String slug,
  required DateTime date,
  required PrayerSessionReport report,
}) async {
  final uri = Uri.https(
    _host,
    '/api/people-groups/$slug/prayer-content/${_formatDate(date)}/session',
  );
  final response = await http.post(
    uri,
    headers: const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(report.toJson()),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to log prayer session (${response.statusCode})');
  }
}
