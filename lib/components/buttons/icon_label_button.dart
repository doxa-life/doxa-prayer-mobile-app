import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/hyphenated_text.dart';

class IconLabelButton extends StatelessWidget {
  const IconLabelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(button: true, enabled: _enabled, child: _build(context)),
    );
  }

  Widget _build(BuildContext context) {
    // A button with no callback is inert either way; muting it is what tells
    // the user that, rather than leaving it looking tappable.
    final tint = _enabled ? AppColors.primary : AppColors.primaryLight;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme.merge(
              data: IconThemeData(color: tint, size: 28),
              child: icon,
            ),
            const SizedBox(height: 6),
            HyphenatedText(
              label.toUpperCase(),
              style: AppTypography.caption.copyWith(color: tint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
