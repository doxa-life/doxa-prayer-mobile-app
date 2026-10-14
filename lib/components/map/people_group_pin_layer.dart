import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/people_group.dart';
import '../../models/prayer_commitment.dart';
import '../../theme/app_colors.dart';
import '../../services/map_screen_offsets.dart';
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

/// Radius of the halo behind every group the user prays for. Shape alone (a
/// heart among circles) is easy to miss in a crowded region at a glance; the
/// halo makes their own groups the first thing the eye lands on without
/// borrowing a commitment colour, which is what the pin's fill is for.
const double kPrayingHaloRadius = 16.0;

/// The halo's fill and rim. Exposed so the legend can draw the same thing.
final Color kPrayingHaloFill = AppColors.primary.withValues(alpha: 0.16);
final Color kPrayingHaloRim = AppColors.primary.withValues(alpha: 0.55);
const double kPrayingHaloRimWidth = 1.5;

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

  /// The group the map was opened for, or null for the overview map opened
  /// from the home screen.
  final String? focusedSlug;

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

/// Every group's position at zoom 0 and its pin colour, worked out once per
/// list. At any other zoom a position is just this one scaled — `Epsg3857`'s
/// transformation is linear in scale — so a frame of panning costs a multiply
/// and an add per pin instead of the Mercator log/tan for all ~2,100 of them.
class _Projected {
  _Projected(List<PeopleGroup> groups)
    : xs = Float64List(groups.length),
      ys = Float64List(groups.length),
      colours = Uint8List(groups.length) {
    const crs = Epsg3857();
    for (var i = 0; i < groups.length; i++) {
      final g = groups[i];
      final o = crs.latLngToOffset(LatLng(g.latitude!, g.longitude!), 0);
      xs[i] = o.dx;
      ys[i] = o.dy;
      colours[i] = prayerCommitmentLevelFor(g.peopleCommitted).index;
    }
  }

  final Float64List xs;
  final Float64List ys;

  /// [PrayerCommitmentLevel.index] per group.
  final Uint8List colours;
}

/// Keyed on the list object itself: the map is handed the same list for its
/// whole life, and a new list (after a refresh) simply gets projected anew.
final Expando<_Projected> _projections = Expando<_Projected>('pin projections');

/// One point buffer per commitment colour, kept between frames: allocating
/// them afresh would hand the garbage collector a few hundred kilobytes on
/// every frame of a pan. Painting is synchronous, so sharing them is safe.
List<Float32List> _sharedPointBuffers = const [];

List<Float32List> _pointBuffers(int length) {
  final current = _sharedPointBuffers;
  if (current.isEmpty || current.first.length < length) {
    _sharedPointBuffers = [
      for (final _ in PrayerCommitmentLevel.values) Float32List(length),
    ];
  }
  return _sharedPointBuffers;
}

/// Most copies of the world a pin can appear in at once. Zoomed fully out a
/// phone shows about two worlds side by side; this leaves room for a tablet
/// in landscape.
const int _maxWorldCopies = 4;

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
  required String? focusedSlug,
  required Set<String> subscribedSlugs,
}) {
  int layerOf(PeopleGroup g) => g.slug == focusedSlug
      ? 2
      : subscribedSlugs.contains(g.slug)
      ? 1
      : 0;

  final worldWidth = camera.getWorldWidthAtZoom();
  PeopleGroup? best;
  var bestDistance = double.infinity;
  var bestLayer = -1;
  for (final group in groups) {
    // Every visible copy of the world, matching what the painter draws.
    var distance = double.infinity;
    for (final offset in screenOffsetsOf(
      camera,
      LatLng(group.latitude!, group.longitude!),
      margin: _tapRadius,
      worldWidth: worldWidth,
    )) {
      final d = (offset - point).distance;
      if (d < distance) distance = d;
    }
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
  _PinPainter({
    required this.camera,
    required this.groups,
    required this.focusedSlug,
    required this.subscribedSlugs,
    required this.selectedSlug,
  });

  final MapCamera camera;
  final List<PeopleGroup> groups;
  final String? focusedSlug;
  final Set<String> subscribedSlugs;
  final String? selectedSlug;

  /// Worked out once per painter rather than once per pin. A new painter is
  /// built for every camera change, so it never goes stale.
  late final double _worldWidth = camera.getWorldWidthAtZoom();

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
    final haloFill = Paint()
      ..style = PaintingStyle.fill
      ..color = kPrayingHaloFill;
    final haloRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = kPrayingHaloRimWidth
      ..color = kPrayingHaloRim;

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
    final fast = camera.crs is Epsg3857 && camera.rotation == 0;
    final ordinary = fast ? <int>[] : null;
    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];
      if (group.slug == selectedSlug) {
        selected = group;
      } else if (group.slug == focusedSlug) {
        focused = group;
      } else if (subscribedSlugs.contains(group.slug)) {
        subscribed.add(group);
      } else if (ordinary != null) {
        ordinary.add(i);
      } else {
        _paintPin(canvas, size, group, fill, border);
      }
    }
    if (ordinary != null) _paintOrdinaryPins(canvas, size, ordinary);
    // Halos go down in a pass of their own, before any of the user's pins:
    // painted with each pin, a halo would wash over the neighbouring heart
    // drawn just before it.
    for (final group in [...subscribed, ?focused, ?selected]) {
      if (!subscribedSlugs.contains(group.slug)) continue;
      _paintHalo(canvas, size, group, haloFill, haloRim);
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

  /// Draws the ordinary pins — nearly all of them — in four calls: one for
  /// every white outline, then one per commitment colour, as round points.
  /// Two `drawCircle`s per pin cost thousands of draw calls a frame, which is
  /// what pinned the CPU while the map moved.
  ///
  /// The trade: overlapping pins now share one outline rather than each
  /// drawing its own over the last, so a dense cluster reads as one blob with
  /// a white edge instead of a stack of separate discs.
  void _paintOrdinaryPins(Canvas canvas, Size size, List<int> indices) {
    final projected = _projections[groups] ??= _Projected(groups);
    final crs = camera.crs;
    final scale = crs.scale(camera.zoom) / crs.scale(0);
    final origin =
        camera.projectAtZoom(camera.center) -
        camera.nonRotatedSize.center(Offset.zero);
    final worldWidth = _worldWidth;
    const margin = _pinRadius + _borderWidth + 4;
    final maxX = size.width + margin;
    final maxY = size.height + margin;

    // Upper bound on points per colour; trimmed with a view at the end.
    final buffers = _pointBuffers(indices.length * 2 * _maxWorldCopies);
    final counts = List<int>.filled(PrayerCommitmentLevel.values.length, 0);
    for (final i in indices) {
      final y = projected.ys[i] * scale - origin.dy;
      if (y < -margin || y > maxY) continue;
      var x = projected.xs[i] * scale - origin.dx;
      if (worldWidth > 0) {
        // Into the leftmost copy of the world that can still be on screen.
        x -= worldWidth * ((x + margin) / worldWidth).floorToDouble();
      }
      final c = projected.colours[i];
      final buffer = buffers[c];
      var copies = 0;
      for (; x <= maxX && copies < _maxWorldCopies; x += worldWidth) {
        if (x >= -margin) {
          buffer[counts[c]++] = x;
          buffer[counts[c]++] = y;
        }
        copies++;
        if (worldWidth <= 0) break;
      }
    }

    final outline = Paint()
      ..color = AppColors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (_pinRadius + _borderWidth / 2) * 2;
    for (var c = 0; c < buffers.length; c++) {
      if (counts[c] == 0) continue;
      canvas.drawRawPoints(
        ui.PointMode.points,
        Float32List.sublistView(buffers[c], 0, counts[c]),
        outline,
      );
    }
    final dot = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (_pinRadius - _borderWidth / 2) * 2;
    for (var c = 0; c < buffers.length; c++) {
      if (counts[c] == 0) continue;
      dot.color = PrayerCommitmentLevel.values[c].color;
      canvas.drawRawPoints(
        ui.PointMode.points,
        Float32List.sublistView(buffers[c], 0, counts[c]),
        dot,
      );
    }
  }

  void _paintHalo(
    Canvas canvas,
    Size size,
    PeopleGroup group,
    Paint haloFill,
    Paint haloRim,
  ) {
    for (final offset in _visibleOffsets(group, size, kPrayingHaloRadius)) {
      canvas.drawCircle(offset, kPrayingHaloRadius, haloFill);
      canvas.drawCircle(offset, kPrayingHaloRadius, haloRim);
    }
  }

  /// Every on-screen copy of [group]'s pin, culled by the painted extent
  /// rather than the tap radius: an off-screen pin can still be tapped near
  /// the edge, but it must not be drawn.
  Iterable<Offset> _visibleOffsets(
    PeopleGroup group,
    Size size,
    double extent,
  ) sync* {
    final margin = extent + _borderWidth + 4;
    for (final offset in screenOffsetsOf(
      camera,
      LatLng(group.latitude!, group.longitude!),
      margin: margin,
      worldWidth: _worldWidth,
    )) {
      if (offset.dy < -margin || offset.dy > size.height + margin) continue;
      yield offset;
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
    for (final offset in screenOffsetsOf(
      camera,
      LatLng(group.latitude!, group.longitude!),
      margin: enclosed + _borderWidth + 4,
      worldWidth: _worldWidth,
    )) {
      canvas.drawCircle(offset, enclosed + _borderWidth + 2, ring);
    }
  }

  void _paintPin(
    Canvas canvas,
    Size size,
    PeopleGroup group,
    Paint fill,
    Paint border,
  ) {
    final isPrimary =
        group.slug == focusedSlug || subscribedSlugs.contains(group.slug);
    final radius = isPrimary ? _primaryPinRadius : _pinRadius;
    // Colour says how well covered the group is; shape says whether it is one
    // of the user's own.
    fill.color = prayerCommitmentLevelFor(group.peopleCommitted).color;
    final extent = isPrimary ? radius * _heartScale / 2 : radius;
    for (final offset in _visibleOffsets(group, size, extent)) {
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
