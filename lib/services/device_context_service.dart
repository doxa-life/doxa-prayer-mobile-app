import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Cached device context — the values don't change within a session, so we only
/// gather them once.
Map<String, String>? _cached;

/// Collects a small map of diagnostic device data to attach to feedback:
/// `platform`, `os_version`, `device_model`, `app_version`, `app_build`,
/// `timezone`. Every lookup is guarded so a single failure just omits that key
/// rather than blocking the feedback flow. Result is cached after first call.
Future<Map<String, String>> gatherDeviceContext() async {
  if (_cached != null) return _cached!;

  final context = <String, String>{};

  context['platform'] = switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'ios',
    TargetPlatform.android => 'android',
    _ => defaultTargetPlatform.name,
  };

  try {
    final info = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = await info.androidInfo;
      context['os_version'] = 'Android ${android.version.release}';
      context['device_model'] = '${android.manufacturer} ${android.model}'.trim();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = await info.iosInfo;
      context['os_version'] = '${ios.systemName} ${ios.systemVersion}';
      context['device_model'] = ios.utsname.machine;
    }
  } catch (e) {
    developer.log('failed to resolve device info', name: 'device_context', error: e);
  }

  try {
    final pkg = await PackageInfo.fromPlatform();
    if (pkg.version.isNotEmpty) context['app_version'] = pkg.version;
    if (pkg.buildNumber.isNotEmpty) context['app_build'] = pkg.buildNumber;
  } catch (e) {
    developer.log('failed to resolve app version', name: 'device_context', error: e);
  }

  try {
    context['timezone'] = (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (e) {
    developer.log('failed to resolve timezone', name: 'device_context', error: e);
  }

  return _cached = context;
}
