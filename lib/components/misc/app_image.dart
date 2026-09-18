import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../services/image_cache_manager.dart';
import '../../theme/app_colors.dart';
import 'skeleton_box.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.url,
    this.aspectRatio = 16 / 9,
    this.radius = 16,
    this.fit = BoxFit.cover,
    this.size = 96.0,
    this.semanticLabel,
  });

  final String? url;
  final double aspectRatio;
  final double radius;
  final BoxFit fit;
  final double size;

  /// Describes the photo for screen readers. When null the image is treated as
  /// decorative and excluded from the semantics tree.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null || url!.isEmpty
          ? _placeholder()
          : SizedBox(
              width: size,
              height: size,
              child: _semantics(
                CachedNetworkImage(
                  imageUrl: url!,
                  // Held on disk for 30 days, so a photo the user has already
                  // seen paints immediately on later launches instead of
                  // being refetched. See services/image_cache_manager.dart.
                  cacheManager: AppImageCacheManager.instance,
                  // Decode to the size actually drawn, not the source's. 77 of
                  // the people groups are served as 1024x1024 photos, which
                  // cost ~4 MB each in the image cache no matter how small the
                  // box is — enough, several at a time on a scrolling list, to
                  // put a modest iPhone under the memory pressure that makes
                  // iOS reclaim the very directory this cache lives in.
                  //
                  // Width only: `CachedNetworkImage` resizes with the default
                  // exact policy, so passing a height as well would squash the
                  // portrait sources (most are 200x250) instead of letting
                  // `BoxFit.cover` crop them.
                  memCacheWidth: _decodeWidth(context),
                  fit: fit,
                  // The default 500ms fade-in over a 1s placeholder fade-out
                  // makes a photo already on disk look like it is still
                  // loading. Swapping straight to it is what makes the cache
                  // feel like a cache.
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  // On a cache miss the bytes still come off the network,
                  // and without a placeholder the layout would hold an empty
                  // gap until they arrive. A pulsing block fills the exact
                  // final footprint. A cache hit skips this entirely.
                  placeholder: (context, url) =>
                      SkeletonBox(width: size, height: size, radius: radius),
                  errorWidget: (context, url, error) => _placeholder(),
                ),
              ),
            ),
    );
  }

  /// The width to decode at: the box's width in physical pixels. Sources are
  /// never wider than 1024, and [CachedNetworkImage] does not upscale, so a
  /// photo smaller than the box is left at its own resolution.
  int _decodeWidth(BuildContext context) =>
      (size * MediaQuery.devicePixelRatioOf(context)).round();

  /// [CachedNetworkImage] has no semantics parameters of its own, so the
  /// treatment `Image.network` applies is reproduced here: a labelled photo is
  /// announced as an image, an unlabelled one is decorative and kept out of the
  /// semantics tree entirely.
  Widget _semantics(Widget image) {
    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: image);
    return Semantics(image: true, label: label, child: image);
  }

  /// Shown when there is no image to load, and when loading fails — both leave
  /// the same hole in the layout, so they get the same filler.
  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      color: AppColors.mutedSurface,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}
