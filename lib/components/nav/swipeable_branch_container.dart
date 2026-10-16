import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// The bottom-nav tabs laid side by side, paged like a [PageView], so a
/// horizontal swipe slides to the neighbouring tab and a tap on the nav bar
/// slides over to the one tapped.
///
/// Unlike a [PageView], every tab is built from the start, not when it first
/// scrolls into view: each tab loads what it shows (and keeps it fresh) while
/// the user is still on another, so it is ready the moment they swipe to it.
/// With the branches preloaded (see router.dart), this is what makes every tab
/// open already filled in. Stands in for go_router's default `IndexedStack` container — see
/// the `navigatorContainerBuilder` in router.dart.
///
/// The shell's current index stays the single source of truth: a swipe calls
/// [StatefulNavigationShell.goBranch], and any other branch change (nav bar
/// tap, back to Home, a reminder tap) arrives here as a new index and is
/// animated to. Every tab change ends in a selection haptic.
class SwipeableBranchContainer extends StatefulWidget {
  const SwipeableBranchContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;

  /// One navigator per branch, in branch order.
  final List<Widget> children;

  @override
  State<SwipeableBranchContainer> createState() =>
      _SwipeableBranchContainerState();
}

class _SwipeableBranchContainerState extends State<SwipeableBranchContainer> {
  static const Duration _slideDuration = Duration(milliseconds: 240);

  late final PageController _controller = PageController(
    initialPage: widget.navigationShell.currentIndex,
  );

  /// Set while a nav-bar tap (or other programmatic change) is sliding the
  /// pages, so the pages it passes on the way don't register as swipes.
  int? _animatingTo;

  /// The page last reported to [_onPageChanged], as [PageView] tracks it.
  late int _lastReportedPage = widget.navigationShell.currentIndex;

  @override
  void didUpdateWidget(SwipeableBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.navigationShell.currentIndex;
    if (index == oldWidget.navigationShell.currentIndex) return;
    HapticFeedback.selectionClick();
    // A swipe has already moved the pages; only other changes need sliding.
    if (_controller.hasClients && _controller.page?.round() != index) {
      _slideTo(index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _slideTo(int index) async {
    if (_animatingTo == index) return;
    setState(() => _animatingTo = index);
    // A jump across several tabs starts from the neighbouring page, so it
    // reads as one slide rather than a flick through every tab in between.
    final from = _controller.page?.round() ?? index;
    if ((from - index).abs() > 1) {
      _controller.jumpToPage(index > from ? index - 1 : index + 1);
    }
    await _controller.animateToPage(
      index,
      duration: _slideDuration,
      curve: Curves.easeOutCubic,
    );
    if (mounted && _animatingTo == index) setState(() => _animatingTo = null);
  }

  void _onPageChanged(int index) {
    if (_animatingTo != null) return;
    final shell = widget.navigationShell;
    if (index != shell.currentIndex) shell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.navigationShell.currentIndex;
    final axisDirection = textDirectionToAxisDirection(
      Directionality.of(context),
    );
    // What a PageView is, less its one-page cache: a paged Scrollable over a
    // viewport whose cache reaches every tab, so all of them are laid out —
    // and kept — however far off screen. Page changes are reported the way
    // PageView reports them.
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0 &&
            notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          if (metrics is PageMetrics && metrics.page != null) {
            final page = metrics.page!.round();
            if (page != _lastReportedPage) {
              _lastReportedPage = page;
              _onPageChanged(page);
            }
          }
        }
        return false;
      },
      child: Scrollable(
        axisDirection: axisDirection,
        controller: _controller,
        physics: const _TabSwipePhysics(),
        scrollBehavior: ScrollConfiguration.of(
          context,
        ).copyWith(scrollbars: false),
        viewportBuilder: (context, position) => Viewport(
          axisDirection: axisDirection,
          offset: position,
          scrollCacheExtent: ScrollCacheExtent.viewport(
            widget.children.length.toDouble(),
          ),
          clipBehavior: Clip.hardEdge,
          slivers: [
            SliverFillViewport(
              delegate: SliverChildListDelegate([
                for (final (i, child) in widget.children.indexed)
                  // Tabs out of view stay alive but stop animating, as they
                  // did in go_router's own container: without this a loading
                  // skeleton on a tab nobody is looking at pulses forever,
                  // costing frames on every other tab.
                  TickerMode(
                    enabled: i == current || i == _animatingTo,
                    child: _KeepAlive(child: child),
                  ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page physics for the tabs: a swipe has to be meant to change tab, and the
/// tabs settle quickly once it is.
///
/// A drag that ends with the tab less than half across only counts as a
/// change of tab if it ends in a deliberate flick — fast, and long enough not
/// to be the sideways wobble of a vertical scroll. Anything less springs
/// back. The spring is stiffer than the default, so the tab lands sooner.
class _TabSwipePhysics extends PageScrollPhysics {
  const _TabSwipePhysics({super.parent});

  @override
  _TabSwipePhysics applyTo(ScrollPhysics? ancestor) =>
      _TabSwipePhysics(parent: buildParent(ancestor));

  @override
  double get minFlingVelocity => 700;

  @override
  double get minFlingDistance => 48;

  /// How far a drag must travel before the tabs start to follow it.
  @override
  double get dragStartDistanceMotionThreshold => 12;

  @override
  SpringDescription get spring =>
      SpringDescription.withDampingRatio(mass: 0.5, stiffness: 260, ratio: 1);
}

/// Keeps an off-screen tab's navigator — and its scroll position, form input
/// and pushed pages — alive, as the `IndexedStack` it replaces did.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
