import 'package:flutter/foundation.dart';

import '../models/people_group.dart';
import 'locale_controller.dart';
import 'map_config.dart';
import 'people_groups_service.dart';

/// Every people group the app knows a location for, in whatever order the list
/// endpoint returned them.
///
/// Published by `people_groups_service.dart` each time the UUPG list is
/// decoded — which includes the startup warm of the disk cache, so this is
/// usually populated before the home screen's first frame without any request
/// being made. Empty until then: on a cold cache the home cards simply show no
/// map button, and `loadPeopleGroupLocations` fetches on demand.
final ValueNotifier<List<PeopleGroup>> peopleGroupLocationsController =
    ValueNotifier<List<PeopleGroup>>(const <PeopleGroup>[]);

/// Which slugs are known to have coordinates, or null while that isn't known
/// yet. Recomputed on publish rather than per lookup — the carousel rebuilds on
/// every prayed-today change.
///
/// Null is the important case, and it is a normal one: the list is cached per
/// language, so a fresh install — or simply switching the app's language —
/// leaves the app with no locations in hand even though every people group has
/// them server-side. See [canMapPeopleGroup].
final ValueNotifier<Set<String>?> peopleGroupSlugsWithLocation =
    ValueNotifier<Set<String>?>(null);

/// Whether a map can actually be opened for [slug] — that is, whether the home
/// card's map button should be enabled.
///
/// False only when the app *knows* the group has no coordinates. While [known]
/// is null it stays enabled and the map screen fetches what it needs: a cold
/// cache is not evidence of a missing location, and disabling on it would make
/// the button come and go for reasons a user cannot see.
///
/// Whether the button is shown at all is a separate question, answered by
/// [MapConfig.isConfigured]: a build with no Mapbox token has no map to offer.
bool canMapPeopleGroup(String slug, Set<String>? known) =>
    MapConfig.isConfigured && (known == null || known.contains(slug));

/// Records the located subset of [groups]. Called from the list decode; not
/// meant for anything else.
void publishPeopleGroupLocations(List<PeopleGroup> groups) {
  final located = groups.where((g) => g.hasLocation).toList(growable: false);
  peopleGroupLocationsController.value = located;
  peopleGroupSlugsWithLocation.value = located.map((g) => g.slug).toSet();
}

/// The located groups, fetching the UUPG list first if it isn't loaded yet.
///
/// The map screen calls this rather than reading the notifier directly: a user
/// who arrives with a cold cache (fresh install, or the cache swept while the
/// app was closed) still gets pins, at the cost of waiting for the list.
Future<List<PeopleGroup>> loadPeopleGroupLocations() async {
  if (peopleGroupLocationsController.value.isNotEmpty) {
    return peopleGroupLocationsController.value;
  }
  await fetchPeopleGroups(lang: localeController.value.languageCode);
  return peopleGroupLocationsController.value;
}
