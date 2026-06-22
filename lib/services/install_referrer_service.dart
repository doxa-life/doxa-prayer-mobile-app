import 'dart:io' show Platform;

import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'referral_controller.dart';

// Greppable tag for the deferred-deep-link diagnostics. These use debugPrint
// (not dart:developer log) so they surface in `adb logcat -s flutter`, not only
// in DevTools — filter with `adb logcat -s flutter | grep '\[deferred\]'`.
const _tag = '[deferred]';

const _checkedFlagKey = 'install_referrer_checked';

/// The single in-flight (or completed) lookup, so repeated calls share one
/// operation. The wizard awaits this to close the cold-start race; startup
/// fires it. Reset by [clearInstallReferrerChecked] so a debug re-test re-runs.
Future<void>? _lookup;

/// Reads the Google Play install referrer **once** (Android only) and, if it carries
/// a `utm_content=<slug>`, stashes that slug as the referred people group so the
/// onboarding wizard can auto-select it after a fresh install.
///
/// Idempotent: every call returns the same in-flight future, so startup and the
/// wizard await a single lookup rather than triggering several.
///
/// No-op on iOS (no install-referrer equivalent) and on every run after the first —
/// the referrer is only meaningful for the install that produced it.
Future<void> fetchInstallReferrer() => _lookup ??= _runInstallReferrerLookup();

Future<void> _runInstallReferrerLookup() async {
  if (!Platform.isAndroid) {
    debugPrint('$_tag install referrer: not Android — skipping');
    return;
  }
  final prefs = SharedPreferencesAsync();
  if (await prefs.getBool(_checkedFlagKey) ?? false) {
    debugPrint(
      '$_tag install referrer: already checked this install (flag set) — '
      'skipping. Clear it from the Debug screen to re-test.',
    );
    return;
  }
  try {
    final details = await AndroidPlayInstallReferrer.installReferrer;
    debugPrint(
      '$_tag install referrer received: '
      'referrer="${details.installReferrer}" '
      'clickTs=${details.referrerClickTimestampSeconds} '
      'installBeginTs=${details.installBeginTimestampSeconds} '
      'instant=${details.googlePlayInstantParam}',
    );
    final slug = _slugFromReferrer(details.installReferrer);
    if (slug != null) {
      debugPrint(
        '$_tag parsed utm_content slug="$slug" — storing as referred people group',
      );
      await setReferredPeopleGroup(slug);
    } else {
      debugPrint('$_tag no utm_content in referrer — nothing to defer');
    }
  } catch (e, s) {
    debugPrint('$_tag install referrer lookup failed: $e\n$s');
  } finally {
    // Only attempt once per install, whatever the outcome.
    await prefs.setBool(_checkedFlagKey, true);
  }
}

/// Clears the "already checked" flag so the next launch re-reads the Play install
/// referrer. Used by the Debug screen to re-test the deferred deep-link flow
/// without a full uninstall/reinstall (which is otherwise required because
/// `flutter run` reinstalls keep SharedPreferences). Does not clear the stored
/// referred slug — clear that separately if you want a clean slate.
Future<void> clearInstallReferrerChecked() async {
  final prefs = SharedPreferencesAsync();
  await prefs.remove(_checkedFlagKey);
  // Drop the cached lookup so the next fetchInstallReferrer() actually re-reads,
  // even without a relaunch (e.g. re-testing from the Debug screen).
  _lookup = null;
  debugPrint('$_tag cleared install-referrer checked flag');
}

/// Pulls `utm_content` out of a referrer string such as
/// `utm_source=doxa_web&utm_medium=referral&utm_content=<slug>`.
String? _slugFromReferrer(String? referrer) {
  if (referrer == null || referrer.isEmpty) return null;
  final slug = Uri.splitQueryString(referrer)['utm_content']?.trim();
  return (slug == null || slug.isEmpty) ? null : slug;
}
