import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'referral_controller.dart';

const _checkedFlagKey = 'install_referrer_checked';

/// Reads the Google Play install referrer **once** (Android only) and, if it carries
/// a `utm_content=<slug>`, stashes that slug as the referred people group so the
/// onboarding wizard can auto-select it after a fresh install.
///
/// No-op on iOS (no install-referrer equivalent) and on every run after the first —
/// the referrer is only meaningful for the install that produced it.
Future<void> fetchInstallReferrer() async {
  if (!Platform.isAndroid) return;
  final prefs = SharedPreferencesAsync();
  if (await prefs.getBool(_checkedFlagKey) ?? false) return;
  try {
    final details = await AndroidPlayInstallReferrer.installReferrer;
    final slug = _slugFromReferrer(details.installReferrer);
    if (slug != null) {
      await setReferredPeopleGroup(slug);
    }
  } catch (e, s) {
    developer.log(
      'install referrer lookup failed',
      name: 'install_referrer_service',
      error: e,
      stackTrace: s,
    );
  } finally {
    // Only attempt once per install, whatever the outcome.
    await prefs.setBool(_checkedFlagKey, true);
  }
}

/// Pulls `utm_content` out of a referrer string such as
/// `utm_source=doxa_web&utm_medium=referral&utm_content=<slug>`.
String? _slugFromReferrer(String? referrer) {
  if (referrer == null || referrer.isEmpty) return null;
  final slug = Uri.splitQueryString(referrer)['utm_content']?.trim();
  return (slug == null || slug.isEmpty) ? null : slug;
}
