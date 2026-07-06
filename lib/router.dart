import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'screens/debug_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/news_signup_settings_screen.dart';
import 'screens/notification_permission_settings_screen.dart';
import 'screens/people_group_details_screen.dart';
import 'screens/people_groups_screen.dart';
import 'screens/pray_deep_link_screen.dart';
import 'screens/pray_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wizard_screen.dart';
import 'services/crashlytics_route_observer.dart';
import 'services/pray_override_controller.dart';
import 'services/referral_controller.dart';
import 'services/wizard_completion_controller.dart';

enum AppRoute { home, pray, peopleGroups, reminders }

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

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  // Records root-level screen transitions as Crashlytics breadcrumbs.
  observers: [CrashlyticsRouteObserver()],
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
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
          routes: [
            GoRoute(
              name: AppRoute.pray.name,
              path: '/pray',
              builder: (_, _) => const PrayScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: AppRoute.peopleGroups.name,
              path: '/people-groups',
              builder: (_, _) => const PeopleGroupsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: AppRoute.reminders.name,
              path: '/reminders',
              builder: (_, _) => const RemindersScreen(),
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
      builder: (_, state) =>
          PrayDeepLinkScreen(slug: state.pathParameters['slug']!),
      routes: [
        GoRoute(
          name: 'pray-deep-link-dated',
          path: ':date',
          parentNavigatorKey: _rootNavigatorKey,
          redirect: _prayDeepLinkRedirect,
          builder: (_, state) => PrayDeepLinkScreen(
            slug: state.pathParameters['slug']!,
            date: DateTime.tryParse(state.pathParameters['date'] ?? ''),
          ),
        ),
      ],
    ),
    GoRoute(
      name: 'people-group-details',
      path: '/people-groups/:slug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra;
        final fromWizard = extra is Map && extra['fromWizard'] == true;
        return PeopleGroupDetailsScreen(
          slug: state.pathParameters['slug'],
          fromWizard: fromWizard,
        );
      },
    ),
    GoRoute(
      name: 'settings',
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => const SettingsScreen(),
      routes: [
        GoRoute(
          name: 'settings-news-signup',
          path: 'news-signup',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, _) => const NewsSignupSettingsScreen(),
        ),
        GoRoute(
          name: 'settings-notifications',
          path: 'notifications',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, _) => const NotificationPermissionSettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      name: 'gallery',
      path: '/gallery',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => const GalleryScreen(),
    ),
    GoRoute(
      name: 'debug',
      path: '/debug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, _) => const DebugScreen(),
    ),
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
