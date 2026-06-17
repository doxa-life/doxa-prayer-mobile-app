import 'package:doxa_prayer_mobile_app/components/misc/background_image_container.dart';
import 'package:doxa_prayer_mobile_app/components/nav/top_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'components/misc/app_icon.dart';
import 'components/nav/bottom_nav_bar.dart';
import 'router.dart';
import 'services/analytics_service.dart';
import 'services/reminders_notifications.dart';
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
    if (reminderTapPayload.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onReminderTap());
    }
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
      // Re-check the version gate when returning to the foreground.
      checkForAppUpdate();
      // Count the foreground resume as an app-open (cold start is tracked in main()).
      trackAppOpen();
    }
  }

  void _onReminderTap() {
    final payload = reminderTapPayload.value;
    if (payload == null) return;
    reminderTapPayload.value = null;
    if (!mounted) return;
    final prayIndex = AppRoute.values.indexOf(AppRoute.pray);
    widget.navigationShell.goBranch(prayIndex, initialLocation: true);
  }

  void _openSettings(BuildContext context) => context.push('/settings');

  void _openGallery(BuildContext context) => context.push('/gallery');

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
        content: Text(AppLocalizations.of(context)!.pressBackAgainToExit),
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TopNavBar(
            onSettings: () => _openSettings(context),
            onGallery: () => _openGallery(context),
            onDebug: () => _openDebug(context),
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
              BottomNavItemData(
                icon: AppIconName.bell,
                selectedIcon: AppIconName.bellSolid,
                label: AppLocalizations.of(context)!.reminders,
              ),
            ],
            currentIndex: widget.navigationShell.currentIndex,
            onTap: _onTabTap,
          ),
        ),
      ),
    );
  }
}
