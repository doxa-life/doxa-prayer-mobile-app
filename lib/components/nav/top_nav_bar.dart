import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      leading: onBack != null
          ? IconButton(
              icon: TriangleIcon(
                color: AppColors.onPrimary,
                direction: Directionality.of(context) == TextDirection.rtl
                    ? TriangleDirection.right
                    : TriangleDirection.left,
                size: 12,
              ),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: onBack,
            )
          : null,
      centerTitle: true,
      title: title != null
          ? Semantics(
              header: true,
              child: Text(
                title!,
                style: AppTypography.h2.copyWith(color: AppColors.onPrimary),
              ),
            )
          : Image.asset(
              'assets/images/doxa-logo.png',
              height: AppTypography.lg,
              fit: BoxFit.contain,
              semanticLabel: l10n.appName,
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
            tooltip: l10n.settings,
            onPressed: onSettings,
          ),
      ],
      backgroundColor: AppColors.primary,
    );
  }
}
