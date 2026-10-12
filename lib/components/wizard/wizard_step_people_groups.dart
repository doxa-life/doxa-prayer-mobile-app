import 'package:doxa_prayer_mobile_app/components/buttons/action_button.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../misc/titles.dart';
import '../widgets/people_groups_list.dart';

class WizardStepPeopleGroups extends StatelessWidget {
  const WizardStepPeopleGroups({super.key, required this.controller});

  final WizardController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // The keyboard overlays this step (resizeToAvoidBottomInset is off on the
    // wizard Scaffold) so the title and search field stay put while typing;
    // matching bottom padding lets the results scroll clear of the keyboard.
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.lg,
        children: [
          H1(l.wizardChoosePeopleGroupTitle, textAlign: TextAlign.center),
          Expanded(
            child: PeopleGroupsList(
              onSelect: controller.proposePeopleGroup,
              onSelectionConfirmed: (_) => controller.next(),
              listBottomPadding: keyboardInset + AppSpacing.lg,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Skip picks a group for the user (see
              // WizardController.skipPeopleGroup) rather than leaving them
              // with none.
              ActionButton(
                label: l.skip,
                onPressed: controller.autoSelectingGroup
                    ? null
                    : controller.skipPeopleGroup,
                isOutlined: true,
                color: ActionButtonColor.white,
              ),
              if (controller.autoSelectingGroup) ...[
                const SizedBox(width: AppSpacing.md),
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
