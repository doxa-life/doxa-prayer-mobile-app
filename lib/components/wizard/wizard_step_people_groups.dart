import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../buttons/button_link.dart';
import '../misc/titles.dart';
import '../widgets/people_groups_list.dart';

class WizardStepPeopleGroups extends StatelessWidget {
  const WizardStepPeopleGroups({super.key, required this.controller});

  final WizardController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        H1(l.wizardChoosePeopleGroupTitle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: PeopleGroupsList(onSelect: controller.proposePeopleGroup),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ButtonLink(
              label: l.skip,
              onPressed: controller.skipPeopleGroup,
            ),
          ],
        ),
      ],
    );
  }
}
