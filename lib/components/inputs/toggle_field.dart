import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';

class ToggleField extends StatelessWidget {
  const ToggleField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.bodyLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTypography.caption),
                  ],
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
