import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../misc/app_icon.dart';
import '../misc/splash_transition.dart';
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
    VoidCallback? onHelp,
    VoidCallback? onBack,
    VoidCallback? onDebug,
    Widget? trailing,
    bool settingsBadge = false,
  }) => TopNavBar._(
    key: key,
    title: title,
    onSettings: onSettings,
    onHelp: onHelp,
    settingsBadge: settingsBadge,
    onBack: onBack,
    onDebug: onDebug,
    trailing: trailing,
    preferredSize: NavBarTitle.preferredSizeFor(
      context,
      title: title,
      hasLeading: _hasLeading(onBack: onBack, onDebug: onDebug),
      actionCount: _actionCount(
        onSettings: onSettings,
        onHelp: onHelp,
        trailing: trailing,
      ),
    ),
  );

  const TopNavBar._({
    super.key,
    required this.title,
    required this.onSettings,
    required this.onHelp,
    required this.settingsBadge,
    required this.onBack,
    required this.onDebug,
    required this.trailing,
    required this.preferredSize,
  });

  final String? title;
  final VoidCallback? onSettings;

  /// Opens Help, from an icon just before the settings cog.
  final VoidCallback? onHelp;

  /// Dots the settings cog when something inside it needs attention —
  /// reminders that can't fire as set. The Reminders tab carried this dot
  /// before Reminders moved into Settings.
  final bool settingsBadge;
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
  static int _actionCount({
    VoidCallback? onSettings,
    VoidCallback? onHelp,
    Widget? trailing,
  }) =>
      (trailing != null ? 1 : 0) +
      (onHelp != null ? 1 : 0) +
      (onSettings != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      // Must match preferredSize, or the Scaffold and the AppBar disagree on
      // how tall the bar is and the title clips.
      toolbarHeight: preferredSize.height,
      // The bar draws nothing different when content scrolls under it (the
      // theme's scrolledUnderElevation is 0), but by default it still listens
      // to every scroll below it and rebuilds — title and all — each time the
      // content leaves or reaches its top, over and over in an iOS bounce.
      notificationPredicate: (_) => false,
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
                  onHelp: onHelp,
                  trailing: trailing,
                ),
              ),
            )
          // Where the launch splash shrinks into.
          : SplashTarget(
              child: Image.asset(
                'assets/images/doxa-logo.png',
                height: AppTypography.lg,
                fit: BoxFit.contain,
                semanticLabel: l10n.appName,
              ),
            ),
      actions: [
        ?trailing,
        if (onHelp != null)
          IconButton(
            icon: const AppIcon(AppIconName.help, color: AppColors.onPrimary),
            tooltip: l10n.help,
            onPressed: onHelp,
          ),
        if (onSettings != null)
          IconButton(
            icon: Badge(
              isLabelVisible: settingsBadge,
              backgroundColor: AppColors.warning,
              child: const AppIcon(
                AppIconName.gear,
                color: AppColors.onPrimary,
              ),
            ),
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
