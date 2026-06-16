import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// The server-driven app version gate (see GET /api/app/version).
class AppVersionInfo {
  const AppVersionInfo({
    required this.latestVersion,
    required this.minSupportedVersion,
    this.iosAppStoreUrl,
    required this.androidPlayUrl,
  });

  /// Latest released version (semver, e.g. "1.1.0").
  final String latestVersion;

  /// Minimum supported version; below this the app must force an update.
  final String minSupportedVersion;

  /// Deep link to the App Store listing (null when the iOS id is unset).
  final String? iosAppStoreUrl;

  /// Deep link to the Google Play listing.
  final String androidPlayUrl;

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      latestVersion: json['latest_version'] as String,
      minSupportedVersion: json['min_supported_version'] as String,
      iosAppStoreUrl: json['ios_app_store_url'] as String?,
      androidPlayUrl: json['android_play_url'] as String,
    );
  }
}

Future<AppVersionInfo> fetchAppVersionInfo() async {
  final uri = ApiConfig.buildUri('/api/app/version');
  final response = await http.get(
    uri,
    headers: const {'Accept': 'application/json'},
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to load app version info (${response.statusCode})');
  }
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  return AppVersionInfo.fromJson(body);
}
