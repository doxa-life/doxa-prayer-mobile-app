import 'package:doxa_prayer_mobile_app/layouts/fill_viewport_scroll_view.dart';
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
        // The logo is part of the content column (not a Positioned layer) so
        // it reserves space and the centered text can never rise underneath
        // it on short viewports; the scroll view takes over when even the
        // collapsed column doesn't fit.
        Positioned.fill(
          child: PageContainer(
            verticalPadding: 0,
            child: FillViewportScrollView(
              padKeyboardInset: false,
              builder: (context, maxWidth) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 50.0,
                children: [
                  Image.asset(
                    'assets/images/doxa-logo-vertical.png',
                    height: 140,
                  ),
                  H1(l.wizardWelcomeTitle, textAlign: TextAlign.center),
                  Text(
                    l.wizardWelcomeBody,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  // Resolves a deferred "Pray on the app" referral (if any)
                  // and jumps to the confirm step with that group pre-filled;
                  // otherwise advances to the people-groups list. Shows a
                  // spinner while the referred group is being looked up.
                  if (controller.resolvingReferral)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: CircularProgressIndicator(),
                    )
                  else
                    ActionButton(
                      label: l.wizardGetStarted,
                      onPressed: controller.startFromWelcome,
                      color: ActionButtonColor.secondary,
                    ),
                  SizedBox(height: AppSpacing.xxxs),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
