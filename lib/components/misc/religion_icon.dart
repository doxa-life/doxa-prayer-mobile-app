import 'package:flutter/material.dart';

/// The icon for a religion, from the API's religion code ("MSN", "CPR"…),
/// or null for a religion with no fitting icon — those simply show none.
///
/// The code's first letter is the religion family (the IMB "registry of
/// religion" codes): B Buddhism, C Christianity, H Hinduism, M Islam,
/// J Judaism. Ethnic religions (E), the "other" religions (O), Sikhism (S),
/// non-religious (N) and unknown (U) have no icon.
IconData? religionIconFor(String? code) {
  if (code == null || code.isEmpty) return null;
  return switch (code[0].toUpperCase()) {
    'B' => Icons.temple_buddhist,
    'C' => Icons.church,
    'H' => Icons.temple_hindu,
    'M' => Icons.mosque,
    'J' => Icons.synagogue,
    _ => null,
  };
}

/// [religionIconFor] as a widget; nothing at all when there's no icon.
/// Decorative: the religion's name is always shown beside it.
class ReligionIcon extends StatelessWidget {
  const ReligionIcon({super.key, required this.code, this.size = 18});

  final String? code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = religionIconFor(code);
    if (icon == null) return const SizedBox.shrink();
    return ExcludeSemantics(
      child: Icon(
        icon,
        size: size,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}
