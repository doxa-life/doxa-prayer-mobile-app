import 'package:flutter/material.dart';

import 'components/misc/app_icon.dart';
import 'components/nav/bottom_nav_bar.dart';
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('DOXA'),
        actions: [
          IconButton(
            icon: const AppIcon(AppIconName.gear),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
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
            icon: AppIconName.person,
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
