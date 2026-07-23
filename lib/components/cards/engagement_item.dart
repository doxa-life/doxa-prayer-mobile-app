import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../misc/check_icon.dart';
import '../misc/close_icon.dart';
import '../misc/icon_circle.dart';

enum EngagementStatus { yes, no, partial }

/// A single engagement marker: a coloured tick / cross circle above a [label]
/// (e.g. "Prayer Status", "Adoption Status").
///
/// The tick / cross is drawn as a [CustomPaint] icon that carries no text, so
/// on its own a screen reader would announce only the label and never whether
/// the marker is met. This wraps the marker in an explicit semantics node —
/// "{label}: {status}" — and excludes the decorative children, so TalkBack
/// speaks the status that sighted users read from the icon's shape and colour.
class EngagementItem extends StatelessWidget {
  const EngagementItem({super.key, required this.label, required this.status});

  final String label;
  final EngagementStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = switch (status) {
      EngagementStatus.yes => AppColors.secondary,
      EngagementStatus.no => AppColors.scheme.error,
      EngagementStatus.partial => AppColors.partial,
    };

    final icon = switch (status) {
      EngagementStatus.yes => const CheckIcon(
        size: AppTypography.md,
        color: AppColors.white,
      ),
      EngagementStatus.partial => const CheckIcon(
        size: AppTypography.md,
        color: AppColors.white,
      ),
      EngagementStatus.no => const CloseIcon(
        size: AppTypography.md,
        color: AppColors.white,
      ),
    };

    final statusLabel = switch (status) {
      EngagementStatus.yes => l.yes,
      EngagementStatus.no => l.no,
      EngagementStatus.partial => l.partial,
    };

    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The tick / cross is a text-less CustomPaint icon, so give it the
          // spoken status as its own semantics node. Kept separate from the
          // label (rather than a single "{label}: {status}" node) so the
          // status word is announced in isolation — a bare "No" at the tail of
          // a longer phrase was read by TTS as the abbreviation "№" ("number").
          Semantics(
            label: statusLabel,
            child: IconCircle(icon: icon, color: color),
          ),
          Text(
            label,
            style: AppTypography.h1.copyWith(fontSize: AppTypography.md),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
