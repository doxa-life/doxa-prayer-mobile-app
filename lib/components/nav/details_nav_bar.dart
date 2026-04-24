import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../misc/triangle_icon.dart';

class DetailsNavBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailsNavBar({super.key, this.title = 'DOXA', this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: onBack != null
          ? IconButton(
              icon: const TriangleIcon(
                color: AppColors.onSurface,
                direction: TriangleDirection.left,
                size: 12,
              ),
              onPressed: onBack,
            )
          : null,
      centerTitle: true,
      title: Text(
        title,
        style: AppTypography.h2.copyWith(color: AppColors.onSurface),
      ),
      backgroundColor: AppColors.surface,
    );
  }
}
