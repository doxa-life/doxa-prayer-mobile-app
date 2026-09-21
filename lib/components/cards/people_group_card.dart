import 'package:doxa_prayer_mobile_app/components/buttons/icon_label_button.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_icon.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/app_image.dart';
import 'elevated_card.dart';
import '../misc/hyphenated_text.dart';
import '../misc/prayed_today_pill.dart';

class PeopleGroupCard extends StatelessWidget {
  const PeopleGroupCard({
    super.key,
    required this.name,
    required this.imageUrl,
    this.prayedToday = false,
    this.onPray,
    this.onShare,
    this.onDetails,
    this.onMap,
    this.showMap = false,
  });

  final String name;
  final String? imageUrl;
  final bool prayedToday;
  final VoidCallback? onPray;

  /// Opens the share modal, which carries both the QR code and the
  /// device's share sheet.
  final VoidCallback? onShare;
  final VoidCallback? onDetails;

  /// Opens the map of where this group lives. Null leaves the button in place
  /// but disabled, labelled to say the group's location isn't available —
  /// a card that silently loses a button its neighbours have looks broken.
  final VoidCallback? onMap;

  /// Whether the map button belongs on this card at all. False in a build with
  /// no Mapbox token, where there is no map to offer.
  final bool showMap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ElevatedAppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: AppSpacing.xl,
        children: [
          HyphenatedText(name, style: AppTypography.h2),
          AppImage(url: imageUrl, size: 169.0, semanticLabel: name),
          if (onPray != null)
            ActionButton(
              label: l.pray,
              onPressed: onPray,
              color: ActionButtonColor.secondary,
            ),
          if (prayedToday) PrayedTodayPill(label: l.prayedToday),
          // A Wrap (rather than a Row) so the action buttons reflow onto a
          // second line instead of overflowing when large font scales widen
          // their labels. Full width so spaceEvenly spreads them across the
          // card while they fit on one line.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                if (onDetails != null)
                  IconLabelButton(
                    icon: const AppIcon(AppIconName.person),
                    label: l.profile,
                    onPressed: onDetails,
                  ),
                if (onShare != null)
                  IconLabelButton(
                    icon: const AppIcon(AppIconName.share),
                    label: l.share,
                    onPressed: onShare,
                  ),
                if (showMap)
                  IconLabelButton(
                    icon: const AppIcon(AppIconName.geoAlt),
                    label: onMap == null ? l.locationNotAvailable : l.map,
                    onPressed: onMap,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
