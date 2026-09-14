import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'status_pill.dart';

/// "Prayed today" badge. Shared by the home carousel's cards, the Pray tab's
/// people group row and the map's pin card, so today's progress reads the same
/// in all three.
class PrayedTodayPill extends StatelessWidget {
  const PrayedTodayPill({super.key, required this.label, this.compact = false});

  final String label;

  /// Drops the text, leaving just the check — for the Pray tab's avatars,
  /// where a full pill would be wider than the avatar it sits on.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return StatusPill(
      label: label,
      // Muted rather than accent: having prayed is a completed fact, and the
      // accent is reserved for the groups the user has committed to.
      color: AppColors.primaryLight,
      icon: Icons.check,
      compact: compact,
    );
  }
}
