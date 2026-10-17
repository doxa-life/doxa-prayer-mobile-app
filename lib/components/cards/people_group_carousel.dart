import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../services/map_config.dart';
import '../../services/people_group_locations.dart';
import '../../services/prayer_history_service.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../layouts/design_scale.dart';
import '../../theme/app_spacing.dart';
import 'add_people_group_card.dart';
import 'profile_deck.dart' show DeckArrowButton, ProfileDeckDots;
import 'people_group_card.dart';

/// The people groups the user prays for, as a menu with one card always in
/// focus. Cards stay in the order they were added — a card the user is reaching
/// for never slides away — and the neighbouring cards are left peeking, drawn
/// smaller and fainter, so the row reads as something to swipe through.
///
/// The focused card is always centred: a swipe moves one card and settles on
/// it, with a selection haptic as each new card comes into focus, and tapping a
/// neighbour brings it into focus rather than acting on it. Bringing a group
/// into focus makes it the active group (the one the Pray tab will show) —
/// focus is the only cue saying which group is active, so it also follows the
/// active group whenever it changes, including a switch made from the Pray tab
/// while this screen sat in the background.
class PeopleGroupCarousel extends StatefulWidget {
  const PeopleGroupCarousel({
    super.key,
    required this.groups,
    required this.activeSlug,
    required this.onPray,
    required this.onDetails,
    required this.onShare,
    required this.onMap,
    required this.onAdd,
    this.onFocus,
  });

  final List<SubscribedPeopleGroup> groups;
  final String? activeSlug;
  final ValueChanged<SubscribedPeopleGroup> onPray;
  final ValueChanged<SubscribedPeopleGroup> onDetails;
  final ValueChanged<SubscribedPeopleGroup> onShare;
  final ValueChanged<SubscribedPeopleGroup> onMap;
  final VoidCallback onAdd;

  /// Called when the user settles on a group other than the active one — the
  /// home screen makes it the active group.
  final ValueChanged<SubscribedPeopleGroup>? onFocus;

  @override
  State<PeopleGroupCarousel> createState() => _PeopleGroupCarouselState();
}

class _PeopleGroupCarouselState extends State<PeopleGroupCarousel> {
  final ScrollController _controller = ScrollController();

  /// The cards sit inside this padding so their shadows have somewhere to fall.
  /// A scroll view clips at its own bounds, so without it every card loses its
  /// shadow along the bottom.
  static const double _gutter = AppSpacing.md;

  static const double _gap = AppSpacing.lg;

  /// The least of each neighbouring card that shows beside the focused one. A
  /// screen wider than the design leaves more.
  static const double _peek = AppSpacing.xl;

  /// How the cards out of focus are drawn, at a full card's distance from it.
  static const double _unfocusedScale = 0.9;
  static const double _unfocusedOpacity = 0.6;

  /// The card in focus — the centred one, or mid-swipe the one nearest the
  /// centre. The "add another" card counts, as the last card.
  ///
  /// A notifier rather than state: focus moves mid-swipe, and only each
  /// card's tap handling depends on it. A setState here rebuilt — and
  /// re-measured, through the IntrinsicHeight — every card in the row on the
  /// frame the swipe crossed between two of them.
  final ValueNotifier<int> _focused = ValueNotifier<int>(0);

  /// What moves a card's scale, fade and tap handling: the scroll and focus.
  late final Listenable _motion = Listenable.merge([_controller, _focused]);

  /// Distance between neighbouring cards' centres, from the last layout.
  double _itemExtent = 1;

  /// The slug the scroll position was last aligned to, so an alignment runs
  /// once per change of active group rather than on every rebuild.
  String? _alignedTo;

  /// False until the first alignment has happened, which is the one that must
  /// not animate — the carousel should already be in place when it is first
  /// looked at.
  bool _hasAligned = false;

  /// Set while the carousel is following the active group by itself, so the
  /// cards it passes don't tick a haptic the user did nothing to cause.
  bool _aligning = false;

  int get _cardCount =>
      widget.groups.length + (widget.groups.length < kMaxPeopleGroups ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _focused.value = _activeIndex.clamp(0, _cardCount - 1);
    _controller.addListener(_trackFocus);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focused.dispose();
    super.dispose();
  }

  int get _activeIndex =>
      widget.groups.indexWhere((g) => g.slug == widget.activeSlug);

  void _trackFocus() {
    final index = (_controller.offset / _itemExtent).round().clamp(
      0,
      _cardCount - 1,
    );
    if (index == _focused.value) return;
    _focused.value = index;
    if (!_aligning) HapticFeedback.selectionClick();
  }

  /// With half the leftover width as padding on each side, card [index] is
  /// centred exactly at this offset — the first and last cards included.
  double _offsetOf(int index) => index * _itemExtent;

  void _alignToActive() {
    if (_alignedTo == widget.activeSlug) return;
    _alignedTo = widget.activeSlug;
    final index = _activeIndex;
    if (index < 0) return;
    final animate = _hasAligned;
    _hasAligned = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_controller.hasClients) return;
      final target = _offsetOf(
        index,
      ).clamp(0.0, _controller.position.maxScrollExtent);
      _aligning = true;
      // Animating only matters when the user can see it happen; a switch made
      // from the Pray tab lands here before this screen is looked at again.
      if (animate && (_controller.offset - target).abs() > 1) {
        await _controller.animateTo(
          target,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        _controller.jumpTo(target);
      }
      _aligning = false;
    });
  }

  /// Brings a neighbouring card into focus when it is tapped.
  void _focusOn(int index) {
    _controller.animateTo(
      _offsetOf(index),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  /// Once a swipe or a tap has come to rest, the group in focus becomes the
  /// active one. Focusing the "add another" card leaves the active group be.
  bool _onScrollEnd(ScrollEndNotification notification) {
    if (notification.depth != 0 || _aligning) return false;
    final focused = _focused.value;
    if (focused >= widget.groups.length) return false;
    final group = widget.groups[focused];
    if (group.slug != widget.activeSlug) {
      // Already where it should be: the alignment this change of active group
      // would otherwise run has nothing to do.
      _alignedTo = group.slug;
      widget.onFocus?.call(group);
    }
    return false;
  }

  void _showMapNotConfigured(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.mapNotConfigured)),
      );
  }

  /// Draws card [index] by how far it is from the centre: full size in focus,
  /// smaller and fainter as it moves away. A card out of focus takes a tap as
  /// "bring me into focus" rather than passing it to its buttons.
  ///
  /// [card] is laid out at the design size and drawn [scale] times larger.
  ///
  /// The card's own subtree is built once and kept: what changes with focus
  /// sits around it, with the same shape whether or not it is focused. Had the
  /// tap wrapper been added and removed instead, the card under it would be
  /// torn down and rebuilt — photo, hyphenation and all — every time a swipe
  /// moved focus. Its own layer means a frame of swiping only moves and fades
  /// the card's picture rather than painting it again.
  Widget _focusable(int index, double scale, Widget card) {
    return AnimatedBuilder(
      animation: _motion,
      child: RepaintBoundary(
        child: UniformScale(scale: scale, child: card),
      ),
      builder: (context, child) {
        final position = _controller.hasClients
            ? _controller.offset / _itemExtent
            : _focused.value.toDouble();
        final distance = (position - index).abs().clamp(0.0, 1.0);
        final focused = index == _focused.value;
        return Opacity(
          opacity: 1 - (1 - _unfocusedOpacity) * distance,
          child: Transform.scale(
            scale: 1 - (1 - _unfocusedScale) * distance,
            // Shrunk toward the focused card, so the edge facing it stays put
            // and keeps peeking in at the side; shrunk about its middle, that
            // edge pulled back almost out of view.
            alignment: index > position
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: focused ? null : () => _focusOn(index),
              child: AbsorbPointer(absorbing: !focused, child: child),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 360.0;
        // The cards are laid out at the design's own size and drawn larger on
        // a bigger screen, so a tablet shows the same card a phone does, only
        // bigger. Everything below is worked out at the design size first.
        final scale = designScaleOf(context);
        // Sized off a fixed peek rather than a fraction of the viewport: the
        // focused card leaves both neighbours showing — the peek, not a
        // marker, is what says there is more than one — while the card keeps
        // enough width for its three action buttons to stay on one line.
        final designCardWidth =
            (viewportWidth / scale - _gutter * 2 - _peek * 2).clamp(
              200.0,
              340.0,
            );
        final cardWidth = designCardWidth * scale;
        final gap = _gap * scale;
        _itemExtent = cardWidth + gap;
        final sidePadding = (viewportWidth - cardWidth) / 2;
        _alignToActive();

        return ValueListenableBuilder<Set<String>>(
          valueListenable: prayedTodayController,
          builder: (context, prayedSlugs, _) {
            // Which groups are known to have coordinates — null while the UUPG
            // list hasn't been read yet, which canMapPeopleGroup treats as
            // "show the button and let the map screen fetch".
            return ValueListenableBuilder<Set<String>?>(
              valueListenable: peopleGroupSlugsWithLocation,
              builder: (context, locatedSlugs, _) => _withCues(
                sidePadding: sidePadding,
                gap: gap,
                scroller: NotificationListener<ScrollEndNotification>(
                  onNotification: _onScrollEnd,
                  child: SingleChildScrollView(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    physics: _CardSnapPhysics(itemExtent: _itemExtent),
                    padding: EdgeInsets.symmetric(
                      horizontal: sidePadding,
                      vertical: _gutter * scale,
                    ),
                    // A Row (rather than a horizontal ListView) keeps the
                    // carousel's height intrinsic, so a card that grows at a
                    // large font scale is not clipped by a height guessed
                    // here. IntrinsicHeight is what makes `stretch` legal:
                    // the home screen leaves our height unbounded, and
                    // stretching against that forces an infinite height. It
                    // measures the tallest card and gives every card that
                    // height, so the cards line up without one being guessed.
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: gap,
                        children: [
                          for (final (i, group) in widget.groups.indexed)
                            SizedBox(
                              width: cardWidth,
                              child: _focusable(
                                i,
                                scale,
                                PeopleGroupCard(
                                  name: group.name,
                                  imageUrl: group.imageUrl ?? '',
                                  prayedToday: prayedSlugs.contains(group.slug),
                                  onPray: () => widget.onPray(group),
                                  onDetails: () => widget.onDetails(group),
                                  onShare: () => widget.onShare(group),
                                  showMap: true,
                                  // A build with no Mapbox token keeps the
                                  // button and says why tapping it can't
                                  // open the map, rather than the button
                                  // silently vanishing.
                                  onMap: !MapConfig.isConfigured
                                      ? () => _showMapNotConfigured(context)
                                      : canMapPeopleGroup(
                                          group.slug,
                                          locatedSlugs,
                                        )
                                      ? () => widget.onMap(group)
                                      : null,
                                ),
                              ),
                            ),
                          if (widget.groups.length < kMaxPeopleGroups)
                            SizedBox(
                              width: cardWidth,
                              child: _focusable(
                                widget.groups.length,
                                scale,
                                AddPeopleGroupCard(onTap: widget.onAdd),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// [scroller] with what says there are more cards than the one in focus:
  /// a round arrow over the gap on each side that has another card, and a
  /// dot per card under the row — as on a people group's profile.
  Widget _withCues({
    required Widget scroller,
    required double sidePadding,
    required double gap,
  }) {
    final count = _cardCount;
    if (count < 2) return scroller;
    final inset = sidePadding - gap / 2 - DeckArrowButton.size / 2;
    return ValueListenableBuilder<int>(
      valueListenable: _focused,
      child: scroller,
      builder: (context, focused, scroller) {
        Widget arrow({required bool back}) {
          final target = back ? focused - 1 : focused + 1;
          return PositionedDirectional(
            start: back ? inset : null,
            end: back ? null : inset,
            top: 0,
            bottom: 0,
            child: Center(
              child: DeckArrowButton(
                back: back,
                shown: target >= 0 && target < count,
                onTap: () => _focusOn(target),
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(children: [scroller!, arrow(back: true), arrow(back: false)]),
            ProfileDeckDots(count: count, current: focused, onTap: _focusOn),
          ],
        );
      },
    );
  }
}

/// Settles a swipe on exactly one card — the next or previous by the swipe's
/// direction, or the nearest when the finger is lifted without a flick — the
/// way a [PageView] settles on a page, but for cards narrower than the row.
class _CardSnapPhysics extends ScrollPhysics {
  const _CardSnapPhysics({required this.itemExtent, super.parent});

  final double itemExtent;

  @override
  _CardSnapPhysics applyTo(ScrollPhysics? ancestor) =>
      _CardSnapPhysics(itemExtent: itemExtent, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Past either end: let the parent physics bounce or clamp it back.
    if (position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    var card = position.pixels / itemExtent;
    if (velocity < -tolerance.velocity) {
      card -= 0.5;
    } else if (velocity > tolerance.velocity) {
      card += 0.5;
    }
    final target = (card.roundToDouble() * itemExtent).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((target - position.pixels).abs() < tolerance.distance) return null;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}
