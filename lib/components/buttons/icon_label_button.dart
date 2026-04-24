import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class IconLabelButton extends StatelessWidget {
  const IconLabelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
