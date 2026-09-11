import 'package:flutter/material.dart';

import '../../services/prayer_history_service.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_spacing.dart';
import 'add_people_group_card.dart';
import 'people_group_card.dart';

/// The people groups the user prays for, side by side. Cards stay in the order
/// they were added — a card the user is reaching for never slides away — and
/// the next card is deliberately left peeking so the row reads as scrollable.
///
/// Opens scrolled to the active group (the one the Pray tab will show), which
/// is the only cue that says which one that is.
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
  // Set once the first layout has told us how wide a card ended up, so the
  // jump to the active card can only happen when it can land accurately.
  bool _scrolledToActive = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToActive(double cardWidth) {
    if (_scrolledToActive) return;
    _scrolledToActive = true;
    final index = widget.groups.indexWhere((g) => g.slug == widget.activeSlug);
    if (index <= 0) return;
    final offset = index * (cardWidth + AppSpacing.lg);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      _controller.jumpTo(offset.clamp(0, _controller.position.maxScrollExtent));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Leave a sliver of the next card visible: that peek, not a marker, is
        // what tells someone there is more than one.
        final cardWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth * 0.86).clamp(200.0, 340.0)
            : 300.0;
        _scrollToActive(cardWidth);

        return ValueListenableBuilder<Set<String>>(
          valueListenable: prayedTodayController,
          builder: (context, prayedSlugs, _) {
            return SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
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
                  spacing: AppSpacing.lg,
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
