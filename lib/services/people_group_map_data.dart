import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../models/people_group.dart';

/// How many neighbours the map frames itself around when it opens. Enough that
/// the map never opens on one lonely pin in an empty region, few enough that a
/// dense area like the Indian subcontinent still opens zoomed in rather than
/// showing half a continent.
const int kMapNeighbourCount = 20;

LatLng? locationOf(PeopleGroup group) =>
    group.hasLocation ? LatLng(group.latitude!, group.longitude!) : null;

/// Squared great-circle-ish distance between two located groups, in degrees.
///
/// An equirectangular approximation — longitude degrees are narrowed by the
/// cosine of the latitude — which is plenty for ranking neighbours and far
/// cheaper than haversine across ~2,100 candidates. Only used for comparison,
/// so the square root is never taken.
double _rankingDistanceSquared(PeopleGroup a, PeopleGroup b) {
  final latA = a.latitude!;
  final dLat = b.latitude! - latA;
  // Normalised so two groups either side of the antimeridian read as close
  // together rather than a world apart.
  var dLon = (b.longitude! - a.longitude!) % 360;
  if (dLon > 180) dLon -= 360;
  if (dLon < -180) dLon += 360;
  final dx = dLon * math.cos(latA * math.pi / 180);
  return dx * dx + dLat * dLat;
}

/// The [count] located groups closest to [focus], nearest first, excluding
/// [focus] itself.
List<PeopleGroup> nearestGroups(
  PeopleGroup focus,
  List<PeopleGroup> candidates, {
  int count = kMapNeighbourCount,
}) {
  if (!focus.hasLocation) return const <PeopleGroup>[];
  final others = candidates
      .where((g) => g.hasLocation && g.slug != focus.slug)
      .toList();
  others.sort(
    (a, b) => _rankingDistanceSquared(
      focus,
      a,
    ).compareTo(_rankingDistanceSquared(focus, b)),
  );
  return others.take(count).toList(growable: false);
}

/// The coordinates the map should frame on open: [focus] plus its nearest
/// neighbours, so the zoom adapts to how densely packed the region is.
List<LatLng> openingFrame(
  PeopleGroup focus,
  List<PeopleGroup> candidates, {
  int count = kMapNeighbourCount,
}) {
  final origin = locationOf(focus);
  if (origin == null) return const <LatLng>[];
  return <LatLng>[
    origin,
    for (final g in nearestGroups(focus, candidates, count: count))
      LatLng(g.latitude!, g.longitude!),
  ];
}
