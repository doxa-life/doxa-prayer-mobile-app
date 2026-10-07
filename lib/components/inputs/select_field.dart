import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import '../misc/hyphenated_text.dart';

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
      // Without isExpanded the selected value is laid out at its natural
      // width, so a long label ("Islam - Sunni", a long language name) pushes
      // the arrow off the field. The value row has a fixed height, so it is
      // kept to one line with an ellipsis; the open menu still shows the full
      // text.
      isExpanded: true,
      selectedItemBuilder: (context) => [
        for (final item in items)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: item.child,
            ),
          ),
      ],
      decoration: InputDecoration(
        // Clamp the floating label's text scaling so it stays within the
        // outline border's notch at large accessibility font sizes. Left
        // unclamped, an over-large label is clipped by the top border and
        // pushes the value down until its descenders clip too. The selected
        // value itself is left unclamped.
        label: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: HyphenatedText(label),
        ),
        hintText: hint,
      ),
      icon: const Icon(Icons.expand_more),
      style: AppTypography.bodyMedium,
    );
  }
}
