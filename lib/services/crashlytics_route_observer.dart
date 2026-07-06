import 'package:flutter/widgets.dart';

import 'crash_reporting_service.dart';

/// A [NavigatorObserver] that records screen transitions as Crashlytics
/// breadcrumbs, so a crash report shows the trail of screens leading up to it.
///
/// Attached to the root navigator via [GoRouter.observers] in router.dart.
class CrashlyticsRouteObserver extends NavigatorObserver {
  void _crumb(String action, Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) {
      leaveCrashBreadcrumb('nav $action: $name');
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _crumb('push', route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _crumb('pop', route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _crumb('replace', newRoute);
}
