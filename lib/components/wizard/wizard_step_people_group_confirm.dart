import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/selected_people_group_controller.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../buttons/button_bar_wrap.dart';
import '../cards/people_group_card.dart';
import '../misc/titles.dart';

class WizardStepPeopleGroupConfirm extends StatelessWidget {
  const WizardStepPeopleGroupConfirm({super.key, required this.controller});

  final WizardController controller;

  Future<void> _onContinue(BuildContext context) async {
    final g = controller.candidatePeopleGroup;
    if (g == null) return;
    await setSelectedPeopleGroup(
      SelectedPeopleGroup(slug: g.slug, name: g.name, imageUrl: g.imageUrl),
    );
    controller.next();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final g = controller.candidatePeopleGroup;
    if (g == null) {
      return const SizedBox.shrink();
    }
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          H1(
            l.wizardConfirmPeopleGroupTitle(g.name),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l.wizardConfirmPeopleGroupBody,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PeopleGroupCard(name: g.name, imageUrl: g.imageUrl),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(child: SizedBox.shrink()),
          ButtonBarWrap(
            leading: ActionButton(
              label: l.back,
              color: ActionButtonColor.white,
              isOutlined: true,
              onPressed: controller.cancelPeopleGroupSelection,
            ),
            trailing: ActionButton(
              label: l.continueLabel,
              color: ActionButtonColor.secondary,
              onPressed: () => _onContinue(context),
            ),
          ),
        ],
      ),
    );
  }
}
