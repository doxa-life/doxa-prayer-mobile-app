import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.url,
    this.aspectRatio = 16 / 9,
    this.radius = 16,
    this.fit = BoxFit.cover,
    this.size = 96.0,
  });

  final String? url;
  final double aspectRatio;
  final double radius;
  final BoxFit fit;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null || url!.isEmpty
          ? Container(
              width: size,
              height: size,
              color: AppColors.mutedSurface,
              alignment: Alignment.center,
              child: Icon(
                Icons.image_outlined,
                size: 48,
                color: AppColors.onSurface.withValues(alpha: 0.4),
              ),
            )
          : SizedBox(
              width: size,
              height: size,
              child: Image.network(url!, fit: fit),
            ),
    );
  }
}
