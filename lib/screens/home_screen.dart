import 'package:doxa_prayer_mobile_app/components/buttons/cta_button.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_card.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/services/selected_people_group_controller.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: _peopleGroupCardOrCTA(),
      ),
    );
  }

  Widget _peopleGroupCardOrCTA() {
    return ValueListenableBuilder<SelectedPeopleGroup?>(
      valueListenable: selectedPeopleGroupController,
      builder: (context, selected, _) {
        return selected == null
            ? CtaButton(
                label: AppLocalizations.of(context)!.selectPeopleGroup,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'navigating to people groups screen coming soon',
                      ),
                    ),
                  );
                },
              )
            : PeopleGroupCard(
                name: selected.name,
                imageUrl: '',
                onPray: () {},
                onDetails: () {},
              );
      },
    );
  }
}
