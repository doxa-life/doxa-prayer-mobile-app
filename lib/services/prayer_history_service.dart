import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _historyKey = 'prayer_history';

class PrayerRecord {
  const PrayerRecord({
    required this.slug,
    required this.durationSeconds,
    required this.timestamp,
    required this.openedAtTimestamp,
  });

  final String slug;
  final int durationSeconds;
  final String timestamp;
  final String openedAtTimestamp;

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'durationSeconds': durationSeconds,
    'timestamp': timestamp,
    'openedAtTimestamp': openedAtTimestamp,
  };

  factory PrayerRecord.fromJson(Map<String, dynamic> json) => PrayerRecord(
    slug: json['slug'] as String,
    durationSeconds: json['durationSeconds'] as int,
    timestamp: json['timestamp'] as String,
    openedAtTimestamp: json['openedAtTimestamp'] as String,
  );
}

Future<List<PrayerRecord>> loadPrayerHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_historyKey);
  if (raw == null) return [];
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => PrayerRecord.fromJson(e as Map<String, dynamic>))
      .toList();
}

Future<void> recordPrayer(PrayerRecord record) async {
  if (!kReleaseMode) {
    developer.log(
      'Prayer Recorded: ${jsonEncode(record.toJson())}',
      name: 'prayer_history_service',
    );
  }
  final prefs = await SharedPreferences.getInstance();
  final history = await loadPrayerHistory();
  history.add(record);
  final encoded = jsonEncode(history.map((r) => r.toJson()).toList());
  await prefs.setString(_historyKey, encoded);
}
