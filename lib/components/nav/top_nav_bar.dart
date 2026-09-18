import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';
import '../misc/triangle_icon.dart';
import 'nav_bar_title.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  /// Needs a [context] so the bar can be as tall as its wrapped title — see
  /// [NavBarTitle.preferredSizeFor].
  factory TopNavBar({
    Key? key,
    required BuildContext context,
    String? title,
    VoidCallback? onSettings,
    VoidCallback? onBack,
    VoidCallback? onDebug,
    Widget? trailing,
  }) => TopNavBar._(
    key: key,
    title: title,
    onSettings: onSettings,
    onBack: onBack,
    onDebug: onDebug,
    trailing: trailing,
    preferredSize: NavBarTitle.preferredSizeFor(
      context,
      title: title,
      hasLeading: _hasLeading(onBack: onBack, onDebug: onDebug),
      actionCount: _actionCount(onSettings: onSettings, trailing: trailing),
    ),
  );

  const TopNavBar._({
    super.key,
    required this.title,
    required this.onSettings,
    required this.onBack,
    required this.onDebug,
    required this.trailing,
    required this.preferredSize,
  });

  final String? title;
  final VoidCallback? onSettings;
  final VoidCallback? onBack;
  final VoidCallback? onDebug;

  /// An extra action ahead of the settings cog — the Pray tab's people-group
  /// avatar. Null everywhere else, so no other screen pays for the slot.
  final Widget? trailing;

  @override
  final Size preferredSize;

  /// Kept in step with the [leading] built below. Debug sits in the leading
  /// slot (the corner opposite settings), so it counts the same as a back
  /// button for the title's sizing.
  static bool _hasLeading({VoidCallback? onBack, VoidCallback? onDebug}) =>
      onBack != null || (kDebugMode && onDebug != null);

  /// Kept in step with the [actions] built below.
  static int _actionCount({VoidCallback? onSettings, Widget? trailing}) =>
      (trailing != null ? 1 : 0) + (onSettings != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      // Must match preferredSize, or the Scaffold and the AppBar disagree on
      // how tall the bar is and the title clips.
      toolbarHeight: preferredSize.height,
      leading: _buildLeading(context),
      centerTitle: true,
      title: title != null
          ? NavBarTitle(
              title!,
              color: AppColors.onPrimary,
              width: NavBarTitle.widthFor(
                context,
                hasLeading: _hasLeading(onBack: onBack, onDebug: onDebug),
                actionCount: _actionCount(
                  onSettings: onSettings,
                  trailing: trailing,
                ),
              ),
            )
          : Image.asset(
              'assets/images/doxa-logo.png',
              height: AppTypography.lg,
              fit: BoxFit.contain,
              semanticLabel: l10n.appName,
            ),
      actions: [
        ?trailing,
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

  /// A back button when there is one to show, otherwise the dev-only Debug
  /// button — parked in the corner opposite settings so the actions side is
  /// left to the screen's own controls. kDebugMode is a compile-time constant,
  /// so the tree-shaker drops it entirely from release builds.
  Widget? _buildLeading(BuildContext context) {
    if (onBack != null) {
      return IconButton(
        icon: TriangleIcon(
          color: AppColors.onPrimary,
          direction: Directionality.of(context) == TextDirection.rtl
              ? TriangleDirection.right
              : TriangleDirection.left,
          size: 12,
        ),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onBack,
      );
    }
    if (kDebugMode && onDebug != null) {
      return IconButton(
        icon: const Icon(Icons.bug_report_outlined, color: AppColors.onPrimary),
        tooltip: 'Debug',
        onPressed: onDebug,
      );
    }
    return null;
  }
}
