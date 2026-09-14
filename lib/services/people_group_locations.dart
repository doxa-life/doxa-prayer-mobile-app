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

/// The slugs the app can open a map for, for the home cards' "show the map
/// button?" check. Recomputed on publish rather than per lookup — the carousel
/// rebuilds on every prayed-today change.
///
/// Empty when no Mapbox token is configured: a map with no tile source can only
/// ever show grey squares, so the button hides rather than leading somewhere
/// broken.
final ValueNotifier<Set<String>> mappablePeopleGroupSlugs =
    ValueNotifier<Set<String>>(const <String>{});

/// Records the located subset of [groups]. Called from the list decode; not
/// meant for anything else.
void publishPeopleGroupLocations(List<PeopleGroup> groups) {
  final located = groups.where((g) => g.hasLocation).toList(growable: false);
  peopleGroupLocationsController.value = located;
  mappablePeopleGroupSlugs.value = MapConfig.isConfigured
      ? located.map((g) => g.slug).toSet()
      : const <String>{};
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
