import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A [NavigatorObserver] that gives a light haptic tick whenever a page opens
/// or closes — including one swiped away with the back gesture.
///
/// Only full pages count: dialogs, sheets and menus are routes too, but they
/// have their own feedback. The app's first page is skipped, since nothing was
/// navigated to get there. Switching tabs is not a route change; its haptic
/// lives in `SwipeableBranchContainer`.
///
/// Attached to the root navigator via [GoRouter.observers] in router.dart.
class HapticRouteObserver extends NavigatorObserver {
  void _tick(Route<dynamic>? route) {
    if (route is PageRoute) HapticFeedback.selectionClick();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _tick(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _tick(route);
}
