import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';
import '../misc/triangle_icon.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavBar({
    super.key,
    this.title,
    this.onSettings,
    this.onBack,
    this.onGallery,
    this.onDebug,
  });

  final String? title;
  final VoidCallback? onSettings;
  final VoidCallback? onBack;
  final VoidCallback? onGallery;
  final VoidCallback? onDebug;

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
      title: title != null
          ? Text(
              title!,
              style: AppTypography.h2.copyWith(color: AppColors.onPrimary),
            )
          : Image.asset(
              'assets/images/doxa-logo.png',
              height: AppTypography.lg,
              fit: BoxFit.contain,
            ),
      actions: [
        // Gallery ("Kitchen Sink") and Debug are dev-only tools — hidden in
        // release builds. kDebugMode is a compile-time constant, so the
        // tree-shaker drops these buttons entirely from release builds.
        if (kDebugMode)
          IconButton(
            icon: const Icon(
              Icons.widgets_outlined,
              color: AppColors.onPrimary,
            ),
            tooltip: 'Kitchen Sink',
            onPressed: onGallery,
          ),
        if (kDebugMode && onDebug != null)
          IconButton(
            icon: const Icon(
              Icons.bug_report_outlined,
              color: AppColors.onPrimary,
            ),
            tooltip: 'Debug',
            onPressed: onDebug,
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
