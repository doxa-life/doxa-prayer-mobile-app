import 'package:flutter/material.dart';

import '../components/buttons/action_button.dart';
import '../components/misc/action_modal.dart';
import '../l10n/app_localizations.dart';
import 'selected_people_group_controller.dart';

Future<bool> showSelectPeopleGroupConfirmation(
  BuildContext context, {
  required String slug,
  required String name,
  required String? imageUrl,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final current = selectedPeopleGroupController.value;
  if (current?.slug == slug) return false;

  final message = current == null
      ? l10n.selectPeopleGroupConfirm
      : l10n.switchPeopleGroupConfirm(current.name, name);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => ActionModal(
      message: message,
      actionButtons: [
        ActionButton(
          label: l10n.no,
          onPressed: () => Navigator.of(ctx).pop(false),
          color: ActionButtonColor.white,
        ),
        ActionButton(
          label: l10n.yes,
          onPressed: () => Navigator.of(ctx).pop(true),
          color: ActionButtonColor.secondaryLight,
          isOutlined: true,
        ),
      ],
    ),
  );

  if (confirmed != true) return false;

  await setSelectedPeopleGroup(
    SelectedPeopleGroup(slug: slug, name: name, imageUrl: imageUrl),
  );
  return true;
}
