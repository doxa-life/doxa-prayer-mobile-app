import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../layouts/page_scaffold.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/entrance_fade_slide.dart';
import '../misc/fit_to_page.dart';
import '../misc/hyphenated_text.dart';

/// Staggered reveal: the intro first, then the choice, then the note.
const _choiceDelay = Duration(milliseconds: 350);
const _noteDelay = Duration(milliseconds: 650);

/// Explains why the app needs a people group, then lets the user choose how:
/// search for one ([WizardController.searchForGroup]) or have one picked for
/// them ([WizardController.skipPeopleGroup]). Neither is final — the group can
/// be changed later. Always fits on one screen (see [FitToPage]).
class WizardStepGroupIntro extends StatelessWidget {
  const WizardStepGroupIntro({super.key, required this.controller});

  final WizardController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final busy = controller.autoSelectingGroup;
    return PageContainer(
      child: Center(
        child: FitToPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xl,
            children: [
              EntranceFadeSlide(
                child: HyphenatedText(
                  l.wizardGroupIntroBody,
                  style: AppTypography.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              EntranceFadeSlide(
                delay: _choiceDelay,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.md,
                  children: [
                    ActionButton.fullWidth(
                      label: l.wizardGroupIntroSearchOption,
                      onPressed: busy ? null : controller.searchForGroup,
                      color: ActionButtonColor.secondary,
                    ),
                    ActionButton.fullWidth(
                      label: l.wizardGroupIntroPickForMeOption,
                      onPressed: busy ? null : controller.skipPeopleGroup,
                      color: ActionButtonColor.white,
                      isOutlined: true,
                    ),
                    // Space kept while hidden, so the spinner appearing doesn't
                    // shift the column.
                    Visibility(
                      visible: busy,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
              ),
              EntranceFadeSlide(
                delay: _noteDelay,
                child: HyphenatedText(
                  l.wizardGroupIntroChangeLaterNote,
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
