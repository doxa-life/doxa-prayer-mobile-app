import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum _ActionButtonKind { label, iconLabel, icon, fullWidth }

enum ActionButtonColor { primary, secondary, secondaryLight, white }

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = ActionButtonColor.primary,
    this.isOutlined = false,
  }) : _kind = _ActionButtonKind.label,
       semanticLabel = null;

  const ActionButton.iconLabel({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = ActionButtonColor.primary,
    this.isOutlined = false,
  }) : _kind = _ActionButtonKind.iconLabel,
       semanticLabel = null;

  const ActionButton.icon({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.label = '',
    this.color = ActionButtonColor.primary,
    this.isOutlined = false,
  }) : _kind = _ActionButtonKind.icon;

  const ActionButton.fullWidth({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = ActionButtonColor.primary,
    this.isOutlined = false,
  }) : _kind = _ActionButtonKind.fullWidth,
       semanticLabel = null;

  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final ActionButtonColor? color;
  final bool isOutlined;

  /// Accessible label for the icon-only [ActionButton.icon] variant, which has
  /// no visible text for a screen reader to announce.
  final String? semanticLabel;
  final _ActionButtonKind _kind;

  static const borderWidth = 1.5;

  ButtonStyle getStyle(ActionButtonColor color) {
    switch (color) {
      case ActionButtonColor.primary:
        return FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          side: isOutlined
              ? BorderSide(color: AppColors.white, width: borderWidth)
              : null,
        );
      case ActionButtonColor.secondary:
        return FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          side: isOutlined
              ? BorderSide(color: AppColors.white, width: borderWidth)
              : null,
        );
      case ActionButtonColor.secondaryLight:
        return FilledButton.styleFrom(
          backgroundColor: AppColors.secondaryLight,
          foregroundColor: AppColors.white,
          side: isOutlined
              ? BorderSide(color: AppColors.white, width: borderWidth)
              : null,
        );
      case ActionButtonColor.white:
        return FilledButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary,
          side: isOutlined
              ? BorderSide(color: AppColors.onPrimary, width: borderWidth)
              : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final upper = label.toUpperCase();
    switch (_kind) {
      case _ActionButtonKind.label:
        return FilledButton(
          onPressed: onPressed,
          style: getStyle(color!),
          child: Text(upper, textAlign: TextAlign.center),
        );
      case _ActionButtonKind.iconLabel:
        return FilledButton.icon(
          onPressed: onPressed,
          style: getStyle(color!),
          icon: icon!,
          label: Text(upper, textAlign: TextAlign.center),
        );
      case _ActionButtonKind.icon:
        return Semantics(
          button: true,
          label: semanticLabel,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(48, 48),
            ),
            child: ExcludeSemantics(child: icon!),
          ),
        );
      case _ActionButtonKind.fullWidth:
        return SizedBox(
          width: double.infinity,
          child: icon == null
              ? FilledButton(
                  onPressed: onPressed,
                  style: getStyle(color!),
                  child: Text(upper, textAlign: TextAlign.center),
                )
              : FilledButton.icon(
                  onPressed: onPressed,
                  style: getStyle(color!),
                  icon: icon!,
                  label: Text(upper),
                ),
        );
    }
  }
}
