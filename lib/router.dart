import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'components/nav/root_pop_scope.dart';
import 'components/nav/sheet_page.dart';
import 'components/prayer_content/prayer_calendar_sheet.dart';
import 'components/nav/swipeable_branch_container.dart';
import 'screens/debug_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/help_screen.dart';
import 'screens/home_screen.dart';
import 'screens/news_signup_settings_screen.dart';
import 'screens/notification_permission_settings_screen.dart';
import 'screens/people_group_details_screen.dart';
import 'screens/people_group_map_screen.dart';
import 'screens/people_group_prayer_screen.dart';
import 'screens/people_groups_screen.dart';
import 'screens/pray_deep_link_screen.dart';
import 'screens/pray_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/saved_prayers_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wizard_screen.dart';
import 'services/crashlytics_route_observer.dart';
import 'services/haptic_route_observer.dart';
import 'services/pray_override_controller.dart';
import 'services/referral_controller.dart';
import 'services/wizard_completion_controller.dart';

/// The bottom-nav tabs, in branch order.
enum AppRoute { home, pray, peopleGroups }

/// Matches the `/<slug>/prayer` and `/<slug>/prayer/<date>` deep links that
/// mirror the campaigns site's prayer pages.
final RegExp _prayDeepLinkPath = RegExp(r'^/[^/]+/prayer(/[^/]+)?$');

/// Shared redirect for the prayer deep-link routes. An onboarded user is sent
/// to the Pray tab with the group stashed as a one-visit override; a
/// pre-onboarding user falls through to the standalone [PrayDeepLinkScreen].
String? _prayDeepLinkRedirect(BuildContext context, GoRouterState state) {
  final slug = state.pathParameters['slug'] ?? '';
  if (slug.isEmpty) return '/home';
  if (!wizardCompletedController.value) return null;
  final date = DateTime.tryParse(state.pathParameters['date'] ?? '');
  setPrayOverride(slug, date);
  return '/pray';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Whether [uri] is the Pray tab — on it, or choosing a day for it from the
/// calendar sheet over it. The tab's prayer session and a deep link's override
/// both last while the calendar is open: picking a day is still praying here.
bool isPrayTabLocation(Uri uri) =>
    uri.path == '/pray' ||
    (uri.path == '/calendar' && uri.queryParameters['from'] == 'pray');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  // Records root-level screen transitions as Crashlytics breadcrumbs, and
  // gives each page change a light haptic tick.
  observers: [CrashlyticsRouteObserver(), HapticRouteObserver()],
  refreshListenable: wizardCompletedController,
  redirect: (context, state) {
    // "Pray on the app" deep links (/app/<slug>) are resolved by their own route
    // redirect below — let them through so the "force wizard" guard doesn't eat them.
    if (state.uri.path.startsWith('/app/')) return null;
    final atWizard = state.matchedLocation == '/wizard';
    final atPeopleGroupDetails = state.matchedLocation.startsWith(
      '/people-groups/',
    );
    // Let `/<slug>/prayer` deep links reach their own route so a pre-onboarding
    // visitor can see the prayer content before being routed into the wizard.
    final atPrayDeepLink = _prayDeepLinkPath.hasMatch(state.uri.path);
    if (!wizardCompletedController.value &&
        !atWizard &&
        !atPeopleGroupDetails &&
        !atPrayDeepLink) {
      return '/wizard';
    }
    if (wizardCompletedController.value && atWizard) return '/home';
    return null;
  },
  routes: [
    StatefulShellRoute(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      // Tabs sit side by side so they can be swiped between, rather than in
      // go_router's default IndexedStack.
      navigatorContainerBuilder: (context, navigationShell, children) =>
          SwipeableBranchContainer(
            navigationShell: navigationShell,
            children: children,
          ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: AppRoute.home.name,
              path: '/home',
              builder: (_, _) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          // Built at launch rather than on first visit, so the tab has
          // loaded by the time it is opened — see SwipeableBranchContainer.
          preload: true,
          routes: [
            GoRoute(
              name: AppRoute.pray.name,
              path: '/pray',
              builder: (_, _) => const PrayScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          // Built at launch rather than on first visit, so the tab has
          // loaded by the time it is opened — see SwipeableBranchContainer.
          preload: true,
          routes: [
            GoRoute(
              name: AppRoute.peopleGroups.name,
              path: '/people-groups',
              builder: (_, _) => const PeopleGroupsScreen(),
            ),
          ],
        ),
      ],
    ),
    // "Pray on the app" deep link (App Link / Universal Link / custom scheme).
    // Branches to onboarding (stashing the slug for auto-select) or straight to the
    // people group profile, depending on whether the wizard has been completed.
    GoRoute(
      name: 'app-deep-link',
      path: '/app/:slug',
      redirect: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        if (slug.isEmpty) return '/home';
        if (wizardCompletedController.value) {
          return '/people-groups/$slug';
        }
        // Stash for the wizard to auto-select, then drop into onboarding.
        setReferredPeopleGroup(slug);
        return '/wizard';
      },
    ),
    // Pray deep link mirroring the campaigns site's `/<slug>/prayer[/<date>]`
    // pages. Onboarded users are redirected onto the Pray tab with a one-visit
    // override; pre-onboarding users get the standalone screen + wizard CTA.
    GoRoute(
      name: 'pray-deep-link',
      path: '/:slug/prayer',
      parentNavigatorKey: _rootNavigatorKey,
      redirect: _prayDeepLinkRedirect,
      builder: (_, state) => RootPopScope(
        child: PrayDeepLinkScreen(slug: state.pathParameters['slug']!),
      ),
      routes: [
        GoRoute(
          name: 'pray-deep-link-dated',
          path: ':date',
          parentNavigatorKey: _rootNavigatorKey,
          redirect: _prayDeepLinkRedirect,
          builder: (_, state) => RootPopScope(
            child: PrayDeepLinkScreen(
              slug: state.pathParameters['slug']!,
              date: DateTime.tryParse(state.pathParameters['date'] ?? ''),
            ),
          ),
        ),
      ],
    ),
    // Help, opened from the app bar's help icon: a sheet over wherever it was
    // opened from, as a people group's profile is.
    GoRoute(
      name: 'help',
      path: '/help',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (_, state) => SheetPage<Object?>(
        key: state.pageKey,
        name: state.name,
        child: const RootPopScope(child: HelpScreen()),
      ),
    ),
    // The calendar for picking a day's prayer, from the Pray tab or a
    // standalone prayer screen. A sheet like Help; pops with the picked day.
    GoRoute(
      name: 'prayer-calendar',
      path: '/calendar',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (_, state) {
        final extra = state.extra;
        final today = DateTime.now();
        return SheetPage<DateTime>(
          key: state.pageKey,
          name: state.name,
          child: RootPopScope(
            child: PrayerCalendarScreen(
              // Opened cold, with nothing to say which days, it offers the
              // last year up to today.
              args: extra is PrayerCalendarArgs
                  ? extra
                  : PrayerCalendarArgs(
                      selected: today,
                      firstDay: today.subtract(const Duration(days: 365)),
                      lastDay: today,
                    ),
            ),
          ),
        );
      },
    ),
    GoRoute(
      name: 'people-group-details',
      path: '/people-groups/:slug',
      parentNavigatorKey: _rootNavigatorKey,
      // A sheet over wherever it was opened from, dismissed by dragging it
      // down or by its close button.
      pageBuilder: (_, state) {
        final extra = state.extra;
        final fromWizard = extra is Map && extra['fromWizard'] == true;
        return SheetPage<Object?>(
          key: state.pageKey,
          name: state.name,
          child: RootPopScope(
            child: PeopleGroupDetailsScreen(
              slug: state.pathParameters['slug'],
              fromWizard: fromWizard,
            ),
          ),
        );
      },
    ),
    // The map opened from a home people-group card. A sibling of the details
    // route rather than a child of it: the user arrives from the card, so
    // nesting would insert a details page they never visited into the back
    // stack.
    GoRoute(
      name: 'people-group-map',
      path: '/people-groups/:slug/map',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) =>
          PeopleGroupMapScreen(slug: state.pathParameters['slug']!),
    ),
    // Every people group on one map, opened from the home screen's map button
    // rather than for any one group. Pushed above the tabs like the per-group
    // map, so back returns to home.
    GoRoute(
      name: 'people-groups-overview-map',
      path: '/map',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => const PeopleGroupMapScreen(),
    ),
    // Prayer content pushed on top of the map, so praying for a group found on
    // the map doesn't discard the map.
    GoRoute(
      name: 'people-group-prayer',
      path: '/people-groups/:slug/pray',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra;
        final name = extra is Map ? extra['name'] as String? : null;
        final date = extra is Map ? extra['date'] as DateTime? : null;
        return PeopleGroupPrayerScreen(
          slug: state.pathParameters['slug']!,
          name: name ?? '',
          initialDate: date,
        );
      },
    ),
    // The prayers the user has starred or downloaded, opened from Settings and
    // from the Pray screen's calendar.
    GoRoute(
      name: 'saved-prayers',
      path: '/saved-prayers',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => const RootPopScope(child: SavedPrayersScreen()),
    ),
    GoRoute(
      name: 'settings',
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => const RootPopScope(child: SettingsScreen()),
      routes: [
        GoRoute(
          name: 'settings-news-signup',
          path: 'news-signup',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, _) =>
              const RootPopScope(child: NewsSignupSettingsScreen()),
        ),
        GoRoute(
          name: 'settings-notifications',
          path: 'notifications',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, _) =>
              const RootPopScope(child: NotificationPermissionSettingsScreen()),
        ),
      ],
    ),
    // Reminders used to be a tab; it now opens from Settings, and from the
    // home screen's reminder card and call to action. Pushed above the tabs
    // like Settings, so back returns to wherever it was opened from.
    GoRoute(
      name: 'reminders',
      path: '/reminders',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => const RootPopScope(child: RemindersScreen()),
    ),
    GoRoute(
      name: 'feedback',
      path: '/feedback',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => const RootPopScope(child: FeedbackScreen()),
    ),
    // Dev-only screens. The Debug button that opens /debug is already hidden in
    // release (see TopNavBar), but the routes themselves were still reachable by
    // any `doxa:///debug` or `doxa:///gallery` link. kReleaseMode is a
    // compile-time constant, so release builds drop these screens entirely.
    if (!kReleaseMode) ...[
      GoRoute(
        name: 'gallery',
        path: '/gallery',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const RootPopScope(child: GalleryScreen()),
      ),
      GoRoute(
        name: 'debug',
        path: '/debug',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const RootPopScope(child: DebugScreen()),
      ),
    ],
    GoRoute(
      name: 'wizard',
      path: '/wizard',
      parentNavigatorKey: _rootNavigatorKey,
      // Stable page key so re-resolving '/wizard' (e.g. an /app/<slug> deep link
      // arriving while the user is already mid-wizard) is a Navigator no-op
      // instead of a remount — the WizardController survives and its referral
      // listener fires, preserving onboarding progress.
      pageBuilder: (_, _) =>
          const MaterialPage(key: ValueKey('wizard'), child: WizardScreen()),
    ),
  ],
);
