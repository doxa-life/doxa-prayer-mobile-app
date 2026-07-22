import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/titles.dart';

/// In-place confirmation shown after feedback is submitted. Thanks the user and
/// echoes the email the feedback was sent with, so they can confirm it matches
/// the address they intended (the feedback loop doesn't verify emails server-side).
class FeedbackSuccess extends StatelessWidget {
  const FeedbackSuccess({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Icon(
          Icons.check_circle_outline,
          size: 56,
          color: AppColors.secondary,
        ),
        const SizedBox(height: AppSpacing.lg),
        H1(l.feedbackSuccessTitle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l.feedbackSuccessBody(email),
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
