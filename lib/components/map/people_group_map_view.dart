import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/app_localizations.dart';
import '../../models/people_group.dart';
import '../../services/cached_map_tile_provider.dart';
import '../../services/map_config.dart';
import '../../services/people_group_map_data.dart';
import '../../services/prayer_history_service.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../buttons/map_recentre_button.dart';
import 'map_attribution_bar.dart';
import 'map_offline_notice.dart';
import 'people_group_pin_card.dart';
import 'people_group_pin_layer.dart';

/// How many tiles must fail in a row before the map admits it has no basemap.
/// More than one, so a single dropped request doesn't flash a notice at a user
/// whose connection is merely slow.
const int _offlineTileFailureThreshold = 4;

/// Padding around the opening fit, so the outermost neighbouring pin isn't
/// jammed against the edge of the map — and so the bottom row clears the pin
/// card that opens with it.
const EdgeInsets _fitPadding = EdgeInsets.fromLTRB(48, 48, 48, 180);

/// The map itself: every located people group as a pin, framed on [focus] and
/// its nearest neighbours.
class PeopleGroupMapView extends StatefulWidget {
  const PeopleGroupMapView({
    super.key,
    required this.focus,
    required this.groups,
    required this.onPray,
    required this.onProfile,
  });

  /// The group the map was opened for. Drawn larger, and what the recentre
  /// button returns to.
  final PeopleGroup focus;

  /// Every located people group, drawn as pins.
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

  /// The pin whose card is open. Starts on the focused group so the screen
  /// says whose map this is without the user having to find their own dot.
  late PeopleGroup? _selected = widget.focus;

  int _consecutiveTileFailures = 0;
  bool _tilesUnavailable = false;

  /// When a tile last *finished* loading successfully. Used to tell a genuinely
  /// new success from the tiles already on screen: the tile builder runs for
  /// every displayed tile on every build, so treating each of those as a
  /// success would reset the failure count continuously and the offline notice
  /// would never appear.
  DateTime _lastTileSuccessAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Whether the focused group has been panned or zoomed off screen. The
  /// recentre button only appears then: while the pin the map was opened for is
  /// still in view there is nothing to go back to.
  bool _focusOffScreen = false;

  /// The groups the user prays for. Read from the controller rather than held,
  /// so a tap and a repaint can never disagree about who is subscribed.
  Set<String> get _subscribedSlugs => {
    for (final g in peopleGroupsController.value.list) g.slug,
  };

  @override
  void initState() {
    super.initState();
    _tileProvider = CachedMapTileProvider();
    _openingFit = CameraFit.coordinates(
      coordinates: openingFrame(widget.focus, widget.groups),
      padding: _fitPadding,
      // Without a cap, a group whose neighbours are all but on top of it opens
      // at street level, which says nothing about where in the world it is.
      maxZoom: 9,
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
      focusedSlug: widget.focus.slug,
      subscribedSlugs: _subscribedSlugs,
    );
    // A tap on empty map dismisses the card; a tap on a pin swaps to it.
    setState(() => _selected = hit);
  }

  void _recentre() {
    _controller.fitCamera(_openingFit);
    setState(() {
      _selected = widget.focus;
      _focusOffScreen = false;
    });
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    final focus = locationOf(widget.focus);
    if (focus == null) return;
    final offScreen = !camera.visibleBounds.contains(focus);
    if (offScreen == _focusOffScreen) return;
    setState(() => _focusOffScreen = offScreen);
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
              label: '${l.mapOf(widget.focus.name)}. ${l.nearbyPeopleGroups}',
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
                    focusedSlug: widget.focus.slug,
                    subscribedSlugs: subscribedSlugs,
                    selectedSlug: _selected?.slug,
                  ),
                ],
              ),
            ),

            if (_tilesUnavailable)
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Center(
                  child: MapOfflineNotice(message: l.mapUnavailableOffline),
                ),
              ),
            if (_focusOffScreen)
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: MapRecentreButton(
                  onPressed: _recentre,
                  label: l.recenter,
                ),
              ),
            // Card and attribution share one bottom-aligned column so the
            // attribution is never covered by the card — Mapbox requires it to
            // stay visible, and an open card would otherwise sit on top of it.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selected != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: ValueListenableBuilder<Set<String>>(
                          valueListenable: prayedTodayController,
                          builder: (context, prayedSlugs, _) =>
                              PeopleGroupPinCard(
                                group: _selected!,
                                isSubscribed: subscribedSlugs.contains(
                                  _selected!.slug,
                                ),
                                prayedToday: prayedSlugs.contains(
                                  _selected!.slug,
                                ),
                                onPray: () => widget.onPray(_selected!),
                                onProfile: () => widget.onProfile(_selected!),
                                onClose: () => setState(() => _selected = null),
                              ),
                        ),
                      ),
                    const MapAttributionBar(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
