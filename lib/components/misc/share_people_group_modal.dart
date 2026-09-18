import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import 'app_icon.dart';
import 'hyphenated_text.dart';

/// Shows the single share surface for a people group: a QR code of [url] for
/// someone physically nearby to scan, and a button handing the same link to
/// the device's share sheet for everyone else.
///
/// The two are one modal rather than two card buttons because they are the
/// same act — the QR is just the in-person channel.
Future<void> showSharePeopleGroupModal(
  BuildContext context, {
  required String url,
  required String peopleGroupName,
  required ValueChanged<Rect?> onShareLink,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => SharePeopleGroupModal(
      url: url,
      peopleGroupName: peopleGroupName,
      onShareLink: onShareLink,
    ),
  );
}

class SharePeopleGroupModal extends StatelessWidget {
  const SharePeopleGroupModal({
    super.key,
    required this.url,
    required this.peopleGroupName,
    required this.onShareLink,
  });

  final String url;
  final String peopleGroupName;

  /// Called once the modal has closed, with the modal's own bounds — iPads
  /// need a popover anchor for the share sheet, and the modal is the last
  /// thing the user touched.
  final ValueChanged<Rect?> onShareLink;

  void _shareLink(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    // Close first: the share sheet is the end of this interaction, and
    // returning from it to a stale QR dialog reads as a dead end.
    Navigator.of(context).pop();
    onShareLink(origin);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: SingleChildScrollView(
        // Scrolls when large accessibility font scales make the caption
        // taller than the dialog; shrink-wraps otherwise.
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.primary),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            QrImageView(
              data: url,
              version: QrVersions.auto,
              // Shrink on short viewports so a scannable code stays fully
              // visible without scrolling (the QR itself never scales with
              // font size, only the caption does).
              size: math.min(240.0, MediaQuery.sizeOf(context).height * 0.4),
              backgroundColor: AppColors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            HyphenatedText(
              l.scanToPray(peopleGroupName),
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ActionButton.fullWidth(
              label: l.shareLink,
              icon: const AppIcon(AppIconName.share, color: AppColors.white),
              onPressed: () => _shareLink(context),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
