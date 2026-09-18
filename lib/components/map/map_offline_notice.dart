import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/hyphenated_text.dart';

/// Explains a map with no basemap under it.
///
/// Shown when tiles repeatedly fail to load — offline, or a connection that
/// answers but can't reach Mapbox. The pins are still drawn, because they come
/// from the cached people-group list rather than the network, so the map stays
/// useful for relative position; this just says why the ground is blank.
class MapOfflineNotice extends StatelessWidget {
  const MapOfflineNotice({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.mutedSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xs,
        children: [
          const Icon(Icons.cloud_off, size: 16, color: AppColors.primaryLight),
          Flexible(
            child: HyphenatedText(
              message,
              softWrap: true,
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
