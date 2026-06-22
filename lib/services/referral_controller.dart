import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared state for the "referred" people group slug — the group a user came in
/// for via a "Pray on the app" link.
///
/// Written from two sources:
///   - the Android Play install referrer (see install_referrer_service.dart), for
///     fresh installs, and
///   - an incoming deep link (`/app/<slug>`, see router.dart), when the app is
///     already installed but onboarding isn't finished.
///
/// Read once by the onboarding wizard, which auto-selects the group and then
/// clears it (see wizard_controller.dart).
const _referredSlugKey = 'referred_people_group_slug';

final ValueNotifier<String?> referredPeopleGroupController =
    ValueNotifier<String?>(null);

Future<void> loadReferredPeopleGroup() async {
  final prefs = SharedPreferencesAsync();
  final slug = await prefs.getString(_referredSlugKey);
  referredPeopleGroupController.value = slug;
  debugPrint('[deferred] loaded referred people group slug=${slug ?? '(none)'}');
}

Future<void> setReferredPeopleGroup(String slug) async {
  if (slug.isEmpty) return;
  referredPeopleGroupController.value = slug;
  final prefs = SharedPreferencesAsync();
  await prefs.setString(_referredSlugKey, slug);
  debugPrint('[deferred] set referred people group slug="$slug"');
}

Future<void> clearReferredPeopleGroup() async {
  referredPeopleGroupController.value = null;
  final prefs = SharedPreferencesAsync();
  await prefs.remove(_referredSlugKey);
  debugPrint('[deferred] cleared referred people group');
}
