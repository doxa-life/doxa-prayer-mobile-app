import 'package:doxa_prayer_mobile_app/components/buttons/icon_label_button.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_icon.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/app_image.dart';
import 'elevated_card.dart';
import '../misc/hyphenated_text.dart';
import '../misc/check_icon.dart';

class PeopleGroupCard extends StatelessWidget {
  const PeopleGroupCard({
    super.key,
    required this.name,
    required this.imageUrl,
    this.prayedToday = false,
    this.onPray,
    this.onShare,
    this.onDetails,
  });

  final String name;
  final String? imageUrl;

  /// Whether the user has already prayed for this group today. The Pray
  /// button then says so instead, and still opens the prayer, for anyone who
  /// wants to pray again.
  final bool prayedToday;
  final VoidCallback? onPray;

  /// Opens the share modal, which carries both the QR code and the
  /// device's share sheet.
  final VoidCallback? onShare;
  final VoidCallback? onDetails;

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
            prayedToday
                // Muted, with a check: today's prayer is done.
                ? ActionButton.iconLabel(
                    label: l.prayedToday,
                    icon: const CheckIcon(size: 16, color: AppColors.white),
                    onPressed: onPray,
                    color: ActionButtonColor.secondaryLight,
                  )
                : ActionButton(
                    label: l.pray,
                    onPressed: onPray,
                    color: ActionButtonColor.secondary,
                  ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
