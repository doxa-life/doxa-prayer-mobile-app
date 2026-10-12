import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../misc/hyphenated_text.dart';

class CheckboxField extends StatelessWidget {
  const CheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.leading,
  });

  final String label;

  /// Shown between the checkbox and [label], e.g. a country's flag.
  final Widget? leading;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(child: _build(context));
  }

  Widget _build(BuildContext context) {
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
            if (leading case final leading?) ...[
              leading,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: HyphenatedText(label, style: AppTypography.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
