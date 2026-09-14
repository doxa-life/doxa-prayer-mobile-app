import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../misc/app_icon.dart';

/// Flies the people-group map back to the group it was opened for.
///
/// Without it the map is a one-way trip: pan away from the focused pin and the
/// only route back is leaving the screen and re-entering it.
class MapRecentreButton extends StatelessWidget {
  const MapRecentreButton({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
  });

  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        icon: const AppIcon(AppIconName.geoAlt, color: AppColors.primary),
        tooltip: semanticLabel,
        onPressed: onPressed,
      ),
    );
  }
}
