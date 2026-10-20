import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/people_group_subscription_flow.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/check_icon.dart';
import '../misc/hyphenated_text.dart';
import '../misc/plus_icon.dart';

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
        // Drawn as the app's call-to-action buttons are — large display
        // label, raised, with its icon in a circle at the end — so it reads
        // as the main thing to do on the profile. Selected, it turns white
        // with a green outline, so the two states can't be mistaken.
        final fill = subscribed ? AppColors.white : AppColors.secondary;
        final ink = subscribed ? AppColors.primary : AppColors.white;
        // Selected, the label says so ("Selected" rather than a negative
        // "Deselect"); screen readers still hear what a tap does.
        return Semantics(
          hint: subscribed ? l10n.deselect : null,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.35),
                backgroundColor: fill,
                foregroundColor: ink,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                minimumSize: const Size(64, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: subscribed
                      ? const BorderSide(color: AppColors.primary, width: 2)
                      : BorderSide.none,
                ),
              ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: HyphenatedText(
                      // Matches the browse list's wording, so the two screens
                      // show the same state by the same name.
                      (subscribed ? l10n.selected : l10n.select).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTypography.h2.copyWith(color: ink),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: ShapeDecoration(
                        shape: const CircleBorder(),
                        color: subscribed ? AppColors.primary : AppColors.white,
                      ),
                      child: subscribed
                          ? const CheckIcon(size: 14, color: AppColors.white)
                          : const PlusIcon(
                              color: AppColors.secondary,
                              size: 18,
                              thickness: 4,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
