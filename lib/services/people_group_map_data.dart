import 'package:latlong2/latlong.dart';

import '../models/people_group.dart';

LatLng? locationOf(PeopleGroup group) =>
    group.hasLocation ? LatLng(group.latitude!, group.longitude!) : null;

/// The coordinates the overview map frames on open:
/// the groups the user prays for, so the overview starts on what matters to
/// them. Empty when they pray for none (or none are located), which the map
/// takes to mean "show the whole world".
List<LatLng> overviewFrame(
  Iterable<String> subscribedSlugs,
  List<PeopleGroup> candidates,
) {
  final slugs = subscribedSlugs.toSet();
  return <LatLng>[
    for (final g in candidates)
      if (slugs.contains(g.slug) && g.hasLocation)
        LatLng(g.latitude!, g.longitude!),
  ];
}
