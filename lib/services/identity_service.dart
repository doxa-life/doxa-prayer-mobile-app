import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnonIdentity {
  const AnonIdentity({
    required this.trackingId,
    this.profileId,
    this.subscriptionId,
  });

  final String trackingId;
  final String? profileId;
  final int? subscriptionId;
}

const _trackingIdKey = 'identity_tracking_id';
const _profileIdKey = 'identity_profile_id';
const _subscriptionIdKey = 'identity_subscription_id';

final ValueNotifier<AnonIdentity?> identityController =
    ValueNotifier<AnonIdentity?>(null);

Future<void> loadIdentity() async {
  final prefs = SharedPreferencesAsync();
  final trackingId = await prefs.getString(_trackingIdKey);
  if (trackingId == null || trackingId.isEmpty) return;
  final profileId = await prefs.getString(_profileIdKey);
  final subscriptionId = await prefs.getInt(_subscriptionIdKey);
  identityController.value = AnonIdentity(
    trackingId: trackingId,
    profileId: profileId,
    subscriptionId: subscriptionId,
  );
}

/// Merges the provided fields into the persisted identity. Fields passed as
/// `null` preserve any existing stored value (so a news-signup response that
/// omits `subscription_id` does not clobber it).
Future<void> setIdentity({
  String? trackingId,
  String? profileId,
  int? subscriptionId,
}) async {
  final existing = identityController.value;
  final nextTracking = trackingId ?? existing?.trackingId;
  if (nextTracking == null || nextTracking.isEmpty) return;
  final nextProfile = profileId ?? existing?.profileId;
  final nextSubscription = subscriptionId ?? existing?.subscriptionId;

  identityController.value = AnonIdentity(
    trackingId: nextTracking,
    profileId: nextProfile,
    subscriptionId: nextSubscription,
  );

  final prefs = SharedPreferencesAsync();
  await prefs.setString(_trackingIdKey, nextTracking);
  if (nextProfile != null) {
    await prefs.setString(_profileIdKey, nextProfile);
  }
  if (nextSubscription != null) {
    await prefs.setInt(_subscriptionIdKey, nextSubscription);
  }
}

Future<void> clearIdentity() async {
  identityController.value = null;
  final prefs = SharedPreferencesAsync();
  await prefs.remove(_trackingIdKey);
  await prefs.remove(_profileIdKey);
  await prefs.remove(_subscriptionIdKey);
}
