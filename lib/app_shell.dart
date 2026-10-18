import 'dart:developer' as developer;

import 'package:doxa_prayer_mobile_app/components/misc/background_image_container.dart';
import 'package:doxa_prayer_mobile_app/components/nav/top_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'components/misc/app_icon.dart';
import 'components/misc/hyphenated_text.dart';
import 'components/nav/bottom_nav_bar.dart';
import 'components/nav/sheet_page.dart';
import 'router.dart';
import 'services/analytics_service.dart';
import 'services/reminders_notifications.dart';
import 'services/subscribed_people_groups_controller.dart';
import 'services/update_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    reminderTapPayload.addListener(_onReminderTap);
    // Handle a payload that was already set (cold-start from notification tap).
    developer.log(
      'AppShell.initState: pendingPayload=${reminderTapPayload.value}',
      name: 'REMINDER_TAP',
    );
    if (reminderTapPayload.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onReminderTap());
    }
    refreshNotificationsBlocked();
    refreshExactAlarmsBlocked();
    // Opening the app means the user has seen any waiting reminder — drop the
    // iOS app-icon badge a delivered reminder left behind (no-op elsewhere).
    clearNotificationBadge();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    reminderTapPayload.removeListener(_onReminderTap);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check the version gate when returning to the foreground — at most
      // once an hour; a cold start always checks.
      checkForAppUpdate(minGap: const Duration(hours: 1));
      // Count the foreground resume as an app-open (cold start is tracked in main()).
      trackAppOpen();
      // Re-check notification permission — the user may have just toggled it in
      // OS settings.
      refreshNotificationsBlocked();
      // Likewise re-check exact-alarm permission — the user may have granted it
      // via the system "Alarms & reminders" screen while away.
      refreshExactAlarmsBlocked();
      // Clear the iOS app-icon badge now the reminder has been seen.
      clearNotificationBadge();
    }
  }

  Future<void> _onReminderTap() async {
    final payload = reminderTapPayload.value;
    developer.log(
      'AppShell._onReminderTap: payload=$payload, mounted=$mounted',
      name: 'REMINDER_TAP',
    );
    if (payload == null) return;
    reminderTapPayload.value = null;
    if (!mounted) return;
    // The payload is the slug the reminder was set for, so the Pray tab opens
    // on the group the user was just reminded about. Reminders scheduled by an
    // older build carry the flat 'pray' payload and simply open the tab.
    if (peopleGroupsController.value.contains(payload)) {
      await setActivePeopleGroup(payload);
      if (!mounted) return;
    }
    final prayIndex = AppRoute.values.indexOf(AppRoute.pray);
    developer.log(
      'AppShell._onReminderTap: switching to Pray branch (index=$prayIndex)',
      name: 'REMINDER_TAP',
    );
    widget.navigationShell.goBranch(prayIndex, initialLocation: true);
  }

  void _openSettings(BuildContext context) => context.push('/settings');

  void _openHelp(BuildContext context) => pushSheet(context, '/help');

  void _openDebug(BuildContext context) => context.push('/debug');

  void _onTabTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _handleBack() {
    final shell = widget.navigationShell;
    // From any non-Home tab, switch to Home (deterministic — no reliance on
    // navigation history, so it works on the very first back press too).
    if (shell.currentIndex != AppRoute.home.index) {
      shell.goBranch(AppRoute.home.index);
      return;
    }
    // Already on Home: double-tap within 2s to exit.
    final now = DateTime.now();
    if (_lastBackPress != null &&
        now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPress = now;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: HyphenatedText(
          AppLocalizations.of(context)!.pressBackAgainToExit,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: BackgroundImageContainer(
        // Rebuilt when anything stops reminders from firing as expected —
        // notifications turned off, or exact alarms not permitted (reminders
        // would arrive late) — so the settings cog, where Reminders now lives,
        // can say so.
        child: ListenableBuilder(
          listenable: Listenable.merge([
            notificationsBlocked,
            exactAlarmsBlocked,
          ]),
          builder: (context, _) => Scaffold(
            backgroundColor: Colors.transparent,
            appBar: TopNavBar(
              context: context,
              onSettings: () => _openSettings(context),
              onHelp: () => _openHelp(context),
              onDebug: () => _openDebug(context),
              settingsBadge:
                  notificationsBlocked.value || exactAlarmsBlocked.value,
            ),
            body: widget.navigationShell,
            bottomNavigationBar: BottomNavBar(
              items: [
                BottomNavItemData(
                  icon: AppIconName.home,
                  selectedIcon: AppIconName.homeSolid,
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavItemData(
                  icon: AppIconName.pray,
                  selectedIcon: AppIconName.praySolid,
                  label: AppLocalizations.of(context)!.pray,
                ),
                BottomNavItemData(
                  icon: AppIconName.peopleGroup,
                  selectedIcon: AppIconName.peopleGroupSolid,
                  label: AppLocalizations.of(context)!.search,
                ),
              ],
              currentIndex: widget.navigationShell.currentIndex,
              onTap: _onTabTap,
            ),
          ),
        ),
      ),
    );
  }
}
