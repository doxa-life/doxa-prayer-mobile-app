import 'package:flutter/material.dart';

enum _ActionButtonKind { label, iconLabel, icon, fullWidth }

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : _kind = _ActionButtonKind.label;

  const ActionButton.iconLabel({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  }) : _kind = _ActionButtonKind.iconLabel;

  const ActionButton.icon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label = '',
  }) : _kind = _ActionButtonKind.icon;

  const ActionButton.fullWidth({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : _kind = _ActionButtonKind.fullWidth;

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final _ActionButtonKind _kind;

  @override
  Widget build(BuildContext context) {
    final upper = label.toUpperCase();
    switch (_kind) {
      case _ActionButtonKind.label:
        return FilledButton(onPressed: onPressed, child: Text(upper));
      case _ActionButtonKind.iconLabel:
        return FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(upper),
        );
      case _ActionButtonKind.icon:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            minimumSize: const Size(56, 56),
          ),
          child: Icon(icon),
        );
      case _ActionButtonKind.fullWidth:
        return SizedBox(
          width: double.infinity,
          child: icon == null
              ? FilledButton(onPressed: onPressed, child: Text(upper))
              : FilledButton.icon(
                  onPressed: onPressed,
                  icon: Icon(icon),
                  label: Text(upper),
                ),
        );
    }
  }
}
