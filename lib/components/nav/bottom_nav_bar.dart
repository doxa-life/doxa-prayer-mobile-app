import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../misc/app_icon.dart';

class BottomNavItemData {
  const BottomNavItemData({
    required this.icon,
    required this.label,
    AppIconName? selectedIcon,
  }) : selectedIcon = selectedIcon ?? icon;

  final AppIconName icon;
  final AppIconName selectedIcon;
  final String label;
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BottomNavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(
      context,
    ).extension<AppColorsExtra>()!.onPrimarySelected;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          for (var i = 0; i < items.length; i++)
            BottomNavigationBarItem(
              icon: AppIcon(
                i == currentIndex ? items[i].selectedIcon : items[i].icon,
                color: i == currentIndex ? selectedColor : AppColors.onPrimary,
              ),
              label: items[i].label.toUpperCase(),
            ),
        ],
        backgroundColor: AppColors.primary,
        selectedItemColor: selectedColor,
        unselectedItemColor: AppColors.onPrimary,
        selectedLabelStyle: AppTypography.caption.copyWith(
          fontSize: AppTypography.xs,
        ),
        unselectedLabelStyle: AppTypography.caption.copyWith(
          fontSize: AppTypography.xs,
        ),
      ),
    );
  }
}
