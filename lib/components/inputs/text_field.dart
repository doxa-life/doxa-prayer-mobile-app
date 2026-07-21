import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.onChanged,
    this.keyboardType,
    this.minLines,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        alignLabelWithHint: true,
      ),
    );
  }
}
