import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/select_people_group_flow.dart';
import '../../services/selected_people_group_controller.dart';
import 'action_button.dart';

class SelectPeopleGroupButton extends StatelessWidget {
  const SelectPeopleGroupButton({
    super.key,
    required this.slug,
    required this.name,
    required this.imageUrl,
  });

  final String slug;
  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<SelectedPeopleGroup?>(
      valueListenable: selectedPeopleGroupController,
      builder: (context, selected, _) {
        final isSelected = selected?.slug == slug;
        return ActionButton.fullWidth(
          label: isSelected ? l10n.selected : l10n.select,
          onPressed: isSelected
              ? null
              : () => showSelectPeopleGroupConfirmation(
                  context,
                  slug: slug,
                  name: name,
                  imageUrl: imageUrl,
                ),
          color: ActionButtonColor.secondary,
        );
      },
    );
  }
}
