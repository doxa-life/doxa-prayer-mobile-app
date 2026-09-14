import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/people_group.dart';
import '../../theme/app_colors.dart';

/// Radius of an ordinary people-group pin, in logical pixels.
const double _pinRadius = 5.0;

/// The focused group's pin — the one the map was opened for — is drawn a little
/// larger so it can be picked out of a crowded region at a glance.
const double _focusedPinRadius = 8.0;

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

/// The group whose pin lies under [point] on screen, or null if the tap missed
/// every pin.
///
/// Returns the *closest* pin within [_tapRadius] rather than the first match,
/// so tapping into a cluster selects the one actually aimed at. The focused
/// group wins ties, being the larger target.
PeopleGroup? pinAt(
  Offset point, {
  required MapCamera camera,
  required List<PeopleGroup> groups,
  required String focusedSlug,
}) {
  PeopleGroup? best;
  var bestDistance = double.infinity;
  for (final group in groups) {
    final offset = camera.latLngToScreenOffset(
      LatLng(group.latitude!, group.longitude!),
    );
    final distance = (offset - point).distance;
    if (distance > _tapRadius) continue;
    // A tie inside a fraction of a pixel is arbitrary; prefer the focused pin.
    if (distance < bestDistance ||
        (distance == bestDistance && group.slug == focusedSlug)) {
      best = group;
      bestDistance = distance;
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

    // The focused pin is painted last so it is never buried under a neighbour
    // in a dense region.
    PeopleGroup? focused;
    for (final group in groups) {
      if (group.slug == focusedSlug) {
        focused = group;
        continue;
      }
      _paintPin(canvas, size, group, fill, border, selectionRing);
    }
    if (focused != null) {
      _paintPin(canvas, size, focused, fill, border, selectionRing);
    }
  }

  void _paintPin(
    Canvas canvas,
    Size size,
    PeopleGroup group,
    Paint fill,
    Paint border,
    Paint selectionRing,
  ) {
    final offset = camera.latLngToScreenOffset(
      LatLng(group.latitude!, group.longitude!),
    );
    final isFocused = group.slug == focusedSlug;
    final radius = isFocused ? _focusedPinRadius : _pinRadius;
    // Culling by the painted extent rather than the tap radius: an off-screen
    // pin can still be tapped near the edge, but it must not be drawn.
    final margin = radius + _borderWidth + 4;
    if (offset.dx < -margin ||
        offset.dy < -margin ||
        offset.dx > size.width + margin ||
        offset.dy > size.height + margin) {
      return;
    }

    fill.color = isFocused || subscribedSlugs.contains(group.slug)
        ? AppColors.secondary
        : AppColors.primaryLight;
    canvas.drawCircle(offset, radius, fill);
    canvas.drawCircle(offset, radius, border);
    if (group.slug == selectedSlug) {
      canvas.drawCircle(offset, radius + _borderWidth + 2, selectionRing);
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
