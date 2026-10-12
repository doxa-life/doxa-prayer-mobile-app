import 'package:flutter/material.dart';

/// A country's flag, from the images bundled in assets/flags/ (see
/// tool/fetch_flags.py). Bundled rather than downloaded, so flags show
/// instantly, offline, and are never re-fetched; once decoded they stay in
/// Flutter's image cache like any other asset.
///
/// [code] is the ISO alpha-3 code the API sends ("MYS"). An unknown code
/// renders nothing. Decorative: the country's name is always shown next to
/// it, so screen readers skip the flag.
class CountryFlag extends StatelessWidget {
  const CountryFlag({super.key, required this.code, this.height = 12});

  final String code;
  final double height;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.15);
    return ExcludeSemantics(
      child: Container(
        // A hairline edge, so white-edged flags (Japan, Indonesia) don't
        // dissolve into the card.
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: outline, width: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.asset(
            'assets/flags/${code.toUpperCase()}.png',
            height: height,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
