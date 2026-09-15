import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../inputs/select_field.dart';
import '../misc/hyphenated_text.dart';

/// Picks which people group a reminder is for. Every reminder belongs to one,
/// and the editor opens on the active group, so this only needs touching when
/// the user wants a different one.
///
/// Renders nothing when the user prays for a single group: there is no choice
/// to make, and the reminders screen blocks adding one when they pray for none.
class ReminderGroupField extends StatelessWidget {
  const ReminderGroupField({
    super.key,
    required this.slug,
    required this.onChanged,
  });

  final String slug;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ValueListenableBuilder<SubscribedPeopleGroups>(
      valueListenable: peopleGroupsController,
      builder: (context, groups, _) {
        if (groups.list.length < 2) return const SizedBox.shrink();
        return SelectField<String>(
          label: l.reminderPeopleGroup,
          value: groups.contains(slug) ? slug : null,
          items: [
            for (final group in groups.list)
              DropdownMenuItem<String>(
                value: group.slug,
                child: HyphenatedText(group.name),
              ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        );
      },
    );
  }
}
