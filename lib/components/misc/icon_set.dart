import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'app_icon.dart';
import 'triangle_icon.dart';

class AppIconEntry {
  const AppIconEntry(this.icon, this.label);
  final AppIconName icon;
  final String label;
}

const appIcons = <AppIconEntry>[
  AppIconEntry(AppIconName.home, 'home'),
  AppIconEntry(AppIconName.homeSolid, 'home-solid'),
  AppIconEntry(AppIconName.pray, 'pray'),
  AppIconEntry(AppIconName.praySolid, 'pray-solid'),
  AppIconEntry(AppIconName.bell, 'bell'),
  AppIconEntry(AppIconName.bellSolid, 'bell-solid'),
  AppIconEntry(AppIconName.person, 'person'),
  AppIconEntry(AppIconName.search, 'search'),
  AppIconEntry(AppIconName.searchSolid, 'search-solid'),
  AppIconEntry(AppIconName.gear, 'gear'),
  AppIconEntry(AppIconName.share, 'share'),
  AppIconEntry(AppIconName.linkOut, 'link-out'),
  AppIconEntry(AppIconName.link, 'link'),
  AppIconEntry(AppIconName.calendar, 'calendar'),
  AppIconEntry(AppIconName.fullscreen, 'fullscreen'),
  AppIconEntry(AppIconName.download, 'download'),
  AppIconEntry(AppIconName.trash, 'trash'),
  AppIconEntry(AppIconName.sun, 'sun'),
];

class IconSet extends StatelessWidget {
  const IconSet({super.key, this.icons = appIcons});
  final List<AppIconEntry> icons;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final it in icons)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(it.icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 4),
              Text(it.label, style: AppTypography.caption),
            ],
          ),
        for (final dir in TriangleDirection.values)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TriangleIcon(
                direction: dir,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text('triangle-${dir.name}', style: AppTypography.caption),
            ],
          ),
      ],
    );
  }
}
