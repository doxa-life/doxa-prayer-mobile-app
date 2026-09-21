import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/pray_selector_controller.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_colors.dart';
import '../misc/app_image.dart';

/// The active people group's photo, in the app bar, on the Pray tab only.
///
/// It is both the indicator — the face you are praying for, at any scroll
/// position — and the control that slides the switcher back down once reading
/// has pushed it away.
class PrayGroupAvatarButton extends StatelessWidget {
  const PrayGroupAvatarButton({super.key, required this.group});

  final SubscribedPeopleGroup group;

  static const double _size = 30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<bool>(
      valueListenable: praySelectorOpen,
      builder: (context, open, _) {
        return IconButton(
          tooltip: l10n.switchToPeopleGroup(group.name),
          onPressed: togglePraySelector,
          icon: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Ringed while the switcher is down, so the button shows its own
              // state rather than leaving the sheet to explain itself.
              border: Border.all(
                color: open ? AppColors.onPrimary : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: AppImage(
                url: group.imageUrl,
                size: _size,
                semanticLabel: group.name,
              ),
            ),
          ),
        );
      },
    );
  }
}
