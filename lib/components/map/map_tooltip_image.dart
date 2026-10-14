import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../services/image_cache_manager.dart';
import '../../services/image_failure_reporter.dart';
import '../../theme/app_colors.dart';

/// The people group's photo in a map tooltip.
///
/// Unlike `AppImage`, which swaps straight to a cached photo so lists feel
/// instant, this one is the centrepiece of a popup that is already animating
/// in, so it gets an animation of its own: a light sweeping across the frame
/// while the bytes are on their way, then the photo settling into place —
/// fading in from slightly enlarged and blurred — once it has decoded.
///
/// With the platform's "reduce motion" setting on, the sweep holds still and
/// the photo simply appears.
class MapTooltipImage extends StatelessWidget {
  const MapTooltipImage({
    super.key,
    required this.url,
    this.size = 64,
    this.radius = 12,
    this.semanticLabel,
  });

  final String? url;
  final double size;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final Widget child;
    if (url == null || url.isEmpty) {
      child = _Placeholder(size: size);
    } else {
      child = CachedNetworkImage(
        // Keyed by URL so a tooltip that switches straight from one group to
        // another replays the reveal for the new photo instead of keeping the
        // old one's finished animation.
        key: ValueKey(url),
        imageUrl: url,
        cacheManager: AppImageCacheManager.instance,
        // Decode at the drawn width — see AppImage for why this matters.
        memCacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        // The reveal below replaces the package's own cross-fade.
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) => _LoadingSweep(size: size),
        imageBuilder: (context, provider) => _Reveal(
          child: Image(
            image: provider,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        errorWidget: (context, url, error) {
          reportImageFailure(url, error);
          return _Placeholder(size: size);
        },
      );
    }
    final label = semanticLabel;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: label == null
            ? ExcludeSemantics(child: child)
            : Semantics(image: true, label: label, child: child),
      ),
    );
  }
}

/// A soft band of light travelling diagonally across a muted block — reads as
/// "on its way" without the stop-start of a spinner in a space this small.
class _LoadingSweep extends StatefulWidget {
  const _LoadingSweep({required this.size});

  final double size;

  @override
  State<_LoadingSweep> createState() => _LoadingSweepState();
}

class _LoadingSweepState extends State<_LoadingSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOutSine.transform(_controller.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                AppColors.mutedSurface,
                AppColors.white,
                AppColors.mutedSurface,
              ],
              stops: const [0.3, 0.5, 0.7],
              // Slides the band from fully off one corner to fully off the
              // other, so each pass starts and ends on a plain block.
              transform: _SlideGradient(-1.2 + 2.4 * t),
            ),
          ),
          child: child,
        );
      },
      // A faint people-group glyph so the block reads as "a photo goes here"
      // rather than as a broken box.
      child: SizedBox.square(
        dimension: widget.size,
        child: Icon(
          Icons.groups_rounded,
          size: widget.size * 0.42,
          color: AppColors.outline,
        ),
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.fraction);

  /// How far along the diagonal the band has travelled, in box widths.
  final double fraction;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(
        bounds.width * fraction,
        bounds.height * fraction,
        0,
      );
}

/// Plays once when the decoded photo first arrives: it fades in while
/// shrinking from 112% and sharpening from a blur, so it settles into the
/// frame rather than popping into it.
class _Reveal extends StatefulWidget {
  const _Reveal({required this.child});

  final Widget child;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        final t = _progress.value;
        // Skipping the filter once settled keeps the finished photo off the
        // more expensive blur path entirely.
        final blur = (1 - t) * 6;
        Widget image = Transform.scale(scale: 1.12 - 0.12 * t, child: child);
        if (blur > 0.05) {
          image = ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: image,
          );
        }
        return ColoredBox(
          // The sweep's base tone, so the fade starts from what was just on
          // screen instead of flashing through white.
          color: AppColors.mutedSurface,
          child: Opacity(opacity: t, child: image),
        );
      },
      child: widget.child,
    );
  }
}

/// No photo, or one that failed to load: the same muted block the loading
/// sweep rests on, with a still glyph.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.mutedSurface,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: size * 0.42,
        color: AppColors.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}
