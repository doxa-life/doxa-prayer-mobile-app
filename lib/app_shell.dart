import 'package:doxa_prayer_mobile_app/components/nav/top_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'components/misc/app_icon.dart';
import 'components/nav/bottom_nav_bar.dart';
import 'router.dart';
import 'services/reminders_notifications.dart';

const _kBackgroundColor = Color(0xFFF3F3F1);
const _kPatternColor = Color(0xFFEDEEEC);
const _kTabletBreakpoint = 600.0;

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    reminderTapPayload.addListener(_onReminderTap);
    // Handle a payload that was already set (cold-start from notification tap).
    if (reminderTapPayload.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onReminderTap());
    }
  }

  @override
  void dispose() {
    reminderTapPayload.removeListener(_onReminderTap);
    super.dispose();
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

  void _onTabTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.sizeOf(context).shortestSide >= _kTabletBreakpoint;
    final backgroundAsset = isTablet
        ? 'assets/images/tablet-background.svg'
        : 'assets/images/mobile-background.svg';

    return Container(
      color: _kBackgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              backgroundAsset,
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(
                _kPatternColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: TopNavBar(
              title: AppLocalizations.of(context)!.appName,
              onSettings: () => _openSettings(context),
              onGallery: () => _openGallery(context),
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
                  label: AppLocalizations.of(context)!.peopleGroups,
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
        ],
      ),
    );
  }
}
