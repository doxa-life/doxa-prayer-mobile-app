import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../misc/triangle_icon.dart';
import 'nav_bar_title.dart';

class DetailsNavBar extends StatelessWidget implements PreferredSizeWidget {
  /// Needs a [context] so the bar can be as tall as its wrapped title — see
  /// [NavBarTitle.preferredSizeFor].
  factory DetailsNavBar({
    Key? key,
    required BuildContext context,
    String title = 'DOXA',
    VoidCallback? onBack,
  }) => DetailsNavBar._(
    key: key,
    title: title,
    onBack: onBack,
    preferredSize: NavBarTitle.preferredSizeFor(
      context,
      title: title,
      hasLeading: onBack != null,
    ),
  );

  const DetailsNavBar._({
    super.key,
    required this.title,
    required this.onBack,
    required this.preferredSize,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Must match preferredSize, or the Scaffold and the AppBar disagree on
      // how tall the bar is and the title clips.
      toolbarHeight: preferredSize.height,
      // The bar draws nothing different when content scrolls under it (the
      // theme's scrolledUnderElevation is 0), but by default it still listens
      // to every scroll below it and rebuilds — title and all — each time the
      // content leaves or reaches its top, over and over in an iOS bounce.
      notificationPredicate: (_) => false,
      leading: onBack != null
          ? IconButton(
              icon: TriangleIcon(
                color: AppColors.onSurface,
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
      title: NavBarTitle(
        title,
        color: AppColors.onSurface,
        width: NavBarTitle.widthFor(context, hasLeading: onBack != null),
      ),
      backgroundColor: AppColors.surface,
    );
  }
}
