import 'dart:math' as math;

import 'package:flutter/gestures.dart' show VelocityTracker;
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'root_pop_scope.dart';

/// A page that slides up from the bottom of the screen as a sheet over the
/// one it was opened from, which stays in view, dimmed, above the sheet's top.
///
/// Dismissed by tapping that dimmed strip, by the sheet's own close button
/// (any pop), or by dragging the sheet down: the content takes part through
/// [SheetScope] — see [SheetDrag].
class SheetPage<T> extends Page<T> {
  const SheetPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => _SheetRoute<T>(page: this);
}

/// Moves the sheet a page is shown in, for content that is dragged to dismiss
/// it. Got from [SheetScope.maybeOf]; null when the page isn't in a sheet.
abstract interface class SheetDrag {
  /// How far, in logical pixels, the sheet has been dragged down from open.
  double get offset;

  /// Moves the sheet down by [delta] (up, when negative), following a drag.
  void update(double delta);

  /// Ends a drag, at [velocity] logical pixels a second (positive is down):
  /// the sheet is dismissed if pulled far or fast enough, otherwise it
  /// springs back open. Does nothing if no drag is under way.
  void end(double velocity);
}

/// Gives the content of a [SheetPage] its [SheetDrag].
class SheetScope extends InheritedWidget {
  const SheetScope({super.key, required this.drag, required super.child});

  final SheetDrag drag;

  static SheetDrag? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SheetScope>()?.drag;

  @override
  bool updateShouldNotify(SheetScope oldWidget) => drag != oldWidget.drag;
}

/// Scroll physics for a scrollable inside a sheet: dragged down past its start,
/// it pulls the sheet down instead, and dragged back up it raises the sheet
/// before it scrolls again — all in the one drag, with the finger.
///
/// The drag's end is reported by the scrollable's [ScrollEndNotification];
/// whoever listens for it passes it on to [SheetDrag.end].
mixin SheetPullPhysics on ScrollPhysics {
  SheetDrag? get sheet;

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final sheet = this.sheet;
    if (sheet != null) {
      // A positive offset is the finger moving down, toward the start.
      if (offset > 0 && position.pixels <= position.minScrollExtent) {
        sheet.update(offset);
        return 0;
      }
      if (offset < 0 && sheet.offset > 0) {
        final taken = math.min(-offset, sheet.offset);
        sheet.update(-taken);
        offset += taken;
        if (offset == 0) return 0;
      }
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }
}

class _SheetRoute<T> extends PageRoute<T> implements SheetDrag {
  _SheetRoute({required SheetPage<T> page}) : super(settings: page);

  SheetPage<T> get _page => settings as SheetPage<T>;

  /// Pulled down past this share of its height, a released sheet closes.
  static const double _dismissShare = 0.3;

  /// Flung down faster than this, in logical pixels a second, it closes
  /// however little it was pulled.
  static const double _dismissVelocity = 700;

  static const Curve _curve = Curves.easeOutCubic;

  /// The sheet's height, as last laid out.
  double _height = 1;

  /// Whether the sheet is following a drag, or settling after one. Its
  /// position is then the animation's value as it is, with no curve, so it
  /// stays under the finger and doesn't jump when let go.
  bool _tracking = false;

  bool _dragging = false;

  /// Fingers down on the sheet, and how the latest one is moving.
  final Set<int> _pointers = <int>{};
  VelocityTracker? _velocity;

  /// The last finger has left the sheet. Whatever was dragging it reports the
  /// drag's end as that same event is handled; if nothing did — a drag can
  /// end without the scrollable it went through saying so, or say so only
  /// once a fling it set off has run out — the sheet settles here, so it is
  /// never left part-way open.
  void _onLastPointerUp() {
    final velocity = _velocity?.getVelocity().pixelsPerSecond.dy ?? 0;
    _velocity = null;
    // After this event has reached the gesture recognizers, which see it last.
    Future.microtask(() {
      if (_dragging) end(velocity);
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers.add(event.pointer);
    _velocity = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
  }

  void _onPointerMove(PointerMoveEvent event) =>
      _velocity?.addPosition(event.timeStamp, event.position);

  void _onPointerEnd(PointerEvent event) {
    if (!_pointers.remove(event.pointer)) return;
    if (_pointers.isEmpty) _onLastPointerUp();
  }

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.45);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 380);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 280);

  @override
  double get offset => (1 - (controller?.value ?? 1)) * _height;

  @override
  void update(double delta) {
    final controller = this.controller;
    if (controller == null || !isCurrent) return;
    if (!_dragging) {
      _dragging = true;
      _tracking = true;
      navigator?.didStartUserGesture();
    }
    // Never quite to 0: a dismissed animation would finish the route.
    controller.value = (controller.value - delta / _height).clamp(0.001, 1.0);
  }

  @override
  void end(double velocity) {
    if (!_dragging) return;
    _dragging = false;
    navigator?.didStopUserGesture();
    final controller = this.controller!;
    final dismiss =
        velocity > _dismissVelocity ||
        (velocity > -_dismissVelocity && controller.value < 1 - _dismissShare);
    if (dismiss) {
      // Pops from where the sheet is, or goes home when there is nothing
      // under it (a deep link opened it).
      final context = subtreeContext;
      if (context != null) safeBack(context);
    } else {
      controller
          .animateTo(
            1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          )
          .whenCompleteOrCancel(() {
            // Interrupted by a new drag, it is that drag's to settle.
            if (_dragging) return;
            _tracking = false;
            if (isCurrent && controller.value < 1) controller.value = 1;
          });
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SheetScope(drag: this, child: _page.child);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final top = MediaQuery.paddingOf(context).top + AppSpacing.sm;
    final sheet = Padding(
      padding: EdgeInsets.only(top: top),
      child: Material(
        color: AppColors.surface,
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        // The sheet starts below the status bar, so its content has no top
        // inset to keep clear of.
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: child,
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        _height = math.max(1, constraints.maxHeight - top);
        return Stack(
          children: [
            // Opened by a deep link, the sheet has nothing under it to show.
            if (isFirst)
              const Positioned.fill(
                child: ColoredBox(color: AppColors.mutedSurface),
              ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final t = _tracking
                      ? animation.value
                      : _curve.transform(animation.value);
                  return Transform.translate(
                    offset: Offset(0, (1 - t) * _height),
                    child: child,
                  );
                },
                child: Listener(
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: _onPointerEnd,
                  onPointerCancel: _onPointerEnd,
                  child: sheet,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
