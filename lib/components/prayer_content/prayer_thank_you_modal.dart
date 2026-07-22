import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/app_icon.dart';

/// Shows an encouraging modal thanking the user for praying, affirming that
/// their prayers make a difference. Shown after the user taps "Amen".
Future<void> showPrayerThankYouModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => const PrayerThankYouModal(),
  );
}

class PrayerThankYouModal extends StatelessWidget {
  const PrayerThankYouModal({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: SingleChildScrollView(
        // Scrolls when large accessibility font scales make the content
        // taller than the dialog; shrink-wraps otherwise.
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.primary),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Text(
              l10n.prayerThankYouTitle,
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.prayerThankYouMessage,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.prayerThankYouVerse,
              style: AppTypography.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.primaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.prayerThankYouVerseReference,
              style: AppTypography.caption.copyWith(
                color: AppColors.primaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ActionButton.fullWidth(
              label: l10n.home,
              icon: const AppIcon(AppIconName.home),
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
              color: ActionButtonColor.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
