import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/titles.dart';

class WizardStepWelcome extends StatelessWidget {
  const WizardStepWelcome({super.key, required this.controller});

  final WizardController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            'assets/images/worldmap.svg',
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/doxa-logo-vertical.png',
            height: 140,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white.withValues(alpha: 0.5)],
                stops: const [0.0, 1],
              ),
            ),
            child: Image.asset(
              'assets/images/pray-03-bottom-unsplash.jpg',
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        Positioned.fill(
          child: PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: AppSpacing.xl,
              children: [
                H1(l.wizardWelcomeTitle, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l.wizardWelcomeBody,
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                if (controller.resolvingReferral)
                  const CircularProgressIndicator()
                else
                  ActionButton(
                    label: l.wizardGetStarted,
                    onPressed: controller.startFromWelcome,
                    color: ActionButtonColor.secondary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
