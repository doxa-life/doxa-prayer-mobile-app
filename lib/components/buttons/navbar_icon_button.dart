import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class NavbarIconButton extends StatelessWidget {
  const NavbarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: AppColors.onSurface,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
