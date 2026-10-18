import 'package:flutter/material.dart';

/// Moves from one child to the next with a "fade through": the outgoing child
/// fades out first, then the incoming one fades in with a short slide in the
/// direction the user moved — forward from the end, back from the start,
/// mirrored in a right-to-left language.
///
/// The two never show at once. Cross-fading two pages of prayer text laid
/// slightly apart drew every line twice, a few pixels off, and stepping
/// quickly through days stacked several such copies — the text seemed to
/// shudder. Only the most recent outgoing child is kept: one replaced before
/// it had finished leaving is dropped, so quick steps never pile up.
///
/// Each child has a layer of its own, so a frame of the transition only moves
/// and fades a finished picture rather than painting it again.
///
/// [child] must carry a key that changes whenever it should switch.
class DirectionalSwitcher extends StatelessWidget {
  const DirectionalSwitcher({
    super.key,
    required this.child,
    this.direction = 0,
    this.duration = const Duration(milliseconds: 300),
    this.fill = true,
  });

  final Widget child;

  /// +1 forward, -1 back, 0 for a plain fade.
  final int direction;

  final Duration duration;

  /// Whether the children fill the space given (a page of their own), or
  /// size to their content, top-aligned — for use inside a scroll view, where
  /// there is no height to fill.
  final bool fill;

  /// How far the incoming child slides, as a share of its width: enough to
  /// give the switch a direction, little enough to read as a fade.
  static const double _slide = 0.04;

  /// The share of [duration] the outgoing child takes to fade out; the
  /// incoming one fades in over the rest.
  static const double _outShare = 0.35;

  static const Interval _fadeIn = Interval(
    _outShare,
    1,
    curve: Curves.easeOutCubic,
  );

  /// Applied to the outgoing child's animation as it runs back from 1 to 0,
  /// so it is gone by the time that animation is [_outShare] of the way
  /// through.
  static const Interval _fadeOut = Interval(
    1 - _outShare,
    1,
    curve: Curves.easeIn,
  );

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final dx = _slide * direction.sign * (rtl ? -1 : 1);
    final currentKey = child.key;
    return AnimatedSwitcher(
      duration: duration,
      layoutBuilder: (current, previous) => Stack(
        fit: fill ? StackFit.expand : StackFit.loose,
        alignment: Alignment.topCenter,
        children: [if (previous.isNotEmpty) previous.last, ?current],
      ),
      transitionBuilder: (child, animation) {
        final incoming = child.key == currentKey;
        if (!incoming) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: _fadeOut),
            child: RepaintBoundary(child: child),
          );
        }
        final shown = CurvedAnimation(parent: animation, curve: _fadeIn);
        return FadeTransition(
          opacity: shown,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(dx, 0),
              end: Offset.zero,
            ).animate(shown),
            child: RepaintBoundary(child: child),
          ),
        );
      },
      child: child,
    );
  }
}
