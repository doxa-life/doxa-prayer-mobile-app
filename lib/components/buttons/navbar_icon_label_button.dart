import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class NavbarIconLabelButton extends StatelessWidget {
  const NavbarIconLabelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.onSurface;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
