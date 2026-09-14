import 'package:flutter/material.dart';

import '../../services/prayer_history_service.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_spacing.dart';
import 'add_people_group_card.dart';
import 'people_group_card.dart';

/// The people groups the user prays for, side by side. Cards stay in the order
/// they were added — a card the user is reaching for never slides away — and
/// the neighbouring cards are left peeking so the row reads as scrollable.
///
/// The active group (the one the Pray tab will show) is centred whenever there
/// is room, and comes to rest fully visible against whichever end it is at.
/// That position is the only cue saying which group is active, so it follows
/// the active group whenever it changes — including a switch made from the Pray
/// tab while this screen sat in the background.
class PeopleGroupCarousel extends StatefulWidget {
  const PeopleGroupCarousel({
    super.key,
    required this.groups,
    required this.activeSlug,
    required this.onPray,
    required this.onDetails,
    required this.onShare,
    required this.onShowQr,
    required this.onAdd,
  });

  final List<SubscribedPeopleGroup> groups;
  final String? activeSlug;
  final ValueChanged<SubscribedPeopleGroup> onPray;
  final ValueChanged<SubscribedPeopleGroup> onDetails;
  final ValueChanged<SubscribedPeopleGroup> onShare;
  final ValueChanged<SubscribedPeopleGroup> onShowQr;
  final VoidCallback onAdd;

  @override
  State<PeopleGroupCarousel> createState() => _PeopleGroupCarouselState();
}

class _PeopleGroupCarouselState extends State<PeopleGroupCarousel> {
  final ScrollController _controller = ScrollController();

  /// The cards sit inside this padding so their shadows have somewhere to fall.
  /// A scroll view clips at its own bounds, so without it the first and last
  /// cards lose their shadow to the left and right edges and every card loses
  /// it along the bottom.
  static const double _gutter = AppSpacing.md;

  static const double _gap = AppSpacing.lg;

  /// How much of each neighbouring card shows beside a centred one.
  static const double _peek = AppSpacing.lg;

  /// The slug the scroll position was last aligned to, so an alignment runs
  /// once per change of active group rather than on every rebuild.
  String? _alignedTo;

  /// False until the first alignment has happened, which is the one that must
  /// not animate — the carousel should already be in place when it is first
  /// looked at.
  bool _hasAligned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Where the scroll view must sit for card [index] to be centred. Clamping by
  /// the caller does the rest: at either end the target falls outside the
  /// scrollable range and the card comes to rest fully visible instead.
  ///
  /// The "add another" card is part of the row, so it counts as the last card —
  /// which is what lets the final *group* be centred while there is still room
  /// under the cap.
  double _centredOffset(int index, double cardWidth, double viewportWidth) =>
      _gutter + index * (cardWidth + _gap) - (viewportWidth - cardWidth) / 2;

  void _alignToActive(double cardWidth, double viewportWidth) {
    if (_alignedTo == widget.activeSlug) return;
    _alignedTo = widget.activeSlug;
    final index = widget.groups.indexWhere((g) => g.slug == widget.activeSlug);
    if (index < 0) return;
    final animate = _hasAligned;
    _hasAligned = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final target = _centredOffset(
        index,
        cardWidth,
        viewportWidth,
      ).clamp(0.0, _controller.position.maxScrollExtent);
      // Animating only matters when the user can see it happen; a switch made
      // from the Pray tab lands here before this screen is looked at again.
      if (animate && (_controller.offset - target).abs() > 1) {
        _controller.animateTo(
          target,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        _controller.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 360.0;
        // Sized off a fixed peek rather than a fraction of the viewport: a
        // centred card leaves both neighbours showing — the peek, not a
        // marker, is what says there is more than one — while the card keeps
        // enough width for its three action buttons to stay on one line.
        final cardWidth = (viewportWidth - _gutter * 2 - _peek * 2).clamp(
          200.0,
          340.0,
        );
        _alignToActive(cardWidth, viewportWidth);

        return ValueListenableBuilder<Set<String>>(
          valueListenable: prayedTodayController,
          builder: (context, prayedSlugs, _) {
            return SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: _gutter,
                vertical: _gutter,
              ),
              // A Row (rather than a horizontal ListView) keeps the carousel's
              // height intrinsic, so a card that grows at a large font scale is
              // not clipped by a height guessed here. IntrinsicHeight is what
              // makes `stretch` legal: the home screen leaves our height
              // unbounded, and stretching against that forces an infinite
              // height. It measures the tallest card and gives every card that
              // height, so the cards line up without one being guessed.
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: _gap,
                  children: [
                    for (final group in widget.groups)
                      SizedBox(
                        width: cardWidth,
                        child: PeopleGroupCard(
                          name: group.name,
                          imageUrl: group.imageUrl ?? '',
                          prayedToday: prayedSlugs.contains(group.slug),
                          onPray: () => widget.onPray(group),
                          onDetails: () => widget.onDetails(group),
                          onShare: () => widget.onShare(group),
                          onShowQr: () => widget.onShowQr(group),
                        ),
                      ),
                    if (widget.groups.length < kMaxPeopleGroups)
                      SizedBox(
                        width: cardWidth,
                        child: AddPeopleGroupCard(onTap: widget.onAdd),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
