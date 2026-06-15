import 'package:doxa_prayer_mobile_app/components/buttons/icon_label_button.dart';
import 'package:doxa_prayer_mobile_app/components/misc/app_icon.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/app_image.dart';
import 'elevated_card.dart';

class PeopleGroupCard extends StatelessWidget {
  const PeopleGroupCard({
    super.key,
    required this.name,
    required this.imageUrl,
    this.prayedToday = false,
    this.onPray,
    this.onShare,
    this.onShowQr,
    this.onDetails,
  });

  final String name;
  final String? imageUrl;
  final bool prayedToday;
  final VoidCallback? onPray;
  final VoidCallback? onShare;
  final VoidCallback? onShowQr;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ElevatedAppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: AppSpacing.xl,
        children: [
          Text(name, style: AppTypography.h2),
          AppImage(url: imageUrl, aspectRatio: 1, size: 169.0),
          if (onPray != null)
            ActionButton(
              label: l.pray,
              onPressed: onPray,
              color: ActionButtonColor.secondary,
            ),
          Row(
            spacing: AppSpacing.md,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              if (onShowQr != null)
                IconLabelButton(
                  icon: const AppIcon(AppIconName.qrCode),
                  label: l.qrCode,
                  onPressed: onShowQr,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
