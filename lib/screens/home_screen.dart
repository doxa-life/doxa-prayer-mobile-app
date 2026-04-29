import 'package:doxa_prayer_mobile_app/components/buttons/cta_button.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/reminders_summary.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_icon.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:doxa_prayer_mobile_app/router.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:doxa_prayer_mobile_app/services/selected_people_group_controller.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: ListView(
        children: [
          Column(
            spacing: AppSpacing.xxl,
            children: [_peopleGroupCardOrCTA(), _remindersCardOrCTA()],
          ),
        ],
      ),
    );
  }

  void _openDetails(String slug, BuildContext context) {
    context.push('/people-groups/$slug');
  }

  void _openPray(BuildContext context) {
    context.goNamed(AppRoute.pray.name);
  }

  Widget _peopleGroupCardOrCTA() {
    return ValueListenableBuilder<SelectedPeopleGroup?>(
      valueListenable: selectedPeopleGroupController,
      builder: (context, selected, _) {
        return selected == null
            ? CtaButton(
                label: AppLocalizations.of(context)!.selectPeopleGroup,
                onPressed: () => context.go('/people-groups'),
              )
            : PeopleGroupCard(
                name: selected.name,
                imageUrl: selected.imageUrl ?? '',
                onPray: () => _openPray(context),
                onDetails: () => _openDetails(selected.slug, context),
              );
      },
    );
  }
}

Widget _remindersCardOrCTA() {
  return ValueListenableBuilder<Reminders?>(
    valueListenable: remindersController,
    builder: (context, reminders, _) {
      final hasAny = reminders != null && reminders.list.isNotEmpty;
      return hasAny
          ? RemindersSummary(reminders: reminders)
          : CtaButton(
              label: AppLocalizations.of(context)!.setReminder,
              leadingIcon: const AppIcon(AppIconName.bell),
              onPressed: () => context.go('/reminders'),
            );
    },
  );
}
