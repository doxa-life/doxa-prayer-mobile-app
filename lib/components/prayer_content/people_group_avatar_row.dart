import 'package:flutter/material.dart';

import '../../services/prayer_history_service.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_spacing.dart';
import 'people_group_avatar.dart';

/// Switches the Pray tab between the people groups the user prays for, without
/// sending them back to the home carousel to do it.
///
/// Hidden below two subscriptions: with one group there is nothing to switch
/// to, and the row would just take space from the prayer content.
class PeopleGroupAvatarRow extends StatefulWidget {
  const PeopleGroupAvatarRow({super.key, required this.activeSlug});

  /// The group currently on screen — which may be a deep-link override rather
  /// than the stored active group, so it is passed in rather than read here.
  final String activeSlug;

  @override
  State<PeopleGroupAvatarRow> createState() => _PeopleGroupAvatarRowState();
}

class _PeopleGroupAvatarRowState extends State<PeopleGroupAvatarRow> {
  final ScrollController _controller = ScrollController();
  bool _scrolledToActive = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Brings the active avatar into view on first build. Without this the fifth
  /// group sits off the right edge and the row appears to have no selection.
  void _scrollToActive(List<SubscribedPeopleGroup> groups) {
    if (_scrolledToActive) return;
    _scrolledToActive = true;
    final index = groups.indexWhere((g) => g.slug == widget.activeSlug);
    if (index <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      // Left-align the active avatar, minus one slot so the previous one still
      // peeks and the row still reads as scrollable.
      final offset =
          (index - 1) * (PeopleGroupAvatar.slotWidth + AppSpacing.sm);
      _controller.jumpTo(
        offset.clamp(0.0, _controller.position.maxScrollExtent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SubscribedPeopleGroups>(
      valueListenable: peopleGroupsController,
      builder: (context, groups, _) {
        if (groups.list.length < 2) return const SizedBox.shrink();
        _scrollToActive(groups.list);
        return ValueListenableBuilder<Set<String>>(
          valueListenable: prayedTodayController,
          builder: (context, prayedSlugs, _) {
            return SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  for (final group in groups.list)
                    PeopleGroupAvatar(
                      name: group.name,
                      imageUrl: group.imageUrl,
                      selected: group.slug == widget.activeSlug,
                      prayedToday: prayedSlugs.contains(group.slug),
                      onTap: () => setActivePeopleGroup(group.slug),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
