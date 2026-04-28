import 'package:doxa_prayer_mobile_app/components/nav/top_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'components/misc/app_icon.dart';
import 'components/nav/bottom_nav_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _openSettings(BuildContext context) => context.push('/settings');

  void _openGallery(BuildContext context) => context.push('/gallery');

  void _onTabTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(
        title: AppLocalizations.of(context)!.appName,
        onSettings: () => _openSettings(context),
        onGallery: () => _openGallery(context),
      ),
      body: navigationShell,
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
            label: AppLocalizations.of(context)!.peopleGroups,
          ),
          BottomNavItemData(
            icon: AppIconName.bell,
            selectedIcon: AppIconName.bellSolid,
            label: AppLocalizations.of(context)!.reminders,
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
