import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'status_pill.dart';

/// "Selected" badge — this is one of the people groups the user prays for.
///
/// Accent-coloured, matching the accent fill those groups' pins get on the map,
/// so the pin and its card say the same thing in the same colour.
class SelectedPill extends StatelessWidget {
  const SelectedPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return StatusPill(
      label: label,
      color: AppColors.secondary,
      icon: Icons.favorite,
    );
  }
}
