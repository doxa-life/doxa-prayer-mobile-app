import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Where [point] sits on screen in every copy of the world that is visible.
///
/// `flutter_map` repeats the world sideways, and the camera's centre wraps
/// back into -180..180 as the user pans across the antimeridian. Projecting a
/// pin once puts it in a single copy of the world only — so a group in Fiji
/// vanishes, or reappears a whole world away, the moment the view crosses the
/// date line. The tiles don't do that, so without this the pins and the
/// basemap disagree about where a group is.
///
/// [margin] keeps copies just off screen, for painting a pin that is only
/// partly in view and for taps that land near the edge.
///
/// Pass [worldWidth] (from `camera.getWorldWidthAtZoom()`) when calling this
/// for every pin in a frame: working it out costs two projections, which adds
/// up across a couple of thousand pins.
Iterable<Offset> screenOffsetsOf(
  MapCamera camera,
  LatLng point, {
  double margin = 0,
  double? worldWidth,
}) sync* {
  final base = camera.latLngToScreenOffset(point);
  worldWidth ??= camera.getWorldWidthAtZoom();
  final width = camera.nonRotatedSize.width;
  if (worldWidth <= 0) {
    yield base;
    return;
  }
  // Step back to the leftmost copy that can still be in view, then walk right
  // until past the screen. Zoomed far out, several copies fit at once.
  var x = base.dx;
  while (x - worldWidth >= -margin) {
    x -= worldWidth;
  }
  while (x < -margin) {
    x += worldWidth;
  }
  for (; x <= width + margin; x += worldWidth) {
    yield Offset(x, base.dy);
  }
}

/// The on-screen copy of [point] nearest the middle of the map — where a
/// tooltip for it should be anchored. Falls back to the plain projection when
/// no copy is in view, so a pin panned away takes its tooltip with it rather
/// than the tooltip jumping to another world.
Offset nearestScreenOffsetOf(MapCamera camera, LatLng point) {
  final base = camera.latLngToScreenOffset(point);
  final worldWidth = camera.getWorldWidthAtZoom();
  if (worldWidth <= 0) return base;
  final centreX = camera.nonRotatedSize.width / 2;
  final shifts = ((centreX - base.dx) / worldWidth).roundToDouble();
  return Offset(base.dx + shifts * worldWidth, base.dy);
}
