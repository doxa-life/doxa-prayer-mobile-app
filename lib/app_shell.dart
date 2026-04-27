import 'package:doxa_prayer_mobile_app/components/nav/top_nav_bar.dart';
import 'package:flutter/material.dart';

import 'components/misc/app_icon.dart';
import 'components/nav/bottom_nav_bar.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/people_groups_screen.dart';
import 'screens/pray_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

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
        title: 'DOXA',
        onSettings: _openSettings,
        onGallery: _openGallery,
      ),
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: BottomNavBar(
        items: const [
          BottomNavItemData(
            icon: AppIconName.home,
            selectedIcon: AppIconName.homeSolid,
            label: 'Home',
          ),
          BottomNavItemData(
            icon: AppIconName.pray,
            selectedIcon: AppIconName.praySolid,
            label: 'Pray',
          ),
          BottomNavItemData(
            icon: AppIconName.peopleGroup,
            selectedIcon: AppIconName.peopleGroupSolid,
            label: 'People Groups',
          ),
          BottomNavItemData(
            icon: AppIconName.bell,
            selectedIcon: AppIconName.bellSolid,
            label: 'Reminders',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
