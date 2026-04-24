import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.url,
    this.aspectRatio = 16 / 9,
    this.radius = 16,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final double aspectRatio;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: url == null || url!.isEmpty
            ? Container(
                color: AppColors.mutedSurface,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: AppColors.onSurface.withValues(alpha: 0.4),
                ),
              )
            : Image.network(url!, fit: fit),
      ),
    );
  }
}
