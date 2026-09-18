import 'package:doxa_prayer_mobile_app/layouts/fill_viewport_scroll_view.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../buttons/button_bar_wrap.dart';
import '../cards/people_group_card.dart';
import '../misc/hyphenated_text.dart';
import '../misc/titles.dart';

class WizardStepPeopleGroupConfirm extends StatelessWidget {
  const WizardStepPeopleGroupConfirm({super.key, required this.controller});

  final WizardController controller;

  Future<void> _onContinue(BuildContext context) async {
    final g = controller.candidatePeopleGroup;
    if (g == null) return;
    await addPeopleGroup(
      SubscribedPeopleGroup(slug: g.slug, name: g.name, imageUrl: g.imageUrl),
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
      child: FillViewportScrollView(
        builder: (context, maxWidth) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                H1(
                  l.wizardConfirmPeopleGroupTitle(g.name),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                HyphenatedText(
                  l.wizardConfirmPeopleGroupBody,
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                PeopleGroupCard(name: g.name, imageUrl: g.imageUrl),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
            ButtonBarWrap(
              maxWidth: maxWidth,
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
      ),
    );
  }
}
