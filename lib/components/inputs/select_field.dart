import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class SelectField<T> extends StatelessWidget {
  const SelectField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        // Clamp the floating label's text scaling so it stays within the
        // outline border's notch at large accessibility font sizes. Left
        // unclamped, an over-large label is clipped by the top border and
        // pushes the value down until its descenders clip too. The selected
        // value itself is left unclamped.
        label: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Text(label),
        ),
        hintText: hint,
      ),
      icon: const Icon(Icons.expand_more),
      style: AppTypography.bodyMedium,
    );
  }
}
