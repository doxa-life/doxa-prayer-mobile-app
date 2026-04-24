import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ButtonLink extends StatelessWidget {
  const ButtonLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.secondary,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
