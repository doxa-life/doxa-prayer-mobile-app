import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../nav/sheet_page.dart';

/// Each card takes this share of the deck's width, leaving the rest for the
/// cards either side of it to show at the edges.
const double _kCardShare = 0.86;

/// The space between one card and the next.
const double _kGutter = AppSpacing.md;

/// How far the cards either side of the one in focus are shrunk and dimmed,
/// so they read as set back behind it.
const double _kBackScale = 0.9;
const double _kBackOpacity = 0.7;

/// The space between the sheet's header and the cards.
const double _kTop = AppSpacing.xl;

/// The space kept clear at the foot of every card for the dots laid over it.
const double _kDotsRoom = AppSpacing.xxl;

const Duration _kSlideDuration = Duration(milliseconds: 280);

/// The space under the cards: clear of the home indicator, where there is one.
double _bottomOf(BuildContext context) =>
    math.max(AppSpacing.xl, MediaQuery.viewPaddingOf(context).bottom);

/// A people group's profile as a deck of cards, swiped through sideways one at
/// a time, as the home screen's group cards are. The card in focus is centred,
/// with the cards either side of it showing at the edges, smaller and dimmed,
/// set back behind it; they come forward as they are swiped into the middle.
/// Dots under it show how many there are and which is in view, and each card
/// change ticks a selection haptic.
///
/// Shown in a sheet, a drag down anywhere on the deck pulls the sheet down
/// after it, to dismiss it — on a card that scrolls, once it is back at its
/// top.
///
/// The loading skeleton is the same deck with placeholder cards and
/// [interactive] off, so the two take exactly the same space.
class ProfileDeck extends StatefulWidget {
  const ProfileDeck({
    super.key,
    required this.cards,
    this.darkCards = const {},
    this.interactive = true,
  });

  final List<Widget> cards;

  /// Indexes of the cards drawn dark, under which the dots are drawn light.
  final Set<int> darkCards;

  final bool interactive;

  @override
  State<ProfileDeck> createState() => _ProfileDeckState();
}

class _ProfileDeckState extends State<ProfileDeck> {
  final PageController _controller = PageController(
    viewportFraction: _kCardShare,
  );

  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() => _current = index);
  }

  void _goTo(int index) => _controller.animateToPage(
    index,
    duration: _kSlideDuration,
    curve: Curves.easeOutCubic,
  );

  /// The button on the deck's [back] (start) or forward (end) side, over the
  /// gap between the card in focus and the one peeking in, shown while there
  /// is a card that way.
  Widget _arrow(
    BuildContext context, {
    required bool back,
    required double bottom,
    required double width,
  }) {
    final target = back ? _current - 1 : _current + 1;
    final shown = target >= 0 && target < widget.cards.length;
    final inset = width * (1 - _kCardShare) / 2 - DeckArrowButton.size / 2;
    return PositionedDirectional(
      start: back ? inset : null,
      end: back ? null : inset,
      top: _kTop,
      bottom: bottom,
      child: Center(
        child: DeckArrowButton(
          back: back,
          shown: shown,
          onTap: () => _goTo(target),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheet = widget.interactive ? SheetScope.maybeOf(context) : null;
    final bottom = _bottomOf(context);
    final pages = PageView.builder(
      controller: _controller,
      physics: widget.interactive ? null : const NeverScrollableScrollPhysics(),
      onPageChanged: _onPageChanged,
      itemCount: widget.cards.length,
      itemBuilder: (context, index) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // How far this card is from the middle, in cards: 0 in focus, 1
          // beside it.
          final ready =
              _controller.hasClients &&
              _controller.position.hasContentDimensions &&
              _controller.position.hasPixels;
          final page = ready
              ? _controller.page ?? _current.toDouble()
              : _current.toDouble();
          final away = (page - index).abs().clamp(0.0, 1.0);
          return Opacity(
            opacity: 1 - (1 - _kBackOpacity) * away,
            child: Transform.scale(
              scale: 1 - (1 - _kBackScale) * away,
              // Shrunk toward the card in focus, so the edge facing it stays
              // where it is and keeps showing at the side of the deck.
              // Shrunk about its middle, a card's near edge pulls back almost
              // out of view and there's nothing to say it is there.
              alignment: index > page
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              child: child,
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            _kGutter / 2,
            _kTop,
            _kGutter / 2,
            bottom,
          ),
          child: widget.cards[index],
        ),
      ),
    );
    final deck = LayoutBuilder(
      builder: (context, box) => Stack(
        children: [
          pages,
          if (widget.interactive) ...[
            _arrow(context, back: true, bottom: bottom, width: box.maxWidth),
            _arrow(context, back: false, bottom: bottom, width: box.maxWidth),
          ],
          // Laid over the foot of the card in focus, inside its padding, clear
          // of its content.
          Positioned(
            left: 0,
            right: 0,
            bottom: bottom + AppSpacing.xxs,
            child: Center(
              child: ProfileDeckDots(
                count: widget.cards.length,
                current: _current,
                onDark: widget.darkCards.contains(_current),
                onTap: widget.interactive ? _goTo : null,
              ),
            ),
          ),
        ],
      ),
    );
    if (sheet == null) return deck;
    // A drag down on a card that has nothing to scroll is the sheet's: no
    // scrollable claims it, so it reaches this. A card that does scroll takes
    // it first, and pulls the sheet itself once back at its top.
    return NotificationListener<ScrollEndNotification>(
      onNotification: (n) {
        sheet.end(n.dragDetails?.primaryVelocity ?? 0);
        return false;
      },
      child: GestureDetector(
        onVerticalDragUpdate: (d) => sheet.update(d.primaryDelta ?? 0),
        onVerticalDragEnd: (d) => sheet.end(d.primaryVelocity ?? 0),
        onVerticalDragCancel: () => sheet.end(0),
        child: deck,
      ),
    );
  }
}

/// A round button at the side of a row of cards swiped through one at a time
/// — the profile deck, the home carousel, the Pray tab's switcher — saying
/// there is another card that way, and going to it. Fades out while there is
/// none: on the first card, there is nothing [back].
class DeckArrowButton extends StatelessWidget {
  const DeckArrowButton({
    super.key,
    required this.back,
    required this.shown,
    required this.onTap,
  });

  /// Toward the start (the previous card) rather than the end.
  final bool back;
  final bool shown;
  final VoidCallback onTap;

  static const double size = 32;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final icon = back == rtl ? Icons.chevron_right : Icons.chevron_left;
    return IgnorePointer(
      ignoring: !shown,
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.4),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: shown ? onTap : null,
            child: SizedBox.square(
              dimension: size,
              child: Icon(icon, size: 22, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Which card of the deck is in view, as a row of dots — the current one drawn
/// long. Tapping a dot goes to its card. Hidden from screen readers, which
/// step through the cards themselves.
class ProfileDeckDots extends StatelessWidget {
  const ProfileDeckDots({
    super.key,
    required this.count,
    required this.current,
    this.onTap,
    this.onDark = false,
  });

  final int count;
  final int current;
  final ValueChanged<int>? onTap;

  /// Whether the card under the dots is dark, so the others are drawn light.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap == null ? null : () => onTap!(i),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxs),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: i == current ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == current
                        ? AppColors.secondary
                        : onDark
                        ? AppColors.white.withValues(alpha: 0.45)
                        : AppColors.onSurface.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One card of the profile deck: the app's elevated card, filling the space
/// the deck gives it.
///
/// Its [header] (at the top) and the rule under it, and its [footer], are
/// fixed to the card. Between them, [child] scrolls when there is more of it
/// than fits, so the heading stays put while the rest moves under it; when it
/// fits, it sits in the space left at [bodyAlignment]. A card with no header
/// is centred as a whole. With [fill], [child] is instead given exactly the
/// space between them, to lay out to the card's size itself.
class ProfileDeckCard extends StatelessWidget {
  const ProfileDeckCard({
    super.key,
    this.header,
    required this.child,
    this.footer,
    this.fill = false,
    this.padding = AppSpacing.xxxl,
    this.color = AppColors.surface,
    this.ruleColor,
    this.headerSpacing = AppSpacing.lg,
    this.bodyAlignment = Alignment.topCenter,
  });

  final Widget? header;
  final Widget child;
  final Widget? footer;
  final bool fill;
  final double padding;
  final Color color;
  final Color? ruleColor;

  /// The space above and below the rule under the [header].
  final double headerSpacing;

  /// Where [child] sits in the space under the [header], when it fits.
  final AlignmentGeometry bodyAlignment;

  /// The space between the content and the [footer].
  static const double footerSpacing = AppSpacing.xxl;

  @override
  Widget build(BuildContext context) {
    final full = fill || header != null;
    final column = Column(
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[
          header!,
          SizedBox(height: headerSpacing),
          ProfileHeadingRule(color: ruleColor),
          SizedBox(height: headerSpacing),
        ],
        if (fill)
          Expanded(child: child)
        else if (header != null)
          Expanded(
            child: Align(
              alignment: bodyAlignment,
              child: ProfileCardScroll(child: child),
            ),
          )
        else
          Flexible(child: ProfileCardScroll(child: child)),
        if (footer != null) ...[const SizedBox(height: footerSpacing), footer!],
      ],
    );
    return Material(
      color: color,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          padding,
          padding,
          padding,
          math.max(padding, _kDotsRoom),
        ),
        child: full ? column : Center(child: column),
      ),
    );
  }
}

/// Scrolling for content within a card: clamped, so it never drifts loose of
/// the card's edges, and pulling the sheet down when dragged down from its top.
class ProfileCardScroll extends StatelessWidget {
  const ProfileCardScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: _CardScrollPhysics(sheet: SheetScope.maybeOf(context)),
      child: child,
    );
  }
}

/// Clamped scrolling that only takes a drag when there is something to scroll.
/// Otherwise it would claim the drag even on content that fits, and a drag
/// down there would neither scroll nor reach the sheet.
class _CardScrollPhysics extends ClampingScrollPhysics with SheetPullPhysics {
  const _CardScrollPhysics({this.sheet, super.parent});

  @override
  final SheetDrag? sheet;

  @override
  _CardScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _CardScrollPhysics(sheet: sheet, parent: buildParent(ancestor));

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) =>
      position.pixels != 0 ||
      position.minScrollExtent != position.maxScrollExtent;
}

/// The rule between a card's heading and the rest of it.
class ProfileHeadingRule extends StatelessWidget {
  const ProfileHeadingRule({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: color ?? AppColors.onSurface.withValues(alpha: 0.15),
    );
  }
}
