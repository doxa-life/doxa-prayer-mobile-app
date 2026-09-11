import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_controller.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../buttons/button_bar_wrap.dart';
import 'hyphenated_text.dart';

/// Asked when adding a people group would exceed [kMaxPeopleGroups]: pick one
/// of the current groups to stop praying for, and the new one takes its place.
///
/// Nothing is preselected and the confirm button stays disabled until the user
/// picks. The same modal serves a deliberate add and a tap on a share link, so
/// it is built for the second: ending a months-old commitment must be a
/// decision, never the path of least resistance.
///
/// Returns the slug to drop, or null if the user backed out.
Future<String?> showSwapPeopleGroupModal(
  BuildContext context, {
  required String incomingName,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _SwapPeopleGroupModal(incomingName: incomingName),
  );
}

class _SwapPeopleGroupModal extends StatefulWidget {
  const _SwapPeopleGroupModal({required this.incomingName});

  final String incomingName;

  @override
  State<_SwapPeopleGroupModal> createState() => _SwapPeopleGroupModalState();
}

class _SwapPeopleGroupModalState extends State<_SwapPeopleGroupModal> {
  String? _chosen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groups = peopleGroupsController.value.list;
    final reminders = remindersController.value;

    return Dialog(
      backgroundColor: AppColors.surface,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: HyphenatedText(
                l10n.peopleGroupLimitTitle(groups.length),
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            HyphenatedText(
              l10n.peopleGroupLimitBody(widget.incomingName),
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final group in groups)
              _GroupChoice(
                name: group.name,
                // Naming the reminder count here is the whole point: it is what
                // the user actually loses, and it is invisible otherwise.
                reminderCount: reminders?.forGroup(group.slug).length ?? 0,
                selected: _chosen == group.slug,
                onSelected: () => setState(() => _chosen = group.slug),
              ),
            const SizedBox(height: AppSpacing.xl),
            ButtonBarWrap(
              leading: ActionButton(
                label: l10n.cancel,
                onPressed: () => Navigator.of(context).pop(),
                color: ActionButtonColor.primary,
              ),
              trailing: ActionButton(
                label: l10n.swapPeopleGroupAction,
                // Disabled until a group is picked — there is no sensible
                // default, and guessing one would drop a commitment for them.
                onPressed: _chosen == null
                    ? null
                    : () => Navigator.of(context).pop(_chosen),
                color: ActionButtonColor.secondary,
                isOutlined: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupChoice extends StatelessWidget {
  const _GroupChoice({
    required this.name,
    required this.reminderCount,
    required this.selected,
    required this.onSelected,
  });

  final String name;
  final int reminderCount;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              // A plain icon rather than a Radio: the whole row is the tap
              // target already, and this keeps the choice visibly unset until
              // the user makes it.
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.secondary : AppColors.outline,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HyphenatedText(name, style: AppTypography.bodyMedium),
                    if (reminderCount > 0)
                      HyphenatedText(
                        l10n.removePeopleGroupReminders(reminderCount),
                        style: AppTypography.caption,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
