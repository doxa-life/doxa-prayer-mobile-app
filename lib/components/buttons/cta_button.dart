import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CtaButton extends StatelessWidget {
  const CtaButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(64, 56),
        ),
        child: Text(label.toUpperCase()),
      ),
    );
  }
}
