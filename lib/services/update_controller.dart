import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'version_check_service.dart';

const _dismissedVersionKey = 'update_dismissed_version';

enum UpdateState {
  /// No update needed (or check failed — fail open).
  none,

  /// A newer version exists; show a dismissible banner.
  optional,

  /// The running version is below the minimum supported; block until updated.
  forced,
}

class UpdateStatus {
  const UpdateStatus(this.state, [this.info]);

  final UpdateState state;
  final AppVersionInfo? info;

  static const none = UpdateStatus(UpdateState.none);
}

/// Drives the in-app update banner/modal. Mirrors the ValueNotifier pattern used
/// by [wizardCompletedController].
final ValueNotifier<UpdateStatus> updateController =
    ValueNotifier<UpdateStatus>(UpdateStatus.none);

/// Fetches the server version gate, compares it against the running build and
/// updates [updateController]. Network/parse failures fail open (UpdateState.none)
/// so a backend hiccup never blocks the app.
Future<void> checkForAppUpdate() async {
  try {
    final info = await fetchAppVersionInfo();
    final packageInfo = await PackageInfo.fromPlatform();
    final current = packageInfo.version;

    if (_isLower(current, info.minSupportedVersion)) {
      updateController.value = UpdateStatus(UpdateState.forced, info);
      return;
    }

    if (_isLower(current, info.latestVersion)) {
      final prefs = SharedPreferencesAsync();
      final dismissed = await prefs.getString(_dismissedVersionKey);
      if (dismissed == info.latestVersion) {
        updateController.value = UpdateStatus.none;
        return;
      }
      updateController.value = UpdateStatus(UpdateState.optional, info);
      return;
    }

    updateController.value = UpdateStatus.none;
  } catch (e) {
    developer.log('app update check failed', name: 'update', error: e);
    updateController.value = UpdateStatus.none;
  }
}

/// Remembers that the user dismissed the optional update for this version, so the
/// banner stays hidden until a newer version is released.
Future<void> dismissOptionalUpdate() async {
  final info = updateController.value.info;
  updateController.value = UpdateStatus.none;
  if (info == null) return;
  final prefs = SharedPreferencesAsync();
  await prefs.setString(_dismissedVersionKey, info.latestVersion);
}

/// Starts the platform update flow.
///   Android → native in-app update (background download / "restart to install").
///   iOS & others → deep-link to the store listing.
/// [immediate] selects Play's blocking flow, used for forced updates.
Future<void> startAppUpdate({bool immediate = false}) async {
  final info = updateController.value.info;

  if (Platform.isAndroid) {
    try {
      final result = await InAppUpdate.checkForUpdate();
      if (result.updateAvailability == UpdateAvailability.updateAvailable) {
        if (immediate) {
          await InAppUpdate.performImmediateUpdate();
        } else {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        }
        return;
      }
    } catch (e) {
      developer.log('in_app_update failed, falling back to store', name: 'update', error: e);
    }
    await _openStore(info?.androidPlayUrl);
    return;
  }

  // iOS and any other platform: open the store listing.
  await _openStore(info?.iosAppStoreUrl);
}

Future<void> _openStore(String? url) async {
  if (url == null || url.isEmpty) return;
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Compares two `major.minor.patch` strings. Returns true when [a] < [b].
bool _isLower(String a, String b) {
  final pa = _parse(a);
  final pb = _parse(b);
  for (var i = 0; i < 3; i++) {
    if (pa[i] != pb[i]) return pa[i] < pb[i];
  }
  return false;
}

List<int> _parse(String version) {
  // Drop any build/pre-release suffix (e.g. "1.0.0+3" → "1.0.0").
  final core = version.split('+').first.split('-').first;
  final parts = core.split('.');
  return [
    _intAt(parts, 0),
    _intAt(parts, 1),
    _intAt(parts, 2),
  ];
}

int _intAt(List<String> parts, int i) =>
    i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0;
