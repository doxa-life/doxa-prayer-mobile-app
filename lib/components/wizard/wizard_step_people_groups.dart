import 'package:doxa_prayer_mobile_app/components/buttons/action_button.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ActionButton(
                label: l.skip,
                onPressed: controller.skipPeopleGroup,
                isOutlined: true,
                color: ActionButtonColor.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
