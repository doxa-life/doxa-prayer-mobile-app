import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/news_signup_service.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/titles.dart';
import '../widgets/news_signup.dart';

class WizardStepNewsSignup extends StatelessWidget {
  const WizardStepNewsSignup({super.key, required this.controller});

  final WizardController controller;

  Future<void> _onSubmit(BuildContext context, NewsSignupData data) async {
    await submitNewsSignup(data);
    if (!context.mounted) return;
    await controller.finish(context);
  }

  Future<void> _onSkip(BuildContext context) async {
    await controller.finish(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          H1(l.wizardNewsSignupTitle, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l.wizardNewsSignupBody,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          NewsSignup(
            onSubmit: (data) => _onSubmit(context, data),
            onSkip: () => _onSkip(context),
            submitLabel: l.finish,
          ),
        ],
      ),
    );
  }
}
