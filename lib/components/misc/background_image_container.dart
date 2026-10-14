import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';

const _kBackgroundColor = Color(0xFFF3F3F1);
const _kPatternColor = AppColors.onPrimary;

/// Strength of the background pattern. 0 = invisible, 1 = full [_kPatternColor].
const _kPatternOpacity = 0.25;
const _kTabletBreakpoint = 600.0;

/// The pattern tinted the way it is drawn.
final ColorFilter _patternFilter = ColorFilter.mode(
  _kPatternColor.withValues(alpha: _kPatternOpacity),
  BlendMode.srcIn,
);

class BackgroundImageContainer extends StatelessWidget {
  const BackgroundImageContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.sizeOf(context).shortestSide >= _kTabletBreakpoint;
    final backgroundAsset = isTablet
        ? 'assets/images/tablet-background.svg'
        : 'assets/images/mobile-background.svg';
    return Container(
      color: _kBackgroundColor,
      child: Stack(
        children: [
          Positioned.fill(child: _PatternBackground(asset: backgroundAsset)),
          child,
        ],
      ),
    );
  }
}

/// The background pattern, drawn as one pre-rendered image.
///
/// The SVG has some eighty paths and is tinted through a colour filter, which
/// means an offscreen layer. Drawn as an SVG it was re-rendered on every frame
/// anything on screen moved — on iOS's renderer nothing is cached between
/// frames — and every pushed page carries its own copy, so a page transition
/// drew it twice a frame. Rendered once into an image at the screen's size,
/// each frame costs a single texture copy instead.
///
/// The SVG itself is shown until the image is ready (one frame or so on first
/// use, then never again: the image is shared by every page of that size), so
/// the background never flashes blank.
class _PatternBackground extends StatelessWidget {
  const _PatternBackground({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (!size.isFinite || size.isEmpty) return const SizedBox.shrink();
        final key = _RasterKey(asset, size, math.min(dpr, 3));
        final ready = _rasters[key];
        if (ready != null) return _image(ready);
        return FutureBuilder<ui.Image>(
          future: _rasterize(key),
          builder: (context, snapshot) {
            final image = snapshot.data;
            if (image != null) return _image(image);
            // Still rendering, or failed: the plain SVG, exactly as before.
            return ExcludeSemantics(
              child: SvgPicture.asset(
                asset,
                fit: BoxFit.cover,
                colorFilter: _patternFilter,
              ),
            );
          },
        );
      },
    );
  }

  Widget _image(ui.Image image) => ExcludeSemantics(
    child: RawImage(image: image, fit: BoxFit.fill),
  );
}

@immutable
class _RasterKey {
  const _RasterKey(this.asset, this.size, this.pixelRatio);

  final String asset;
  final Size size;
  final double pixelRatio;

  @override
  bool operator ==(Object other) =>
      other is _RasterKey &&
      other.asset == asset &&
      other.size == size &&
      other.pixelRatio == pixelRatio;

  @override
  int get hashCode => Object.hash(asset, size, pixelRatio);
}

/// Finished images by size. Only a couple are ever made — the screen, and its
/// rotation — but a cap keeps an unusual run of sizes (split screen being
/// dragged on a tablet) from piling up full-screen images.
final Map<_RasterKey, ui.Image> _rasters = <_RasterKey, ui.Image>{};
final Map<_RasterKey, Future<ui.Image>> _pending =
    <_RasterKey, Future<ui.Image>>{};
const int _maxRasters = 3;

Future<ui.Image> _rasterize(_RasterKey key) {
  return _pending[key] ??= () async {
    try {
      final info = await vg.loadPicture(SvgAssetLoader(key.asset), null);
      final width = (key.size.width * key.pixelRatio).ceil();
      final height = (key.size.height * key.pixelRatio).ceil();
      final source = info.size;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      // BoxFit.cover, centred — what the SvgPicture did.
      final scale = math.max(width / source.width, height / source.height);
      canvas
        ..translate(
          (width - source.width * scale) / 2,
          (height - source.height * scale) / 2,
        )
        ..scale(scale)
        ..saveLayer(
          Offset.zero & source,
          Paint()..colorFilter = _patternFilter,
        )
        ..drawPicture(info.picture)
        ..restore();
      final picture = recorder.endRecording();
      final image = await picture.toImage(width, height);
      picture.dispose();
      info.picture.dispose();

      if (_rasters.length >= _maxRasters) {
        // Dropped, not disposed: a page may still be drawing it.
        _rasters.remove(_rasters.keys.first);
      }
      _rasters[key] = image;
      return image;
    } finally {
      _pending.remove(key);
    }
  }();
}
