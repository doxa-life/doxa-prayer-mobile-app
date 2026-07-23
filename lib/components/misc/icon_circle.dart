import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// A small filled circle wrapping an [icon] — used for the tick / cross status
/// markers on the people-group details screen.
class IconCircle extends StatelessWidget {
  const IconCircle({super.key, required this.icon, required this.color});

  final Widget icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: Padding(padding: const EdgeInsets.all(AppSpacing.xs), child: icon),
    );
  }
}
