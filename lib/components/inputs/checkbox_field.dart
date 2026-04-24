import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';

class CheckboxField extends StatelessWidget {
  const CheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
