import 'package:doxa_prayer_mobile_app/components/buttons/action_button.dart';
import 'package:doxa_prayer_mobile_app/components/buttons/wizard_button_bar.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ActionModal extends StatelessWidget {
  const ActionModal({
    super.key,
    required this.message,
    required this.actionButtons,
  }) : assert(
         actionButtons.length == 2,
         'ActionModal lays out exactly two buttons (leading + trailing).',
       );

  final String message;
  final List<ActionButton> actionButtons;

  @override
  Widget build(BuildContext context) {
    // A plain Dialog rather than AlertDialog: AlertDialog wraps its content in
    // IntrinsicWidth, which both hugs the message width (so a wide button row
    // overflows) and breaks WizardButtonBar's LayoutBuilder. A Dialog gives the
    // child bounded width, so the button bar can measure it and lay the buttons
    // out side by side — or stacked full width when a longer (e.g. translated)
    // label wouldn't fit.
    return Dialog(
      backgroundColor: AppColors.secondary,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            WizardButtonBar(
              leading: actionButtons.first,
              trailing: actionButtons.last,
            ),
          ],
        ),
      ),
    );
  }
}
