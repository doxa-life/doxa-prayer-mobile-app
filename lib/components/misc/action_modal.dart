import 'package:doxa_prayer_mobile_app/components/buttons/action_button.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ActionModal extends StatelessWidget {
  const ActionModal({
    super.key,
    required this.message,
    required this.actionButtons,
  });

  final String message;
  final List<ActionButton> actionButtons;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        message,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.onSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.xxl,
      ),
      backgroundColor: AppColors.secondary,
      actions: [
        Row(
          spacing: AppSpacing.xxl,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: actionButtons,
        ),
      ],
    );
  }
}
