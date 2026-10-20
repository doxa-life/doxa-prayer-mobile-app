import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/app_localizations.dart';
import '../../models/people_group.dart';
import '../../services/cached_map_tile_provider.dart';
import '../../services/map_config.dart';
import '../../services/people_group_map_data.dart';
import '../../services/pulled_back_camera_fit.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../buttons/map_recentre_button.dart';
import 'map_attribution_bar.dart';
import 'map_legend.dart';
import 'map_offline_notice.dart';
import 'people_group_pin_layer.dart';
import 'people_group_pin_tooltip.dart';

/// How many tiles must fail in a row before the map admits it has no basemap.
/// More than one, so a single dropped request doesn't flash a notice at a user
/// whose connection is merely slow.
const int _offlineTileFailureThreshold = 4;

/// Padding around the opening fit, so the outermost pin isn't jammed against
/// the edge of the map — and so the top row clears the legend and the tooltip
/// that opens over the focused pin.
const EdgeInsets _fitPadding = EdgeInsets.fromLTRB(48, 130, 48, 60);

/// How far the map backs off from the tight fit around the opening frame, in
/// zoom levels. The tight fit puts the outermost pins at the edges of the
/// screen with nothing around them; a level out keeps the coastlines and
/// borders that say *where* this is in view.
const double _openingZoomOut = 1;

/// The closest the map opens on a single group: about one country across, so
/// the borders around the pin say where in the world it is.
const double _singleGroupMaxZoom = 6;

/// The whole inhabited world, for the overview map when the user prays for no
/// located group yet. Antarctica and the high Arctic are left out: no people
/// group lives there, and on a Mercator map they would take up half the
/// screen.
final LatLngBounds _worldBounds = LatLngBounds(
  const LatLng(-56, -168),
  const LatLng(72, 180),
);

/// The map itself: each of [groups] as a pin.
///
/// Opened for one group ([focus]) from its profile, [groups] is that group
/// alone and the map frames on it. Opened from the home screen's map button
/// ([focus] null), [groups] is every located group and the map frames on the
/// groups the user prays for, or on the whole world when there are none.
class PeopleGroupMapView extends StatefulWidget {
  const PeopleGroupMapView({
    super.key,
    this.focus,
    required this.groups,
    required this.onPray,
    required this.onProfile,
  });

  /// The group the map was opened for, if any. Drawn larger, opens with its
  /// tooltip showing, and is what the recentre button returns to.
  final PeopleGroup? focus;

  /// The groups drawn as pins.
  final List<PeopleGroup> groups;

  final void Function(PeopleGroup group) onPray;
  final void Function(PeopleGroup group) onProfile;

  @override
  State<PeopleGroupMapView> createState() => _PeopleGroupMapViewState();
}

class _PeopleGroupMapViewState extends State<PeopleGroupMapView> {
  final MapController _controller = MapController();
  late final CameraFit _openingFit;
  late final CachedMapTileProvider _tileProvider;

  /// What the recentre button watches for: the focused group, or the user's
  /// own groups on the overview. Empty on a world overview, which has nothing
  /// in particular to return to.
  late final List<LatLng> _home;

  /// The pin whose tooltip is open. Starts on the focused group so the screen
  /// says whose map this is without the user having to find their own pin.
  late PeopleGroup? _selected = widget.focus;

  int _consecutiveTileFailures = 0;
  bool _tilesUnavailable = false;

  /// When a tile last *finished* loading successfully. Used to tell a genuinely
  /// new success from the tiles already on screen: the tile builder runs for
  /// every displayed tile on every build, so treating each of those as a
  /// success would reset the failure count continuously and the offline notice
  /// would never appear.
  DateTime _lastTileSuccessAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Whether everything in [_home] has been panned or zoomed off screen. The
  /// recentre button only appears then: while it is still in view there is
  /// nothing to go back to.
  bool _homeOffScreen = false;

  /// The groups the user prays for. Read from the controller rather than held,
  /// so a tap and a repaint can never disagree about who is subscribed.
  Set<String> get _subscribedSlugs => {
    for (final g in peopleGroupsController.value.list) g.slug,
  };

  @override
  void initState() {
    super.initState();
    _tileProvider = CachedMapTileProvider();
    final focus = widget.focus;
    if (focus != null) {
      _home = [?locationOf(focus)];
      _openingFit = PulledBackCameraFit(
        inner: CameraFit.coordinates(
          coordinates: _home,
          padding: _fitPadding,
          // Without a cap, a lone pin opens at street level, which says
          // nothing about where in the world it is.
          maxZoom: _singleGroupMaxZoom,
        ),
        zoomOut: _openingZoomOut,
      );
      return;
    }
    _home = overviewFrame(_subscribedSlugs, widget.groups);
    _openingFit = _home.isEmpty
        ? CameraFit.bounds(
            bounds: _worldBounds,
            padding: const EdgeInsets.all(AppSpacing.sm),
          )
        : PulledBackCameraFit(
            inner: CameraFit.coordinates(
              coordinates: _home,
              padding: _fitPadding,
              // Lower than the single-group cap: this view is about where the
              // user's groups are in the world, not one neighbourhood — and a
              // user praying for one group would otherwise land zoomed right
              // in on it.
              maxZoom: 4,
            ),
            zoomOut: _openingZoomOut,
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    final hit = pinAt(
      tapPosition.relative ?? Offset.zero,
      camera: _controller.camera,
      groups: widget.groups,
      focusedSlug: widget.focus?.slug,
      subscribedSlugs: _subscribedSlugs,
    );
    if (hit != null && hit.slug != _selected?.slug) {
      HapticFeedback.selectionClick();
    }
    // A tap on empty map dismisses the tooltip; a tap on a pin swaps to it.
    setState(() => _selected = hit);
  }

  void _recentre() {
    _controller.fitCamera(_openingFit);
    setState(() {
      _selected = widget.focus;
      _homeOffScreen = false;
    });
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (_home.isEmpty) return;
    final bounds = camera.visibleBounds;
    final offScreen = !_home.any(bounds.contains);
    if (offScreen == _homeOffScreen) return;
    setState(() => _homeOffScreen = offScreen);
  }

  void _onTileError(TileImage tile, Object error, StackTrace? stackTrace) {
    if (!mounted || _tilesUnavailable) return;
    _consecutiveTileFailures++;
    if (_consecutiveTileFailures < _offlineTileFailureThreshold) return;
    // Checking whether tiles actually arrive beats asking the OS whether there
    // is a connection: a captive-portal wifi reports itself as connected and
    // still serves no tiles.
    setState(() => _tilesUnavailable = true);
  }

  void _onTileLoaded(DateTime finishedAt) {
    // Deferred by a frame from the tile builder, so the state may be gone.
    if (!mounted) return;
    if (!finishedAt.isAfter(_lastTileSuccessAt)) return;
    _lastTileSuccessAt = finishedAt;
    if (_consecutiveTileFailures == 0 && !_tilesUnavailable) return;
    setState(() {
      _consecutiveTileFailures = 0;
      _tilesUnavailable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final focus = widget.focus;
    return ValueListenableBuilder<SubscribedPeopleGroups>(
      valueListenable: peopleGroupsController,
      builder: (context, _, _) {
        final subscribedSlugs = _subscribedSlugs;
        return Stack(
          children: [
            // The pins carry no semantics of their own — they are painted, not
            // built — so the map announces what it is as a whole. Every group
            // on it is reachable through the browse list.
            Semantics(
              label: focus != null ? l.mapOf(focus.name) : l.map,
              image: true,
              child: FlutterMap(
                mapController: _controller,
                options: MapOptions(
                  initialCameraFit: _openingFit,
                  onTap: _onTap,
                  backgroundColor: AppColors.mutedSurface,
                  onPositionChanged: _onPositionChanged,
                  interactionOptions: const InteractionOptions(
                    // Rotation without a compass to undo it leaves users stuck
                    // on a crooked map they can't straighten.
                    //
                    // Double-tap zoom costs every single tap a 250ms wait while
                    // flutter_map decides whether a second one is coming — and
                    // tapping pins is what this map is for, so the lag is worse
                    // than the missing gesture. Pinch still zooms.
                    flags:
                        InteractiveFlag.all &
                        ~InteractiveFlag.rotate &
                        ~InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: MapConfig.tileUrlTemplate,
                    tileDimension: MapConfig.tileSize,
                    zoomOffset: MapConfig.tileZoomOffset,
                    tileProvider: _tileProvider,
                    userAgentPackageName: 'app.prayer.doxa',
                    errorTileCallback: _onTileError,
                    tileBuilder: (context, tileWidget, tile) {
                      final finishedAt = tile.loadFinishedAt;
                      if (finishedAt != null &&
                          !tile.loadError &&
                          finishedAt.isAfter(_lastTileSuccessAt)) {
                        // Deferred: the builder runs during layout, and the
                        // recovery flips state.
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _onTileLoaded(finishedAt),
                        );
                      }
                      return tileWidget;
                    },
                  ),
                  PeopleGroupPinLayer(
                    groups: widget.groups,
                    focusedSlug: focus?.slug,
                    subscribedSlugs: subscribedSlugs,
                    selectedSlug: _selected?.slug,
                  ),

                  // The map's own controls sit inside the map rather than over
                  // it, so an open tooltip is drawn above them instead of
                  // sliding underneath the legend.
                  //
                  // Legend and offline notice share one top-left column so they
                  // stack rather than overlap, and neither collides with the
                  // recentre button opposite them.
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.sm,
                      children: [
                        const MapLegend(),
                        if (_tilesUnavailable)
                          MapOfflineNotice(message: l.mapUnavailableOffline),
                      ],
                    ),
                  ),
                  if (_homeOffScreen)
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: MapRecentreButton(
                        onPressed: _recentre,
                        label: l.recenter,
                      ),
                    ),
                  PeopleGroupPinTooltipLayer(
                    group: _selected,
                    isSubscribed: (g) => subscribedSlugs.contains(g.slug),
                    onPray: widget.onPray,
                    onMoreInfo: widget.onProfile,
                    onClose: () => setState(() => _selected = null),
                  ),
                ],
              ),
            ),
            // Outside the map, and so above the tooltip: Mapbox requires the
            // attribution to stay visible, so nothing may cover it.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: MapAttributionBar(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
