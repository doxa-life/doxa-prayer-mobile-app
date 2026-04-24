import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
      ),
    );
  }
}
