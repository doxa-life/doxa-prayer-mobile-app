import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/titles.dart';
import '../notifications/enable_notifications_prompt.dart';

/// In-place confirmation shown after the news signup form is submitted. Thanks
/// the user and tells them to check their email to verify their subscription.
class NewsSignupSuccess extends StatelessWidget {
  const NewsSignupSuccess({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Icon(
          Icons.mark_email_read_outlined,
          size: 56,
          color: AppColors.secondary,
        ),
        const SizedBox(height: AppSpacing.lg),
        H1(l.newsSignupSuccessTitle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l.newsSignupSuccessBody(email),
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        // Offer to also enable push notifications (self-hides if already on).
        const EnableNotificationsPrompt(),
      ],
    );
  }
}
