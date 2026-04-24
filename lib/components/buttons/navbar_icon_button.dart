import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class NavbarIconButton extends StatelessWidget {
  const NavbarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: IconTheme.merge(
        data: const IconThemeData(color: AppColors.onSurface),
        child: icon,
      ),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
