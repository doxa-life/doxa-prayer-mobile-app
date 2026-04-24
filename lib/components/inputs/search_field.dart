import 'package:flutter/material.dart';

import '../misc/app_icon.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.hint = 'Search',
    this.controller,
    this.onChanged,
    this.onClear,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasText = controller != null && controller!.text.isNotEmpty;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12),
          child: AppIcon(AppIconName.search, size: 20),
        ),
        suffixIcon: hasText
            ? IconButton(icon: const Icon(Icons.close), onPressed: onClear)
            : null,
      ),
    );
  }
}
