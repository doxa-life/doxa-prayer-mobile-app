import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';
import '../misc/triangle_icon.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavBar({
    super.key,
    this.title = 'DOXA',
    this.onSettings,
    this.onBack,
    this.onGallery,
  });

  final String title;
  final VoidCallback? onSettings;
  final VoidCallback? onBack;
  final VoidCallback? onGallery;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: onBack != null
          ? IconButton(
              icon: const TriangleIcon(
                color: AppColors.onPrimary,
                direction: TriangleDirection.left,
                size: 12,
              ),
              onPressed: onBack,
            )
          : null,
      centerTitle: true,
      title: Text(
        title,
        style: AppTypography.h2.copyWith(color: AppColors.onPrimary),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.widgets_outlined, color: AppColors.onPrimary),
          tooltip: 'Kitchen Sink',
          onPressed: onGallery,
        ),
        if (onSettings != null)
          IconButton(
            icon: const AppIcon(AppIconName.gear, color: AppColors.onPrimary),
            tooltip: 'Settings',
            onPressed: onSettings,
          ),
      ],
      backgroundColor: AppColors.primary,
    );
  }
}
