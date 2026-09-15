import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/people_group_subscription_flow.dart';
import '../../services/subscribed_people_groups_controller.dart';
import 'action_button.dart';

/// Adds or removes a people group from the user's subscriptions. Shown on the
/// group's details page, which is where every add route lands — including the
/// `/app/<slug>` share link.
///
/// At the cap the button stays live: [addPeopleGroupFlow] answers with the swap
/// modal rather than a dead end.
class SubscribePeopleGroupButton extends StatelessWidget {
  const SubscribePeopleGroupButton({
    super.key,
    required this.slug,
    required this.name,
    required this.imageUrl,
    this.onAdded,
  });

  final String slug;
  final String name;
  final String? imageUrl;

  /// Fires after the user successfully subscribes. The wizard uses this to pop
  /// back with its selection made.
  final VoidCallback? onAdded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<SubscribedPeopleGroups>(
      valueListenable: peopleGroupsController,
      builder: (context, groups, _) {
        final subscribed = groups.contains(slug);
        return ActionButton.fullWidth(
          // "Unselect", not a state word: the button has to read as the
          // action it performs, and it matches the browse list's wording so
          // the two screens offer the same thing by the same name.
          label: subscribed ? l10n.unselect : l10n.select,
          onPressed: () async {
            if (subscribed) {
              await removePeopleGroupFlow(context, slug: slug);
              return;
            }
            final added = await addPeopleGroupFlow(
              context,
              slug: slug,
              name: name,
              imageUrl: imageUrl,
            );
            if (added) onAdded?.call();
          },
          color: subscribed
              ? ActionButtonColor.white
              : ActionButtonColor.secondary,
          isOutlined: subscribed,
        );
      },
    );
  }
}
