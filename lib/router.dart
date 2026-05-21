import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'screens/debug_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/news_signup_settings_screen.dart';
import 'screens/people_group_details_screen.dart';
import 'screens/people_groups_screen.dart';
import 'screens/pray_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wizard_screen.dart';
import 'services/wizard_completion_controller.dart';

enum AppRoute { home, pray, peopleGroups, reminders }

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  refreshListenable: wizardCompletedController,
  redirect: (context, state) {
    final atWizard = state.matchedLocation == '/wizard';
    final atPeopleGroupDetails = state.matchedLocation.startsWith(
      '/people-groups/',
    );
    if (!wizardCompletedController.value &&
        !atWizard &&
        !atPeopleGroupDetails) {
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
    GoRoute(
      name: 'people-group-details',
      path: '/people-groups/:slug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) =>
          PeopleGroupDetailsScreen(slug: state.pathParameters['slug']),
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
      builder: (_, _) => const WizardScreen(),
    ),
  ],
);
