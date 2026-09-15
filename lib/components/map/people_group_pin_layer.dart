import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/people_group.dart';
import '../../models/prayer_commitment.dart';
import '../../theme/app_colors.dart';
import '../../theme/prayer_commitment_colors.dart';
import 'heart_glyph.dart';

/// Radius of an ordinary people-group pin, in logical pixels.
const double _pinRadius = 5.0;

/// Radius of a pin for a group the user prays for, including the focused one.
/// Larger than its neighbours, and drawn as a heart rather than a circle, so
/// the groups that matter to this user can be picked out of a crowded region at
/// a glance. Colour is never used for that: it is spoken for by how many people
/// have committed to pray, which is what the map is about.
const double _primaryPinRadius = 8.0;

/// Font size of the heart glyph relative to the pin radius it replaces, tuned
/// so a heart carries about the same visual weight on the map as the circle of
/// that radius would.
const double _heartScale = 2.9;

/// White border around every pin, so pins stay legible against both the pale
/// land and the water of the `light-v11` basemap.
const double _borderWidth = 2.0;

/// How close a tap has to land to count as hitting a pin. Larger than the pin
/// itself: a 5 px dot is far below the ~48 px comfortable touch target, so the
/// hit area is grown rather than the pin.
const double _tapRadius = 22.0;

/// Every located people group, drawn onto a single canvas.
///
/// Deliberately *not* `MarkerLayer`: markers are Flutter widgets, and all
/// ~2,100 groups become live widgets whenever the map is zoomed out far enough
/// to see them all. Painting flat circles costs almost nothing at that count,
/// which is what lets the map show every group with no cap, no clustering and
/// no minimum zoom.
///
/// The trade is that these pins are invisible to the widget tree: no hit
/// testing, no semantics. Taps are resolved by [pinAt] from the map's own
/// `onTap`, and `PeopleGroupMapView` labels the map as a whole for screen
/// readers.
class PeopleGroupPinLayer extends StatelessWidget {
  const PeopleGroupPinLayer({
    super.key,
    required this.groups,
    required this.focusedSlug,
    required this.subscribedSlugs,
    this.selectedSlug,
  });

  /// Every group to draw. Groups without coordinates must already be filtered
  /// out.
  final List<PeopleGroup> groups;

  /// The group the map was opened for.
  final String focusedSlug;

  /// Groups the user prays for, drawn in the accent colour.
  final Set<String> subscribedSlugs;

  /// The group whose card is currently open, if any.
  final String? selectedSlug;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _PinPainter(
          camera: camera,
          groups: groups,
          focusedSlug: focusedSlug,
          subscribedSlugs: subscribedSlugs,
          selectedSlug: selectedSlug,
        ),
      ),
    );
  }
}

/// Pins closer together than this are treated as equally aimed at, and the one
/// painted on top wins. Without it a tap into a cluster can select a pin that
/// is hidden underneath the one the user can actually see.
const double _tapTieTolerance = 6.0;

/// The group whose pin lies under [point] on screen, or null if the tap missed
/// every pin.
///
/// Returns the closest pin within [_tapRadius], so tapping into a cluster
/// selects the one actually aimed at — but among pins that are effectively on
/// top of each other it returns whichever is drawn highest, matching what the
/// user sees: the focused group, then a subscribed one, then any other.
PeopleGroup? pinAt(
  Offset point, {
  required MapCamera camera,
  required List<PeopleGroup> groups,
  required String focusedSlug,
  required Set<String> subscribedSlugs,
}) {
  int layerOf(PeopleGroup g) => g.slug == focusedSlug
      ? 2
      : subscribedSlugs.contains(g.slug)
      ? 1
      : 0;

  PeopleGroup? best;
  var bestDistance = double.infinity;
  var bestLayer = -1;
  for (final group in groups) {
    final offset = camera.latLngToScreenOffset(
      LatLng(group.latitude!, group.longitude!),
    );
    final distance = (offset - point).distance;
    if (distance > _tapRadius) continue;
    final layer = layerOf(group);
    final tied = (distance - bestDistance).abs() <= _tapTieTolerance;
    if (tied ? layer > bestLayer : distance < bestDistance) {
      best = group;
      bestDistance = distance;
      bestLayer = layer;
    }
  }
  return best;
}

class _PinPainter extends CustomPainter {
  const _PinPainter({
    required this.camera,
    required this.groups,
    required this.focusedSlug,
    required this.subscribedSlugs,
    required this.selectedSlug,
  });

  final MapCamera camera;
  final List<PeopleGroup> groups;
  final String focusedSlug;
  final Set<String> subscribedSlugs;
  final String? selectedSlug;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderWidth
      ..color = AppColors.white;
    final selectionRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.primary;
    final fill = Paint()..style = PaintingStyle.fill;

    // Four passes, back to front. In a dense region pins overlap heavily, and
    // whichever is painted last is the one the user can actually see — so the
    // groups that matter to this user must never be buried under a stranger's
    // pin: ordinary groups first, then the ones they pray for, then the group
    // this map was opened for, and above everything the selected pin.
    //
    // The selected pin is lifted out of whichever pass it would otherwise
    // belong to and drawn last *with* its ring. Painting only the ring on top
    // isn't enough: the pin under it can still be covered by a later
    // neighbour, and the ring is then left circling somebody else's dot — or,
    // zoomed out, nothing at all.
    PeopleGroup? selected;
    PeopleGroup? focused;
    final subscribed = <PeopleGroup>[];
    for (final group in groups) {
      if (group.slug == selectedSlug) {
        selected = group;
      } else if (group.slug == focusedSlug) {
        focused = group;
      } else if (subscribedSlugs.contains(group.slug)) {
        subscribed.add(group);
      } else {
        _paintPin(canvas, size, group, fill, border);
      }
    }
    for (final group in subscribed) {
      _paintPin(canvas, size, group, fill, border);
    }
    if (focused != null) {
      _paintPin(canvas, size, focused, fill, border);
    }
    if (selected != null) {
      _paintPin(canvas, size, selected, fill, border);
      _paintSelectionRing(canvas, selected, selectionRing);
    }
  }

  void _paintSelectionRing(Canvas canvas, PeopleGroup group, Paint ring) {
    final isPrimary =
        group.slug == focusedSlug || subscribedSlugs.contains(group.slug);
    // A heart is wider than the circle of the same pin radius, so the ring is
    // sized from the glyph's own ink rather than from the radius.
    final enclosed = isPrimary
        ? _primaryPinRadius * _heartScale * kHeartInkRatio / 2
        : _pinRadius;
    canvas.drawCircle(
      camera.latLngToScreenOffset(LatLng(group.latitude!, group.longitude!)),
      enclosed + _borderWidth + 2,
      ring,
    );
  }

  void _paintPin(
    Canvas canvas,
    Size size,
    PeopleGroup group,
    Paint fill,
    Paint border,
  ) {
    final offset = camera.latLngToScreenOffset(
      LatLng(group.latitude!, group.longitude!),
    );
    final isPrimary =
        group.slug == focusedSlug || subscribedSlugs.contains(group.slug);
    final radius = isPrimary ? _primaryPinRadius : _pinRadius;
    // Culling by the painted extent rather than the tap radius: an off-screen
    // pin can still be tapped near the edge, but it must not be drawn.
    final margin = radius + _borderWidth + 4;
    if (offset.dx < -margin ||
        offset.dy < -margin ||
        offset.dx > size.width + margin ||
        offset.dy > size.height + margin) {
      return;
    }

    // Colour says how well covered the group is; shape says whether it is one
    // of the user's own.
    fill.color = prayerCommitmentLevelFor(group.peopleCommitted).color;
    if (isPrimary) {
      paintHeart(
        canvas,
        offset,
        size: radius * _heartScale,
        color: fill.color,
        borderColor: AppColors.white,
        borderWidth: _borderWidth,
      );
    } else {
      canvas.drawCircle(offset, radius, fill);
      canvas.drawCircle(offset, radius, border);
    }
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) =>
      oldDelegate.camera.center != camera.center ||
      oldDelegate.camera.zoom != camera.zoom ||
      oldDelegate.camera.rotation != camera.rotation ||
      oldDelegate.selectedSlug != selectedSlug ||
      oldDelegate.focusedSlug != focusedSlug ||
      !identical(oldDelegate.groups, groups) ||
      !setEquals(oldDelegate.subscribedSlugs, subscribedSlugs);
}
