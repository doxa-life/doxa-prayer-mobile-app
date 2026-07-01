import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/icon_label_button.dart';
import '../misc/app_icon.dart';
import 'elevated_card.dart';

class GetInvolvedCard extends StatelessWidget {
  const GetInvolvedCard({
    super.key,
    required this.onDonate,
    required this.onFeedback,
    this.onCopyFeedbackLink,
  });

  final VoidCallback onDonate;
  final VoidCallback onFeedback;

  /// Debug-only: when provided, renders a button that copies the feedback URL
  /// to the clipboard (so it can be opened on a dev machine). Null in release.
  final VoidCallback? onCopyFeedbackLink;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ElevatedAppCard(
      padding: AppSpacing.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: AppSpacing.lg,
        children: [
          Text(l.getInvolved, style: AppTypography.h2),
          Row(
            spacing: AppSpacing.md,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconLabelButton(
                icon: const AppIcon(AppIconName.heart),
                label: l.donate,
                onPressed: onDonate,
              ),
              IconLabelButton(
                icon: const AppIcon(AppIconName.chat),
                label: l.feedback,
                onPressed: onFeedback,
              ),
              if (onCopyFeedbackLink != null)
                IconLabelButton(
                  icon: const AppIcon(AppIconName.link),
                  label: 'Copy link',
                  onPressed: onCopyFeedbackLink!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
