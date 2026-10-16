import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The splash image: the launch screen's own (ios/Runner/Assets.xcassets/
/// LaunchImage), so the hand-over from the native splash can't be seen.
const String _splashAsset = 'assets/images/splash_circle.png';

/// The title bar's logo, as `TopNavBar` draws it.
const String _barLogoAsset = 'assets/images/doxa-logo.png';

/// Whether the splash is still covering the app, so the title bar's logo
/// stays hidden until the splash's own copy of it has landed in its place.
final ValueNotifier<bool> _splashCovering = ValueNotifier<bool>(false);

/// The title bars' logos, for the splash to fly into. Usually one: the app
/// shell's.
final List<_SplashTargetState> _targets = <_SplashTargetState>[];

/// Picks up where the native launch screen leaves off: the same green and the
/// same logo in its white circle, in the same place, which then shrinks and
/// moves up into the title bar, turning into the DOXA logo there as the green
/// fades away to show the app.
///
/// When the first screen has no title bar logo (the welcome wizard), the logo
/// shrinks away where it is instead. With the system's reduce-motion setting
/// on, the splash only fades.
///
/// Holds back the app's first frame until the splash image is decoded, so the
/// launch screen gives way to an identical picture, never to a blank one.
class SplashTransition extends StatefulWidget {
  const SplashTransition({super.key, required this.child});

  final Widget child;

  @override
  State<SplashTransition> createState() => _SplashTransitionState();
}

class _SplashTransitionState extends State<SplashTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  bool _done = false;
  bool _firstFrameAllowed = false;
  bool _started = false;

  /// Where the title bar's logo is, in this widget's coordinates, once known.
  Rect? _target;

  @override
  void initState() {
    super.initState();
    _splashCovering.value = true;
    WidgetsBinding.instance.deferFirstFrame();
    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      _splashCovering.value = false;
      setState(() => _done = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Never held for long: a slow decode costs a moment of plain green, not
    // a stuck launch screen.
    unawaited(
      Future.any([
        precacheImage(const AssetImage(_splashAsset), context),
        Future<void>.delayed(const Duration(milliseconds: 600)),
      ]).whenComplete(_allowFirstFrame),
    );
  }

  void _allowFirstFrame() {
    if (_firstFrameAllowed) return;
    _firstFrameAllowed = true;
    WidgetsBinding.instance.allowFirstFrame();
    // A beat on the identical picture first, so the hand-over reads as one
    // thing, and so the screen under it has laid out its title bar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() => _target = _findTarget());
        if (MediaQuery.disableAnimationsOf(context)) {
          _controller.duration = const Duration(milliseconds: 250);
        }
        _controller.forward();
      });
    });
  }

  Rect? _findTarget() {
    final self = context.findRenderObject();
    if (self is! RenderBox || !self.hasSize) return null;
    final screen = Offset.zero & self.size;
    for (final target in _targets.reversed) {
      final box = target.context.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final rect = MatrixUtils.transformRect(
        box.getTransformTo(self),
        Offset.zero & box.size,
      );
      if (screen.overlaps(rect) && !rect.isEmpty) return rect;
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _splashCovering.value = false;
    // Never leave the app without a first frame.
    _allowFirstFrame();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) => AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => _frame(context, constraints.biggest),
            ),
          ),
        ),
      ],
    );
  }

  /// The splash at [_controller]'s value.
  Widget _frame(BuildContext context, Size screen) {
    final t = _controller.value;
    final reduced = MediaQuery.disableAnimationsOf(context);
    double phase(double begin, double end, [Curve curve = Curves.linear]) =>
        curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));

    // The launch screen centres the image at its own size in points.
    final startSize = defaultTargetPlatform == TargetPlatform.iOS
        ? 288.0
        : 225.0;
    final start = Rect.fromCenter(
      center: screen.center(Offset.zero),
      width: startSize,
      height: startSize,
    );
    final target = _target;
    final travel = reduced ? 0.0 : phase(0, 1, Curves.easeInOutCubic);

    // Where the circle goes: into the title bar's logo, or, with no bar to go
    // to, down to nothing where it is.
    final Rect end;
    if (target != null) {
      final side = target.height * 2.6;
      end = Rect.fromCenter(center: target.center, width: side, height: side);
    } else {
      end = Rect.fromCenter(center: start.center, width: 0, height: 0);
    }
    final circle = Rect.lerp(start, end, travel)!;
    final circleOpacity = reduced
        ? 1.0
        : 1 - phase(target == null ? 0.4 : 0.55, 0.9);
    final backdrop = 1 - phase(reduced ? 0 : 0.35, 1, Curves.easeOut);

    return IgnorePointer(
      ignoring: t > 0.6,
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.primary.withValues(alpha: backdrop),
            ),
          ),
          if (circle.width > 0 && circleOpacity > 0)
            Positioned.fromRect(
              rect: circle,
              child: Opacity(
                opacity: circleOpacity,
                child: const Image(
                  image: AssetImage(_splashAsset),
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),
            ),
          // The bar's own logo, fading in as the circle lands where it is.
          if (target != null && !reduced)
            Positioned.fromRect(
              rect: target,
              child: Opacity(
                opacity: phase(0.55, 0.9),
                child: Transform.scale(
                  scale: lerpDouble(0.8, 1, phase(0.5, 1, Curves.easeOut)),
                  child: Image.asset(_barLogoAsset, fit: BoxFit.contain),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Marks the title bar's logo as where the splash lands, and keeps it hidden
/// while the splash's own copy is on its way there.
class SplashTarget extends StatefulWidget {
  const SplashTarget({super.key, required this.child});

  final Widget child;

  @override
  State<SplashTarget> createState() => _SplashTargetState();
}

class _SplashTargetState extends State<SplashTarget> {
  @override
  void initState() {
    super.initState();
    _targets.add(this);
  }

  @override
  void dispose() {
    _targets.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _splashCovering,
      // Kept in the semantics tree while hidden, so the bar is announced the
      // same with or without the splash over it.
      builder: (context, covering, child) => Opacity(
        opacity: covering ? 0 : 1,
        alwaysIncludeSemantics: true,
        child: child,
      ),
      child: widget.child,
    );
  }
}
