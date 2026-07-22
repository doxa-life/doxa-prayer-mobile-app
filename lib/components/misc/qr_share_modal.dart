import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Shows a dismissable dialog with a QR code of [url], so someone physically
/// nearby can scan the share link instead of receiving it over a channel.
Future<void> showQrShareModal(
  BuildContext context, {
  required String url,
  required String peopleGroupName,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => QrShareModal(url: url, peopleGroupName: peopleGroupName),
  );
}

class QrShareModal extends StatelessWidget {
  const QrShareModal({
    super.key,
    required this.url,
    required this.peopleGroupName,
  });

  final String url;
  final String peopleGroupName;

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
                tooltip: MaterialLocalizations.of(
                  context,
                ).closeButtonTooltip,
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
            Text(
              l.scanToPray(peopleGroupName),
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
