import 'package:doxa_prayer_mobile_app/components/nav/top_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'components/misc/app_icon.dart';
import 'components/nav/bottom_nav_bar.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/people_groups_screen.dart';
import 'screens/pray_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/settings_screen.dart';
import 'services/selected_tab_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    PrayScreen(),
    PeopleGroupsScreen(),
    RemindersScreen(),
  ];

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  void _openGallery() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const GalleryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(
        title: AppLocalizations.of(context)!.appName,
        onSettings: _openSettings,
        onGallery: _openGallery,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: selectedTabController,
        builder: (context, index, _) =>
            IndexedStack(index: index, children: _tabs),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: selectedTabController,
        builder: (context, index, _) => BottomNavBar(
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
          currentIndex: index,
          onTap: (i) => selectedTabController.value = i,
        ),
      ),
    );
  }
}
